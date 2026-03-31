extends GutTest

var descriptor: ModDescriptor


func before_each():
	descriptor = ModDescriptor.new()


func test_initial_properties_are_empty():
	assert_eq(descriptor.game, "")
	assert_eq(descriptor.name, "")
	assert_eq(descriptor.description, "")
	assert_eq(descriptor.version, "")


func test_save_and_load_roundtrip():
	var tmp_dir := "user://test_mod_descriptor"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

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

	DirAccess.remove_absolute(tmp_dir.path_join("mod.cfg"))
	DirAccess.remove_absolute(tmp_dir)


func test_load_returns_false_for_missing_file():
	var result := descriptor.load_data("user://nonexistent_path")
	assert_false(result)
