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


# -- Static constants --

func test_game_data_static_mod_loader_autoload() -> void:
	assert_eq(GameData.mod_loader_autoload, "GUMM_mod_loader_autoload.gd")


# -- RefCounted inheritance --

func test_game_data_is_refcounted() -> void:
	var game := GameData.new({})
	assert_is(game, RefCounted)


func test_mod_data_is_refcounted() -> void:
	var mod := ModData.new({})
	assert_is(mod, RefCounted)


# -- ModData deactivation on load failure --

func test_mod_data_deactivates_on_missing_descriptor() -> void:
	var mod := ModData.new({load_path = "user://nonexistent_mod_path", active = true})
	assert_false(mod.active, "Mod should be deactivated when descriptor fails to load")


func test_mod_data_stays_active_with_valid_descriptor() -> void:
	var tmp_dir := "user://test_error_mod_data"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	var descriptor := ModDescriptor.new()
	descriptor.game = "Test Game"
	descriptor.name = "Good Mod"
	descriptor.description = "Works"
	descriptor.version = "1.0"
	descriptor.save_data(tmp_dir)

	var mod := ModData.new({load_path = tmp_dir, active = true})
	assert_true(mod.active, "Mod should stay active when descriptor loads successfully")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


# -- Registry save --

func test_registry_save_returns_ok() -> void:
	var err := Registry.save_game_entry_list()
	assert_eq(err, OK)


# -- Untyped dicts accepted by constructors (deserialization compat) --

func test_untyped_dict_accepted_by_mod_data() -> void:
	var data: Dictionary = {load_path = "/mods/from_str", active = true}
	var mod := ModData.new(data)
	assert_eq(mod.load_path, "/mods/from_str")


func test_untyped_dict_accepted_by_game_data() -> void:
	var data: Dictionary = {entry_path = "/ep", game_path = "/gp", installed_mods = []}
	var game := GameData.new(data)
	assert_eq(game.entry_path, "/ep")
	assert_eq(game.game_path, "/gp")


# -- Serialization round-trip --

func test_game_data_serialization_round_trip() -> void:
	var game := GameData.new({
		entry_path = "/rt",
		game_path = "/gp",
		installed_mods = [{load_path = "/mods/a", active = true}],
	})
	var serialized := var_to_str([game.get_var()])
	var deserialized: Array = str_to_var(serialized)
	var restored := GameData.new(deserialized[0])
	assert_eq(restored.entry_path, "/rt")
	assert_eq(restored.installed_mods.size(), 1)
	assert_eq(restored.installed_mods[0].load_path, "/mods/a")
