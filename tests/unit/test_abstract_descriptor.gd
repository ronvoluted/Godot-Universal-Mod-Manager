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


func test_game_descriptor_implements_read_fields() -> void:
	var game := GameDescriptor.new()
	assert_has_method(game, "_read_fields")


func test_game_descriptor_implements_write_fields() -> void:
	var game := GameDescriptor.new()
	assert_has_method(game, "_write_fields")


func test_mod_descriptor_implements_read_fields() -> void:
	var mod := ModDescriptor.new()
	assert_has_method(mod, "_read_fields")


func test_mod_descriptor_implements_write_fields() -> void:
	var mod := ModDescriptor.new()
	assert_has_method(mod, "_write_fields")


func test_load_data_inherited_from_descriptor() -> void:
	var game := GameDescriptor.new()
	var mod := ModDescriptor.new()
	assert_has_method(game, "load_data")
	assert_has_method(mod, "load_data")


func test_save_data_inherited_from_descriptor() -> void:
	var game := GameDescriptor.new()
	var mod := ModDescriptor.new()
	assert_has_method(game, "save_data")
	assert_has_method(mod, "save_data")
