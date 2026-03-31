extends GutTest


func test_game_descriptor_is_descriptor() -> void:
	var game := GameDescriptor.new()
	assert_is(game, Descriptor)


func test_mod_descriptor_is_descriptor() -> void:
	var mod := ModDescriptor.new()
	assert_is(mod, Descriptor)


func test_game_descriptor_overrides_config_file() -> void:
	assert_eq(GameDescriptor.config_file, "game.cfg")


func test_game_descriptor_overrides_section() -> void:
	assert_eq(GameDescriptor.section, "Godot Game")


func test_mod_descriptor_overrides_config_file() -> void:
	assert_eq(ModDescriptor.config_file, "mod.cfg")


func test_mod_descriptor_overrides_section() -> void:
	assert_eq(ModDescriptor.section, "Godot Mod")


func test_game_descriptor_implements_load_data() -> void:
	var game := GameDescriptor.new()
	assert_has_method(game, "load_data")


func test_game_descriptor_implements_save_data() -> void:
	var game := GameDescriptor.new()
	assert_has_method(game, "save_data")


func test_mod_descriptor_implements_load_data() -> void:
	var mod := ModDescriptor.new()
	assert_has_method(mod, "load_data")


func test_mod_descriptor_implements_save_data() -> void:
	var mod := ModDescriptor.new()
	assert_has_method(mod, "save_data")
