extends GutTest


# -- GameData is a standalone RefCounted class --

func test_game_data_is_ref_counted() -> void:
	var game := GameData.new({})
	assert_true(game is RefCounted)


func test_game_data_class_name_accessible_globally() -> void:
	var game := GameData.new({entry_path = "/a", game_path = "/b", installed_mods = []})
	assert_eq(game.get_class(), "RefCounted")
	assert_eq(game.entry_path, "/a")
	assert_eq(game.game_path, "/b")


func test_game_data_static_vars_accessible() -> void:
	assert_eq(GameData.mod_loader_scene, "GUMM_mod_loader.tscn")
	assert_eq(GameData.mod_loader_autoload, "GUMM_mod_loader_autoload.gd")


# -- ModData is a standalone RefCounted class --

func test_mod_data_is_ref_counted() -> void:
	var mod := ModData.new({})
	assert_true(mod is RefCounted)


func test_mod_data_class_name_accessible_globally() -> void:
	var mod := ModData.new({load_path = "/mods/test"})
	assert_eq(mod.get_class(), "RefCounted")
	assert_eq(mod.load_path, "/mods/test")


func test_mod_data_has_descriptor_entry() -> void:
	var mod := ModData.new({})
	assert_not_null(mod.entry)
	assert_true(mod.entry is ModDescriptor)


# -- GameData composes ModData --

func test_game_data_installed_mods_typed_as_mod_data() -> void:
	var raw_mods: Array[Variant] = [{load_path = "/mods/a", active = true}, {load_path = "/mods/b", active = false}]
	var game := GameData.new({entry_path = "", game_path = "", installed_mods = raw_mods})
	assert_eq(game.installed_mods.size(), 2)
	assert_true(game.installed_mods[0] is ModData)
	assert_true(game.installed_mods[1] is ModData)


# -- Serialization round-trip --

func test_game_data_get_var_round_trip() -> void:
	var game := GameData.new({entry_path = "/e", game_path = "/g", installed_mods = [{load_path = "/m", active = true}]})
	var data := game.get_var()
	assert_eq(data.entry_path, "/e")
	assert_eq(data.game_path, "/g")
	assert_eq(data.installed_mods.size(), 1)


func test_mod_data_get_var_round_trip() -> void:
	var mod := ModData.new({load_path = "/mods/x", active = true})
	var data := mod.get_var()
	assert_eq(data.load_path, "/mods/x")
	# active is false because load_data fails for invalid path
	assert_false(data.active)
