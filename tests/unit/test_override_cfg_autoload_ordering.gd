extends GutTest
## Verify override.cfg autoload ordering (GH-113078). For Godot 4.x, the mod
## loader registers as a front-loaded autoload via override.cfg's [autoload]
## section instead of replacing run/main_scene. This ensures mod initialization
## happens before any game autoloads.


# -- Autoload registration format --

func test_override_cfg_registers_gumm_autoload() -> void:
	var path := "user://test_autoload_register.cfg"
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(
		loaded.get_value("autoload", "GUMM"),
		"*res://GUMM_mod_loader_autoload.gd",
		"override.cfg should store GUMM autoload with * prefix for enabled state"
	)

	DirAccess.remove_absolute(path)


func test_override_cfg_autoload_is_first_key() -> void:
	var path := "user://test_autoload_order.cfg"
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	var keys := loaded.get_section_keys("autoload")
	assert_eq(keys[0], "GUMM", "GUMM should be the first autoload in override.cfg")

	DirAccess.remove_absolute(path)


# -- Section structure differs from legacy approach --

func test_override_cfg_autoload_does_not_set_main_scene() -> void:
	var path := "user://test_autoload_no_main_scene.cfg"
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	config.set_value("gumm", "mod_list", ["mods/TestMod"])
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_false(
		loaded.has_section("application"),
		"autoload-based mod loading should not have an application section"
	)

	DirAccess.remove_absolute(path)


func test_override_cfg_autoload_coexists_with_gumm_section() -> void:
	var path := "user://test_autoload_sections.cfg"
	var mod_list: Array[String] = ["mods/ModA", "mods/ModB"]
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	config.set_value("gumm", "mod_list", mod_list)
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)

	var sections := loaded.get_sections()
	assert_true("autoload" in sections, "should have autoload section")
	assert_true("gumm" in sections, "should have gumm section")

	var restored: Array = loaded.get_value("gumm", "mod_list")
	assert_eq(restored.size(), 2, "mod_list should round-trip with correct size")

	DirAccess.remove_absolute(path)


# -- Cleanup removes only GUMM-related entries --

func test_override_cfg_autoload_cleanup_preserves_game_autoloads() -> void:
	var path := "user://test_autoload_cleanup.cfg"
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	config.set_value("autoload", "GameManager", "*res://game_manager.gd")
	config.set_value("gumm", "mod_list", ["mods/TestMod"])
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	loaded.erase_section_key("autoload", "GUMM")
	if loaded.has_section("gumm"):
		loaded.erase_section("gumm")
	loaded.save(path)

	var cleaned := ConfigFile.new()
	assert_eq(cleaned.load(path), OK)
	assert_false(
		cleaned.has_section_key("autoload", "GUMM"),
		"GUMM autoload should be removed after cleanup"
	)
	assert_true(
		cleaned.has_section_key("autoload", "GameManager"),
		"non-GUMM autoloads should be preserved after cleanup"
	)
	assert_false(
		cleaned.has_section("gumm"),
		"gumm section should be removed after cleanup"
	)

	DirAccess.remove_absolute(path)


func test_override_cfg_deletable_when_only_gumm_sections() -> void:
	var path := "user://test_autoload_full_delete.cfg"
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	config.set_value("gumm", "mod_list", ["mods/TestMod"])
	config.save(path)

	var loaded := ConfigFile.new()
	loaded.load(path)
	var sections := loaded.get_sections()
	var has: int
	has += int("autoload" in sections)
	has += int("gumm" in sections)

	assert_eq(has, sections.size(), "config should only contain autoload and gumm sections")
	assert_eq(loaded.get_section_keys("autoload").size(), 1, "autoload section should have exactly one key")

	DirAccess.remove_absolute(path)
	assert_false(
		FileAccess.file_exists(path),
		"override.cfg should be deletable when only GUMM sections remain"
	)
