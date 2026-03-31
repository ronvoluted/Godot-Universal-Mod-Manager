extends GutTest
## Verify ConfigFile.get_sections() and get_section_keys() return
## PackedStringArray directly (GH-105700). The mod manager relies on
## iterating and inspecting these return values in Game.gd and
## AutoExportVersion.gd.

var tmp_dir := "user://test_configfile_return_sections"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(tmp_dir)


func after_each() -> void:
	var dir := DirAccess.open(tmp_dir)
	if dir:
		for file: String in dir.get_files():
			DirAccess.remove_absolute(tmp_dir.path_join(file))
	DirAccess.remove_absolute(tmp_dir)


# -- get_sections() returns PackedStringArray directly --

func test_get_sections_returns_array() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://Main.tscn")
	cfg.set_value("gumm", "main_scene", "res://Scenes/Main.tscn")

	var sections := cfg.get_sections()
	assert_typeof(sections, TYPE_PACKED_STRING_ARRAY, "get_sections() should return PackedStringArray")


func test_get_sections_contains_expected_sections() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("application", "key", "value")
	cfg.set_value("gumm", "key", "value")

	var sections := cfg.get_sections()
	assert_eq(sections.size(), 2)
	assert_true("application" in sections)
	assert_true("gumm" in sections)


func test_get_sections_empty_config() -> void:
	var cfg := ConfigFile.new()
	var sections := cfg.get_sections()
	assert_eq(sections.size(), 0, "Empty config should return empty array")


# -- get_section_keys() returns PackedStringArray directly --

func test_get_section_keys_returns_array() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://Main.tscn")
	cfg.set_value("application", "name", "TestApp")

	var keys := cfg.get_section_keys("application")
	assert_typeof(keys, TYPE_PACKED_STRING_ARRAY, "get_section_keys() should return PackedStringArray")


func test_get_section_keys_contains_expected_keys() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://Main.tscn")
	cfg.set_value("application", "name", "TestApp")

	var keys := cfg.get_section_keys("application")
	assert_eq(keys.size(), 2)
	assert_true("run/main_scene" in keys)
	assert_true("name" in keys)


# -- Return values work with size checks (as used in Game.gd) --

func test_get_sections_size_check() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://GUMM_Loader.tscn")

	var sections := cfg.get_sections()
	assert_eq(sections.size(), 1)
	assert_true(sections.size() == 1 or sections.size() == 2,
		"Size comparison should work on returned array")


func test_get_section_keys_size_check() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://GUMM_Loader.tscn")

	assert_eq(cfg.get_section_keys("application").size(), 1,
		"Chained .size() call on return value should work")


# -- Return values work after save/load roundtrip --

func test_get_sections_after_roundtrip() -> void:
	var path := tmp_dir.path_join("roundtrip.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://GUMM_Loader.tscn")
	cfg.set_value("gumm", "main_scene", "res://Scenes/Main.tscn")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)

	var sections := loaded.get_sections()
	assert_eq(sections.size(), 2)
	assert_true("application" in sections)
	assert_true("gumm" in sections)


func test_get_section_keys_after_roundtrip() -> void:
	var path := tmp_dir.path_join("roundtrip_keys.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("Godot Game", "title", "Test Game")
	cfg.set_value("Godot Game", "godot_version", "4.x")
	cfg.set_value("Godot Game", "main_scene", "res://Main.tscn")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)

	var keys := loaded.get_section_keys("Godot Game")
	assert_eq(keys.size(), 3)
	assert_true("title" in keys)
	assert_true("godot_version" in keys)
	assert_true("main_scene" in keys)


# -- Iteration over return values (as used in AutoExportVersion.gd) --

func test_iterate_sections_directly() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("preset.0", "name", "Linux")
	cfg.set_value("preset.0.options", "version", "1.0")
	cfg.set_value("preset.1", "name", "Windows")
	cfg.set_value("preset.1.options", "version", "1.0")

	var option_sections: PackedStringArray = []
	for section: String in cfg.get_sections():
		if section.ends_with(".options"):
			option_sections.append(section)

	assert_eq(option_sections.size(), 2)


func test_iterate_section_keys_directly() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("preset.0.options", "application/version", "1.0")
	cfg.set_value("preset.0.options", "custom/build", "42")

	var found_keys: PackedStringArray = []
	for key: String in cfg.get_section_keys("preset.0.options"):
		found_keys.append(key)

	assert_eq(found_keys.size(), 2)
	assert_true("application/version" in found_keys)
	assert_true("custom/build" in found_keys)
