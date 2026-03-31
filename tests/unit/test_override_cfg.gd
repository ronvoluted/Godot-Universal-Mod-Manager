extends GutTest


var _tmp_entry: String
var _tmp_game: String


func before_each() -> void:
	_tmp_entry = "user://test_override_entry"
	DirAccess.make_dir_recursive_absolute(_tmp_entry)
	_tmp_game = "user://test_override_game"
	DirAccess.make_dir_recursive_absolute(_tmp_game)


func after_each() -> void:
	for path: String in [_tmp_entry, _tmp_game]:
		if DirAccess.dir_exists_absolute(path):
			var dir := DirAccess.open(path)
			if dir:
				for file: String in dir.get_files():
					DirAccess.remove_absolute(path.path_join(file))
			DirAccess.remove_absolute(path)


func _make_game(version: String) -> GameData:
	var desc := GameDescriptor.new()
	desc.title = "Test"
	desc.godot_version = version
	desc.main_scene = "res://Main.tscn"
	desc.save_data(_tmp_entry)
	return GameData.new({entry_path = _tmp_entry, game_path = _tmp_game, installed_mods = []})


# -- OverrideCfg.get_override_path --

func test_get_path_returns_override_cfg_in_game_dir() -> void:
	var game := _make_game("4.x")
	assert_eq(OverrideCfg.get_override_path(game), _tmp_game.path_join("override.cfg"))


# -- OverrideCfg.apply for 4.x --

func test_apply_4x_creates_autoload_entry() -> void:
	var game := _make_game("4.x")
	OverrideCfg.apply(game)

	var cfg := ConfigFile.new()
	assert_eq(cfg.load(OverrideCfg.get_override_path(game)), OK)
	assert_true(cfg.has_section("autoload"))
	assert_eq(cfg.get_value("autoload", "GUMM"), "*res://" + GameData.mod_loader_autoload)


func test_apply_4x_writes_empty_mod_list() -> void:
	var game := _make_game("4.x")
	OverrideCfg.apply(game)

	var cfg := ConfigFile.new()
	cfg.load(OverrideCfg.get_override_path(game))
	var mod_list: Variant = cfg.get_value("gumm", "mod_list")
	assert_eq(mod_list, [])


# -- OverrideCfg.apply for 3.x --

func test_apply_3x_sets_main_scene() -> void:
	var game := _make_game("3.x")
	OverrideCfg.apply(game)

	var cfg := ConfigFile.new()
	cfg.load(OverrideCfg.get_override_path(game))
	assert_eq(cfg.get_value("application", "run/main_scene"), "res://" + GameData.mod_loader_scene)
	assert_eq(cfg.get_value("gumm", "main_scene"), "res://Main.tscn")


# -- OverrideCfg.apply for 2.x --

func test_apply_2x_sets_main_scene() -> void:
	var game := _make_game("2.x")
	OverrideCfg.apply(game)

	var cfg := ConfigFile.new()
	cfg.load(OverrideCfg.get_override_path(game))
	assert_eq(cfg.get_value("application", "main_scene"), "res://" + GameData.mod_loader_scene)
	assert_eq(cfg.get_value("gumm", "main_scene"), "res://Main.tscn")


# -- OverrideCfg.remove --

func test_remove_4x_deletes_override_if_only_gumm() -> void:
	var game := _make_game("4.x")
	OverrideCfg.apply(game)
	assert_true(FileAccess.file_exists(OverrideCfg.get_override_path(game)))

	OverrideCfg.remove(game)
	assert_false(FileAccess.file_exists(OverrideCfg.get_override_path(game)))


func test_remove_3x_deletes_override_if_only_gumm() -> void:
	var game := _make_game("3.x")
	OverrideCfg.apply(game)
	assert_true(FileAccess.file_exists(OverrideCfg.get_override_path(game)))

	OverrideCfg.remove(game)
	assert_false(FileAccess.file_exists(OverrideCfg.get_override_path(game)))


func test_remove_preserves_non_gumm_sections() -> void:
	var game := _make_game("4.x")

	# Write an override.cfg with extra user content
	var cfg := ConfigFile.new()
	cfg.set_value("display", "window/size", "1920x1080")
	cfg.save(OverrideCfg.get_override_path(game))

	# Apply then remove
	OverrideCfg.apply(game)
	OverrideCfg.remove(game)

	# File should still exist with user content preserved
	assert_true(FileAccess.file_exists(OverrideCfg.get_override_path(game)))
	var loaded := ConfigFile.new()
	loaded.load(OverrideCfg.get_override_path(game))
	assert_true(loaded.has_section("display"))
	assert_false(loaded.has_section("autoload"))
	assert_false(loaded.has_section("gumm"))


# -- OverrideCfg.is_disabled --

func test_is_disabled_false_when_no_project_godot() -> void:
	var game := _make_game("4.x")
	assert_false(OverrideCfg.is_disabled(game))


func test_is_disabled_true_when_setting_enabled() -> void:
	var game := _make_game("4.x")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "config/disable_project_settings_override", true)
	cfg.save(_tmp_game.path_join("project.godot"))

	assert_true(OverrideCfg.is_disabled(game))


func test_is_disabled_false_when_setting_not_set() -> void:
	var game := _make_game("4.x")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "config/name", "Test Game")
	cfg.save(_tmp_game.path_join("project.godot"))

	assert_false(OverrideCfg.is_disabled(game))
