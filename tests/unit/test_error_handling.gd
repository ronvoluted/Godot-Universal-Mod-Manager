extends GutTest


# -- GameDescriptor error handling --

func test_game_descriptor_load_missing_file_returns_false() -> void:
	var descriptor := GameDescriptor.new()
	var result := descriptor.load_data("user://nonexistent_test_path")
	assert_false(result)


func test_game_descriptor_load_empty_file_returns_false() -> void:
	var tmp_dir := "user://test_error_game_empty"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var file := FileAccess.open(tmp_dir.path_join(GameDescriptor.config_file), FileAccess.WRITE)
	file.close()

	var descriptor := GameDescriptor.new()
	var result := descriptor.load_data(tmp_dir)
	assert_false(result)

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_game_descriptor_save_returns_ok_on_success() -> void:
	var tmp_dir := "user://test_error_game_save"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	var descriptor := GameDescriptor.new()
	descriptor.title = "Test"
	descriptor.godot_version = "4.x"
	descriptor.main_scene = "res://Main.tscn"
	var err := descriptor.save_data(tmp_dir)
	assert_eq(err, OK)

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_game_descriptor_save_returns_error_for_invalid_path() -> void:
	var descriptor := GameDescriptor.new()
	descriptor.title = "Test"
	var err := descriptor.save_data("://invalid_path_that_cannot_exist")
	assert_ne(err, OK)
	assert_push_error_count(1)


# -- ModDescriptor error handling --

func test_mod_descriptor_load_missing_file_returns_false() -> void:
	var descriptor := ModDescriptor.new()
	var result := descriptor.load_data("user://nonexistent_test_path")
	assert_false(result)


func test_mod_descriptor_load_empty_file_returns_false() -> void:
	var tmp_dir := "user://test_error_mod_empty"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var file := FileAccess.open(tmp_dir.path_join(ModDescriptor.config_file), FileAccess.WRITE)
	file.close()

	var descriptor := ModDescriptor.new()
	var result := descriptor.load_data(tmp_dir)
	assert_false(result)

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_mod_descriptor_save_returns_ok_on_success() -> void:
	var tmp_dir := "user://test_error_mod_save"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	var descriptor := ModDescriptor.new()
	descriptor.game = "Test Game"
	descriptor.name = "Test Mod"
	descriptor.description = "A test"
	descriptor.version = "1.0"
	var err := descriptor.save_data(tmp_dir)
	assert_eq(err, OK)

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_mod_descriptor_save_returns_error_for_invalid_path() -> void:
	var descriptor := ModDescriptor.new()
	descriptor.name = "Test"
	var err := descriptor.save_data("://invalid_path_that_cannot_exist")
	assert_ne(err, OK)
	assert_push_error_count(1)


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


# -- Registry save returns Error --

func test_registry_save_returns_ok() -> void:
	var err := Registry.save_game_entry_list()
	assert_eq(err, OK)
