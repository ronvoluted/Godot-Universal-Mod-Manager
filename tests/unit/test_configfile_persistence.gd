extends GutTest
## Verify ConfigFile-based persistence in Registry.
## Covers save/load round-trips, legacy migration from game_list.txt, and edge cases.


const GAME_ENTRIES_FILE: String = "user://game_list.cfg"
const LEGACY_ENTRIES_FILE: String = "user://game_list.txt"


func after_each() -> void:
	if FileAccess.file_exists(GAME_ENTRIES_FILE):
		DirAccess.remove_absolute(GAME_ENTRIES_FILE)
	if FileAccess.file_exists(LEGACY_ENTRIES_FILE):
		DirAccess.remove_absolute(LEGACY_ENTRIES_FILE)


# -- ConfigFile round-trip --

func test_save_and_load_empty_game_list() -> void:
	var cfg := ConfigFile.new()
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_false(loaded.has_section("game.0"))


func test_save_and_load_single_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game.0", "entry_path", "/games/rpg")
	cfg.set_value("game.0", "game_path", "/usr/games/rpg")
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_eq(loaded.get_value("game.0", "entry_path"), "/games/rpg")
	assert_eq(loaded.get_value("game.0", "game_path"), "/usr/games/rpg")


func test_save_and_load_game_with_mods() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game.0", "entry_path", "/games/rpg")
	cfg.set_value("game.0", "game_path", "/usr/games/rpg")
	cfg.set_value("game.0.mod.0", "load_path", "/mods/ui_fix")
	cfg.set_value("game.0.mod.0", "active", true)
	cfg.set_value("game.0.mod.1", "load_path", "/mods/retexture")
	cfg.set_value("game.0.mod.1", "active", false)
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_eq(loaded.get_value("game.0.mod.0", "load_path"), "/mods/ui_fix")
	assert_true(loaded.get_value("game.0.mod.0", "active"))
	assert_eq(loaded.get_value("game.0.mod.1", "load_path"), "/mods/retexture")
	assert_false(loaded.get_value("game.0.mod.1", "active"))


func test_save_and_load_multiple_games() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game.0", "entry_path", "/games/a")
	cfg.set_value("game.0", "game_path", "/gp/a")
	cfg.set_value("game.1", "entry_path", "/games/b")
	cfg.set_value("game.1", "game_path", "/gp/b")
	cfg.set_value("game.1.mod.0", "load_path", "/mods/x")
	cfg.set_value("game.1.mod.0", "active", true)
	cfg.set_value("game.2", "entry_path", "/games/c")
	cfg.set_value("game.2", "game_path", "/gp/c")
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_true(loaded.has_section("game.0"))
	assert_true(loaded.has_section("game.1"))
	assert_true(loaded.has_section("game.1.mod.0"))
	assert_true(loaded.has_section("game.2"))
	assert_eq(loaded.get_value("game.1", "entry_path"), "/games/b")


# -- Registry integration: mirrors _load_config / save_game_entry_list --

func test_registry_save_produces_valid_configfile() -> void:
	var games: Array[GameData] = [
		GameData.new({entry_path = "/e1", game_path = "/g1", installed_mods = []}),
		GameData.new({entry_path = "/e2", game_path = "/g2", installed_mods = [{load_path = "/m1", active = true}]}),
	]
	var cfg := ConfigFile.new()
	for i: int in games.size():
		var game := games[i]
		var section := "game.%d" % i
		cfg.set_value(section, "entry_path", game.entry_path)
		cfg.set_value(section, "game_path", game.game_path)
		for j: int in game.installed_mods.size():
			var mod := game.installed_mods[j]
			var mod_section := "%s.mod.%d" % [section, j]
			cfg.set_value(mod_section, "load_path", mod.load_path)
			cfg.set_value(mod_section, "active", mod.active)
	assert_eq(cfg.save(GAME_ENTRIES_FILE), OK)

	# Reload and reconstruct GameData objects (mirrors Registry._load_config)
	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)

	var restored: Array[GameData] = []
	var game_index := 0
	while loaded.has_section("game.%d" % game_index):
		var section := "game.%d" % game_index
		var mods: Array[Variant] = []
		var mod_index := 0
		while loaded.has_section("%s.mod.%d" % [section, mod_index]):
			var mod_section := "%s.mod.%d" % [section, mod_index]
			mods.append({
				load_path = loaded.get_value(mod_section, "load_path", ""),
				active = loaded.get_value(mod_section, "active", false),
			})
			mod_index += 1
		restored.append(GameData.new({
			entry_path = loaded.get_value(section, "entry_path", ""),
			game_path = loaded.get_value(section, "game_path", ""),
			installed_mods = mods,
		}))
		game_index += 1

	assert_eq(restored.size(), 2)
	assert_eq(restored[0].entry_path, "/e1")
	assert_eq(restored[0].game_path, "/g1")
	assert_eq(restored[0].installed_mods.size(), 0)
	assert_eq(restored[1].entry_path, "/e2")
	assert_eq(restored[1].installed_mods.size(), 1)
	assert_eq(restored[1].installed_mods[0].load_path, "/m1")


