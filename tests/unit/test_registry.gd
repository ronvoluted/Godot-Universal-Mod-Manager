extends GutTest


func test_game_data_static_mod_loader_scene() -> void:
	assert_eq(GameData.mod_loader_scene, "GUMM_mod_loader.tscn")


# -- GameData: Dictionary.merge() with defaults --

func test_game_data_defaults_fill_missing_keys() -> void:
	var game := GameData.new({})
	assert_eq(game.entry_path, "")
	assert_eq(game.game_path, "")
	assert_eq(game.installed_mods.size(), 0)


func test_game_data_provided_values_overwrite_defaults() -> void:
	var tmp_dir := "user://test_registry_game"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var desc := GameDescriptor.new()
	desc.title = "Test"
	desc.godot_version = "4.x"
	desc.main_scene = "res://Main.tscn"
	desc.save_data(tmp_dir)

	var game := GameData.new({entry_path = tmp_dir, game_path = tmp_dir, installed_mods = []})
	assert_eq(game.entry_path, tmp_dir)
	assert_eq(game.game_path, tmp_dir)
	assert_eq(game.entry.title, "Test")

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_game_data_partial_data_merges_with_defaults() -> void:
	var game := GameData.new({entry_path = "/some/path"})
	assert_eq(game.entry_path, "/some/path")
	assert_eq(game.game_path, "")
	assert_eq(game.installed_mods.size(), 0)


# -- ModData: Dictionary.merge() with defaults --

func test_mod_data_defaults_fill_missing_keys() -> void:
	var mod := ModData.new({})
	assert_eq(mod.load_path, "")
	assert_false(mod.active)


func test_mod_data_provided_values_overwrite_defaults() -> void:
	var mod := ModData.new({load_path = "/mods/test", active = true})
	assert_eq(mod.load_path, "/mods/test")
	# active gets set to false because load_data fails for invalid path
	assert_false(mod.active)


func test_mod_data_partial_data_merges_with_defaults() -> void:
	var mod := ModData.new({load_path = "/mods/partial"})
	assert_eq(mod.load_path, "/mods/partial")
	assert_false(mod.active)
