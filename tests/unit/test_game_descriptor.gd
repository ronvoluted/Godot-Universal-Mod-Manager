extends GutTest

var descriptor: GameDescriptor


func before_each() -> void:
	descriptor = GameDescriptor.new()


func test_static_config_file() -> void:
	assert_eq(GameDescriptor.config_file, "game.cfg")


func test_static_section() -> void:
	assert_eq(GameDescriptor.section, "Godot Game")


func test_initial_properties_are_empty() -> void:
	assert_eq(descriptor.title, "")
	assert_eq(descriptor.godot_version, "")
	assert_eq(descriptor.main_scene, "")


func test_save_and_load_roundtrip() -> void:
	var tmp_dir := "user://test_game_descriptor"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	descriptor.title = "Test Game"
	descriptor.godot_version = "4.3"
	descriptor.main_scene = "res://Main.tscn"
	descriptor.save_data(tmp_dir)

	var loaded := GameDescriptor.new()
	var result := loaded.load_data(tmp_dir)

	assert_true(result)
	assert_eq(loaded.title, "Test Game")
	assert_eq(loaded.godot_version, "4.3")
	assert_eq(loaded.main_scene, "res://Main.tscn")

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_load_returns_false_for_missing_file() -> void:
	var result := descriptor.load_data("user://nonexistent_path")
	assert_false(result)


func test_load_returns_false_for_empty_file() -> void:
	var tmp_dir := "user://test_error_game_empty"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var file := FileAccess.open(tmp_dir.path_join(GameDescriptor.config_file), FileAccess.WRITE)
	file.close()

	var result := descriptor.load_data(tmp_dir)
	assert_false(result)

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_save_returns_ok_on_success() -> void:
	var tmp_dir := "user://test_error_game_save"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	descriptor.title = "Test"
	descriptor.godot_version = "4.x"
	descriptor.main_scene = "res://Main.tscn"
	var err := descriptor.save_data(tmp_dir)
	assert_eq(err, OK)

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_save_returns_error_for_invalid_path() -> void:
	descriptor.title = "Test"
	var err := descriptor.save_data("://invalid_path_that_cannot_exist")
	assert_ne(err, OK)
	assert_push_error_count(1)


# -- Inheritance --

func test_extends_descriptor() -> void:
	assert_is(descriptor, Descriptor)


func test_overrides_read_and_write_fields() -> void:
	assert_true(descriptor.has_method("_read_fields"))
	assert_true(descriptor.has_method("_write_fields"))
