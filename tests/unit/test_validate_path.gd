extends GutTest


# -- GameDescriptor.validate_path --

func test_game_validate_empty_path() -> void:
	assert_eq(GameDescriptor.validate_path(""), "Path can't be empty.")


func test_game_validate_whitespace_path() -> void:
	assert_eq(GameDescriptor.validate_path("   "), "Path can't be empty.")


func test_game_validate_nonexistent_directory() -> void:
	var error := GameDescriptor.validate_path("user://no_such_dir_game_validate")
	assert_eq(error, "The provided directory does not exist.")


func test_game_validate_missing_config() -> void:
	var tmp := "user://test_game_validate_no_cfg"
	DirAccess.make_dir_recursive_absolute(tmp)
	var error := GameDescriptor.validate_path(tmp)
	assert_string_contains(error, GameDescriptor.config_file)
	DirAccess.remove_absolute(tmp)


func test_game_validate_empty_config() -> void:
	var tmp := "user://test_game_validate_empty"
	DirAccess.make_dir_recursive_absolute(tmp)
	var file := FileAccess.open(tmp.path_join(GameDescriptor.config_file), FileAccess.WRITE)
	file.close()

	var error := GameDescriptor.validate_path(tmp)
	assert_string_contains(error, "empty")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


func test_game_validate_malformed_config() -> void:
	var tmp := "user://test_game_validate_bad"
	DirAccess.make_dir_recursive_absolute(tmp)
	var file := FileAccess.open(tmp.path_join(GameDescriptor.config_file), FileAccess.WRITE)
	file.store_string("not valid config")
	file.close()

	var error := GameDescriptor.validate_path(tmp)
	assert_string_contains(error, "malformed")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


func test_game_validate_valid_config() -> void:
	var tmp := "user://test_game_validate_ok"
	DirAccess.make_dir_recursive_absolute(tmp)
	var desc := GameDescriptor.new()
	desc.title = "Test Game"
	desc.godot_version = "4.x"
	desc.main_scene = "res://Main.tscn"
	desc.save_data(tmp)

	var error := GameDescriptor.validate_path(tmp)
	assert_eq(error, "")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


# -- ModDescriptor.validate_path --

func test_mod_validate_empty_path() -> void:
	assert_eq(ModDescriptor.validate_path(""), "Path can't be empty.")


func test_mod_validate_nonexistent_directory() -> void:
	var error := ModDescriptor.validate_path("user://no_such_dir_mod_validate")
	assert_eq(error, "The provided directory does not exist.")


func test_mod_validate_missing_config() -> void:
	var tmp := "user://test_mod_validate_no_cfg"
	DirAccess.make_dir_recursive_absolute(tmp)
	var error := ModDescriptor.validate_path(tmp)
	assert_string_contains(error, ModDescriptor.config_file)
	DirAccess.remove_absolute(tmp)


func test_mod_validate_valid_config() -> void:
	var tmp := "user://test_mod_validate_ok"
	DirAccess.make_dir_recursive_absolute(tmp)
	var desc := ModDescriptor.new()
	desc.game = "Test Game"
	desc.name = "Test Mod"
	desc.description = "A test"
	desc.version = "1.0"
	desc.save_data(tmp)

	var error := ModDescriptor.validate_path(tmp)
	assert_eq(error, "")

	DirAccess.remove_absolute(tmp.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp)
