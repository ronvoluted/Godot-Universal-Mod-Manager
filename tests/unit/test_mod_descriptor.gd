extends GutTest

var descriptor: ModDescriptor


func before_each() -> void:
	descriptor = ModDescriptor.new()


func test_static_config_file() -> void:
	assert_eq(ModDescriptor.config_file, "mod.cfg")


func test_static_section() -> void:
	assert_eq(ModDescriptor.section, "Godot Mod")


func test_initial_properties_are_empty() -> void:
	assert_eq(descriptor.game, "")
	assert_eq(descriptor.name, "")
	assert_eq(descriptor.description, "")
	assert_eq(descriptor.version, "")


func test_save_and_load_roundtrip() -> void:
	var tmp_dir := DirAccess.create_temp("test_mod_descriptor")

	descriptor.game = "Test Game"
	descriptor.name = "Cool Mod"
	descriptor.description = "A cool mod"
	descriptor.version = "1.0.0"
	descriptor.save_data(tmp_dir)

	var loaded := ModDescriptor.new()
	var result := loaded.load_data(tmp_dir)

	assert_true(result)
	assert_eq(loaded.game, "Test Game")
	assert_eq(loaded.name, "Cool Mod")
	assert_eq(loaded.description, "A cool mod")
	assert_eq(loaded.version, "1.0.0")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_load_returns_false_for_missing_file() -> void:
	var result := descriptor.load_data("user://nonexistent_path")
	assert_false(result)
