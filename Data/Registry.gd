extends Node

const GAME_ENTRIES_FILE: String = "user://game_list.cfg"
const LEGACY_ENTRIES_FILE: String = "user://game_list.txt"
var games: Array[GameData]

func _enter_tree() -> void:
	if FileAccess.file_exists(GAME_ENTRIES_FILE):
		_load_config()
	elif FileAccess.file_exists(LEGACY_ENTRIES_FILE):
		_load_legacy()
		save_game_entry_list()
		DirAccess.remove_absolute(LEGACY_ENTRIES_FILE)

func _load_config() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(GAME_ENTRIES_FILE)
	if err != OK:
		push_error("Failed to load game list from '%s' (error %d)." % [GAME_ENTRIES_FILE, err])
		return
	var game_index := 0
	while cfg.has_section("game.%d" % game_index):
		var section := "game.%d" % game_index
		var entry_path: String = cfg.get_value(section, "entry_path", "")
		var game_path: String = cfg.get_value(section, "game_path", "")
		var mods: Array[Variant] = []
		var mod_index := 0
		while cfg.has_section("%s.mod.%d" % [section, mod_index]):
			var mod_section := "%s.mod.%d" % [section, mod_index]
			mods.append({
				load_path = cfg.get_value(mod_section, "load_path", ""),
				active = cfg.get_value(mod_section, "active", false),
			})
			mod_index += 1
		games.append(GameData.new({entry_path = entry_path, game_path = game_path, installed_mods = mods}))
		game_index += 1

func _load_legacy() -> void:
	var file := FileAccess.open(LEGACY_ENTRIES_FILE, FileAccess.READ)
	if not file:
		push_error("Failed to open legacy game list '%s' (error %d)." % [LEGACY_ENTRIES_FILE, FileAccess.get_open_error()])
		return
	var game_list: Variant = str_to_var(file.get_as_text())
	if game_list is Array:
		games.assign(Array(game_list).map(GameData.new))

func save_game_entry_list() -> Error:
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
	var err := cfg.save(GAME_ENTRIES_FILE)
	if err != OK:
		push_error("Failed to save game list to '%s' (error %d)." % [GAME_ENTRIES_FILE, err])
	return err

func add_new_game_entry(entry_path: String, game_path: String) -> GameData:
	var game := GameData.new({entry_path = entry_path, game_path = game_path, installed_mods = []})
	games.append(game)
	save_game_entry_list()
	return game

func add_new_mod_entry(game: GameData, load_path: String) -> ModData:
	var mod := ModData.new({load_path = load_path, active = true})

	var dir := DirAccess.open(load_path)
	var existing_index := game.installed_mods.find_custom(func(mod_meta: ModData) -> bool: return dir and dir.is_equivalent(mod_meta.load_path, load_path))
	if existing_index != -1:
		game.installed_mods[existing_index].load_path = load_path
		return game.installed_mods[existing_index]

	game.installed_mods.append(mod)
	save_game_entry_list()
	return mod

func remove_game_entry(game: GameData) -> void:
	games.erase(game)
	save_game_entry_list()

func remove_mod_entry(game: GameData, mod: ModData) -> void:
	game.installed_mods.erase(mod)
	save_game_entry_list()

