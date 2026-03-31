extends GutTest
## Verify FileAccess.get_size() static method (GH-83538) is used for descriptor
## file validation, rejecting empty files instead of only checking existence.


# -- FileAccess.get_size() static method --

func test_get_size_returns_zero_for_empty_file() -> void:
	var path: String = "user://test_empty.cfg"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file = null

	assert_true(FileAccess.file_exists(path), "Empty file should exist")
	assert_eq(FileAccess.get_size(path), 0, "get_size() should return 0 for empty files")

	DirAccess.remove_absolute(path)


func test_get_size_returns_positive_for_nonempty_file() -> void:
	var path: String = "user://test_nonempty.cfg"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("[Godot Game]\ntitle=\"Test\"\n")
	file = null

	assert_gt(FileAccess.get_size(path), 0, "get_size() should return > 0 for non-empty files")

	DirAccess.remove_absolute(path)


# -- GameDescriptor rejects empty config files --

func test_game_descriptor_rejects_empty_config() -> void:
	var tmp_dir: String = "user://test_game_empty_cfg"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var cfg_path: String = tmp_dir.path_join(GameDescriptor.config_file)
	var file: FileAccess = FileAccess.open(cfg_path, FileAccess.WRITE)
	file = null

	var descriptor := GameDescriptor.new()
	assert_false(descriptor.load_data(tmp_dir), "load_data() should reject empty config file")

	DirAccess.remove_absolute(cfg_path)
	DirAccess.remove_absolute(tmp_dir)


func test_game_descriptor_loads_valid_config() -> void:
	var tmp_dir: String = "user://test_game_valid_cfg"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	var descriptor := GameDescriptor.new()
	descriptor.title = "Test"
	descriptor.godot_version = "4.3"
	descriptor.main_scene = "res://Main.tscn"
	descriptor.save_data(tmp_dir)

	var loaded := GameDescriptor.new()
	assert_true(loaded.load_data(tmp_dir), "load_data() should accept valid config file")
	assert_eq(loaded.title, "Test")

	DirAccess.remove_absolute(tmp_dir.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


# -- ModDescriptor rejects empty config files --

func test_mod_descriptor_rejects_empty_config() -> void:
	var tmp_dir: String = "user://test_mod_empty_cfg"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var cfg_path: String = tmp_dir.path_join(ModDescriptor.config_file)
	var file: FileAccess = FileAccess.open(cfg_path, FileAccess.WRITE)
	file = null

	var descriptor := ModDescriptor.new()
	assert_false(descriptor.load_data(tmp_dir), "load_data() should reject empty config file")

	DirAccess.remove_absolute(cfg_path)
	DirAccess.remove_absolute(tmp_dir)


func test_mod_descriptor_loads_valid_config() -> void:
	var tmp_dir: String = "user://test_mod_valid_cfg"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	var descriptor := ModDescriptor.new()
	descriptor.game = "Test"
	descriptor.name = "Mod"
	descriptor.description = "Desc"
	descriptor.version = "1.0"
	descriptor.save_data(tmp_dir)

	var loaded := ModDescriptor.new()
	assert_true(loaded.load_data(tmp_dir), "load_data() should accept valid config file")
	assert_eq(loaded.name, "Mod")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)
