extends GutTest
## Verify that float-to-string conversion always includes a decimal (GH-47502)
## and that version strings/numeric displays handle this correctly.
## ModDescriptor and AutoExportVersion guard against whole-number floats
## like 1.0 producing "1.0" instead of the expected "1".


# -- str() behaviour (GH-47502 baseline) --

func test_str_float_includes_decimal() -> void:
	assert_eq(str(1.0), "1.0", "str(1.0) should include a decimal point")


func test_str_float_fractional_unchanged() -> void:
	assert_eq(str(1.5), "1.5")


func test_str_integer_no_decimal() -> void:
	assert_eq(str(1), "1", "str(int) should never include a decimal")


# -- ModDescriptor: version loaded from ConfigFile with float value --

func test_mod_descriptor_version_from_float_config_value() -> void:
	var tmp_dir := DirAccess.create_temp("test_float_version")
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", 2.0)
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var descriptor := ModDescriptor.new()
	var ok := descriptor.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(descriptor.version, "2", "Whole-number float 2.0 should load as '2'")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_mod_descriptor_version_from_fractional_float() -> void:
	var tmp_dir := DirAccess.create_temp("test_frac_version")
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", 1.5)
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var descriptor := ModDescriptor.new()
	var ok := descriptor.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(descriptor.version, "1.5", "Fractional float should preserve decimal")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_mod_descriptor_version_from_string_unchanged() -> void:
	var tmp_dir := DirAccess.create_temp("test_str_version")
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", "3.2.1")
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var descriptor := ModDescriptor.new()
	var ok := descriptor.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(descriptor.version, "3.2.1", "String version should pass through unchanged")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


func test_mod_descriptor_version_from_integer() -> void:
	var tmp_dir := DirAccess.create_temp("test_int_version")
	var cfg := ConfigFile.new()
	cfg.set_value(ModDescriptor.section, "game", "Test")
	cfg.set_value(ModDescriptor.section, "name", "Mod")
	cfg.set_value(ModDescriptor.section, "description", "Desc")
	cfg.set_value(ModDescriptor.section, "version", 5)
	cfg.save(tmp_dir.path_join(ModDescriptor.config_file))

	var descriptor := ModDescriptor.new()
	var ok := descriptor.load_data(tmp_dir)

	assert_true(ok)
	assert_eq(descriptor.version, "5", "Integer version should convert without decimal")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)


# -- Save/load round-trip preserves string version --

func test_mod_descriptor_roundtrip_string_version_stable() -> void:
	var tmp_dir := DirAccess.create_temp("test_roundtrip_version")

	var original := ModDescriptor.new()
	original.game = "Game"
	original.name = "Mod"
	original.description = "Desc"
	original.version = "1.0.0"
	original.save_data(tmp_dir)

	var loaded := ModDescriptor.new()
	loaded.load_data(tmp_dir)

	assert_eq(loaded.version, "1.0.0", "String version round-trip should be stable")

	DirAccess.remove_absolute(tmp_dir.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp_dir)
