extends GutTest


# -- Registry type safety --

func test_game_entries_file_is_string() -> void:
	assert_typeof(Registry.GAME_ENTRIES_FILE, TYPE_STRING)


func test_games_array_is_typed() -> void:
	var games: Array[GameData] = Registry.games
	assert_eq(typeof(games), TYPE_ARRAY)


func test_icon_formats_is_packed_string_array() -> void:
	assert_typeof(Icons.FORMATS, TYPE_PACKED_STRING_ARRAY)


# -- GameData type safety --

func test_game_data_entry_is_game_descriptor() -> void:
	var game := GameData.new({})
	assert_is(game.entry, GameDescriptor)


func test_game_data_entry_path_is_string() -> void:
	var game := GameData.new({entry_path = "/test"})
	assert_typeof(game.entry_path, TYPE_STRING)


func test_game_data_mods_enabled_is_bool() -> void:
	var game := GameData.new({})
	assert_typeof(game.mods_enabled, TYPE_BOOL)


func test_game_data_installed_mods_is_typed_array() -> void:
	var game := GameData.new({})
	var mods: Array[ModData] = game.installed_mods
	assert_eq(mods.size(), 0)


func test_game_data_get_var_returns_typed_dict() -> void:
	var game := GameData.new({entry_path = "/a", game_path = "/b"})
	var result: Dictionary[StringName, Variant] = game.get_var()
	assert_has(result, &"entry_path")
	assert_has(result, &"game_path")
	assert_has(result, &"installed_mods")


# -- ModData type safety --

func test_mod_data_entry_is_mod_descriptor() -> void:
	var mod := ModData.new({})
	assert_is(mod.entry, ModDescriptor)


func test_mod_data_load_path_is_string() -> void:
	var mod := ModData.new({load_path = "/test"})
	assert_typeof(mod.load_path, TYPE_STRING)


func test_mod_data_active_is_bool() -> void:
	var mod := ModData.new({})
	assert_typeof(mod.active, TYPE_BOOL)


func test_mod_data_get_var_returns_typed_dict() -> void:
	var mod := ModData.new({load_path = "/m", active = false})
	var result: Dictionary[StringName, Variant] = mod.get_var()
	assert_has(result, &"load_path")
	assert_has(result, &"active")


# -- Descriptor type safety --

func test_game_descriptor_properties_are_strings() -> void:
	var desc := GameDescriptor.new()
	assert_typeof(desc.title, TYPE_STRING)
	assert_typeof(desc.godot_version, TYPE_STRING)
	assert_typeof(desc.main_scene, TYPE_STRING)


func test_mod_descriptor_properties_are_strings() -> void:
	var desc := ModDescriptor.new()
	assert_typeof(desc.game, TYPE_STRING)
	assert_typeof(desc.name, TYPE_STRING)
	assert_typeof(desc.description, TYPE_STRING)
	assert_typeof(desc.version, TYPE_STRING)


func test_mod_descriptor_dependencies_is_packed_string_array() -> void:
	var desc := ModDescriptor.new()
	assert_typeof(desc.dependencies, TYPE_PACKED_STRING_ARRAY)
