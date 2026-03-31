extends GutTest

var descriptor: GameDescriptor


func before_each():
	descriptor = GameDescriptor.new()


func test_initial_properties_are_empty():
	assert_eq(descriptor.title, "")
	assert_eq(descriptor.godot_version, "")
	assert_eq(descriptor.main_scene, "")


func test_save_and_load_roundtrip():
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

	DirAccess.remove_absolute(tmp_dir.path_join("game.cfg"))
	DirAccess.remove_absolute(tmp_dir)


func test_load_returns_false_for_missing_file():
	var result := descriptor.load_data("user://nonexistent_path")
	assert_false(result)
