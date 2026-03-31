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

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_load_returns_false_for_missing_file() -> void:
	var result := descriptor.load_data("user://nonexistent_path")
	assert_false(result)


func test_load_returns_false_for_empty_file() -> void:
	var tmp_dir := "user://test_error_mod_empty"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var file := FileAccess.open(tmp_dir.path_join(ModDescriptor.config_file), FileAccess.WRITE)
	file.close()

	var result := descriptor.load_data(tmp_dir)
	assert_false(result)

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_save_returns_ok_on_success() -> void:
	var tmp_dir := "user://test_error_mod_save"
	DirAccess.make_dir_recursive_absolute(tmp_dir)

	descriptor.game = "Test Game"
	descriptor.name = "Test Mod"
	descriptor.description = "A test"
	descriptor.version = "1.0"
	var err := descriptor.save_data(tmp_dir)
	assert_eq(err, OK)

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_save_returns_error_for_invalid_path() -> void:
	descriptor.name = "Test"
	var err := descriptor.save_data("://invalid_path_that_cannot_exist")
	assert_ne(err, OK)
	assert_push_error_count(1)


# -- Inheritance --

func test_extends_descriptor() -> void:
	assert_is(descriptor, Descriptor)


func test_overrides_read_and_write_fields() -> void:
	assert_true(descriptor.has_method("_read_fields"))
	assert_true(descriptor.has_method("_write_fields"))


# -- Version coercion from non-string config values --

func test_version_from_float_config_value() -> void:
	var tmp_dir := "user://test_float_version"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", 2.0)
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var loaded := ModDescriptor.new()
	var ok := loaded.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(loaded.version, "2", "Whole-number float 2.0 should load as '2'")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_version_from_fractional_float() -> void:
	var tmp_dir := "user://test_frac_version"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", 1.5)
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var loaded := ModDescriptor.new()
	var ok := loaded.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(loaded.version, "1.5", "Fractional float should preserve decimal")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_version_from_integer() -> void:
	var tmp_dir := "user://test_int_version"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", 5)
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var loaded := ModDescriptor.new()
	var ok := loaded.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(loaded.version, "5", "Integer version should convert without decimal")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)