# -- Legacy migration: var_to_str game_list.txt → ConfigFile game_list.cfg --

func test_legacy_file_loads_via_str_to_var() -> void:
	var game_list: Array = [
		{entry_path = "/games/alpha", game_path = "/gp/alpha", installed_mods = [], mods_enabled = false},
		{entry_path = "/games/beta", game_path = "/gp/beta", installed_mods = [{load_path = "/mods/fix", active = true}], mods_enabled = true},
	]
	var file := FileAccess.open(LEGACY_ENTRIES_FILE, FileAccess.WRITE)
	file.store_string(var_to_str(game_list))
	file = null

	# Simulate Registry._load_legacy
	var loaded_file := FileAccess.open(LEGACY_ENTRIES_FILE, FileAccess.READ)
	var parsed: Variant = str_to_var(loaded_file.get_as_text())
	loaded_file = null
	assert_true(parsed is Array)

	var games: Array[GameData] = []
	games.assign(Array(parsed).map(GameData.new))
	assert_eq(games.size(), 2)
	assert_eq(games[0].entry_path, "/games/alpha")
	assert_eq(games[1].installed_mods.size(), 1)
	assert_eq(games[1].installed_mods[0].load_path, "/mods/fix")


func test_legacy_migration_writes_configfile_and_removes_txt() -> void:
	# Write a legacy file
	var game_list: Array = [
		{entry_path = "/games/test", game_path = "/gp/test", installed_mods = [{load_path = "/mods/a", active = true}]},
	]
	var file := FileAccess.open(LEGACY_ENTRIES_FILE, FileAccess.WRITE)
	file.store_string(var_to_str(game_list))
	file = null
	assert_true(FileAccess.file_exists(LEGACY_ENTRIES_FILE))

	# Simulate the full migration path from Registry._enter_tree
	var games: Array[GameData] = []
	var loaded_file := FileAccess.open(LEGACY_ENTRIES_FILE, FileAccess.READ)
	var parsed: Variant = str_to_var(loaded_file.get_as_text())
	loaded_file = null
	games.assign(Array(parsed).map(GameData.new))

	# Save as ConfigFile
	var cfg := ConfigFile.new()
	for i: int in games.size():
		var game := games[i]
		var section := "game.%d" % i
		cfg.set_value(section, "entry_path", game.entry_path)
		cfg.set_value(section, "game_path", game.game_path)
		for j: int in game.installed_mods.size():
			var mod := game.installed_mods[j]
			var mod_section := "%s.mod.%d" % [section, j]
			cfg.set_value(mod_section, "load_path", mod.load_path)
			cfg.set_value(mod_section, "active", mod.active)
	assert_eq(cfg.save(GAME_ENTRIES_FILE), OK)
	DirAccess.remove_absolute(LEGACY_ENTRIES_FILE)

	# Verify migration result
	assert_true(FileAccess.file_exists(GAME_ENTRIES_FILE))
	assert_false(FileAccess.file_exists(LEGACY_ENTRIES_FILE))

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_eq(loaded.get_value("game.0", "entry_path"), "/games/test")
	assert_eq(loaded.get_value("game.0", "game_path"), "/gp/test")
	assert_eq(loaded.get_value("game.0.mod.0", "load_path"), "/mods/a")
	# active is false because ModData._init() disables mods when load_data() fails for invalid paths
	assert_false(loaded.get_value("game.0.mod.0", "active"))


# -- Edge cases --

func test_paths_with_special_characters() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game.0", "entry_path", "/path/with spaces/game")
	cfg.set_value("game.0", "game_path", "C:\\Users\\test\\games")
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_eq(loaded.get_value("game.0", "entry_path"), "/path/with spaces/game")
	assert_eq(loaded.get_value("game.0", "game_path"), "C:\\Users\\test\\games")


func test_empty_string_values_preserved() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game.0", "entry_path", "")
	cfg.set_value("game.0", "game_path", "")
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_eq(loaded.get_value("game.0", "entry_path"), "")
	assert_eq(loaded.get_value("game.0", "game_path"), "")


func test_bool_values_preserved_in_configfile() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game.0.mod.0", "active", true)
	cfg.set_value("game.0.mod.1", "active", false)
	cfg.save(GAME_ENTRIES_FILE)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(GAME_ENTRIES_FILE), OK)
	assert_true(loaded.get_value("game.0.mod.0", "active"))
	assert_false(loaded.get_value("game.0.mod.1", "active"))
