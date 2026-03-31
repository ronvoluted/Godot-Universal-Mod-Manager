extends GutTest
## Verify detection of the disable_project_settings_override setting (GH-108818).
## Godot 4.6+ adds application/config/disable_project_settings_override to
## project.godot, which prevents override.cfg from being loaded at runtime.
## Games that enable this setting are unmoddable via GUMM's injection mechanism.


# -- Detection via project.godot parsing --

func test_detects_override_cfg_disabled_when_setting_is_true() -> void:
	var path := "user://test_disable_override_true"
	DirAccess.make_dir_recursive_absolute(path)

	var config := ConfigFile.new()
	config.set_value("application", "config/disable_project_settings_override", true)
	config.save(path.path_join("project.godot"))

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path.path_join("project.godot")), OK)
	assert_true(
		loaded.get_value("application", "config/disable_project_settings_override", false),
		"should detect override.cfg is disabled when setting is true"
	)

	DirAccess.remove_absolute(path.path_join("project.godot"))
	DirAccess.remove_absolute(path)


func test_override_cfg_not_disabled_when_setting_is_false() -> void:
	var path := "user://test_disable_override_false"
	DirAccess.make_dir_recursive_absolute(path)

	var config := ConfigFile.new()
	config.set_value("application", "config/disable_project_settings_override", false)
	config.save(path.path_join("project.godot"))

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path.path_join("project.godot")), OK)
	assert_false(
		loaded.get_value("application", "config/disable_project_settings_override", false),
		"should not flag override.cfg as disabled when setting is false"
	)

	DirAccess.remove_absolute(path.path_join("project.godot"))
	DirAccess.remove_absolute(path)


func test_override_cfg_not_disabled_when_setting_absent() -> void:
	var path := "user://test_disable_override_absent"
	DirAccess.make_dir_recursive_absolute(path)

	var config := ConfigFile.new()
	config.set_value("application", "run/main_scene", "res://Main.tscn")
	config.save(path.path_join("project.godot"))

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path.path_join("project.godot")), OK)
	assert_false(
		loaded.get_value("application", "config/disable_project_settings_override", false),
		"should default to false when setting is absent from project.godot"
	)

	DirAccess.remove_absolute(path.path_join("project.godot"))
	DirAccess.remove_absolute(path)


func test_override_cfg_not_disabled_when_project_godot_missing() -> void:
	var path := "user://test_disable_override_no_project"
	DirAccess.make_dir_recursive_absolute(path)

	assert_false(
		FileAccess.file_exists(path.path_join("project.godot")),
		"project.godot should not exist for this test"
	)

	# When project.godot is missing, the default should be false (moddable)
	var config := ConfigFile.new()
	var err := config.load(path.path_join("project.godot"))
	assert_ne(err, OK, "loading missing file should fail")

	# The fallback behavior: treat missing project.godot as moddable
	var disabled: bool = false
	if err == OK:
		disabled = config.get_value("application", "config/disable_project_settings_override", false)
	assert_false(disabled, "missing project.godot should not flag override.cfg as disabled")

	DirAccess.remove_absolute(path)


# -- ConfigFile round-trip with other settings --

func test_disable_setting_coexists_with_other_application_settings() -> void:
	var path := "user://test_disable_override_coexist.cfg"

	var config := ConfigFile.new()
	config.set_value("application", "config/name", "Test Game")
	config.set_value("application", "run/main_scene", "res://Main.tscn")
	config.set_value("application", "config/disable_project_settings_override", true)
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("application", "config/name"), "Test Game")
	assert_eq(loaded.get_value("application", "run/main_scene"), "res://Main.tscn")
	assert_true(
		loaded.get_value("application", "config/disable_project_settings_override", false),
		"disable setting should round-trip alongside other application settings"
	)

	DirAccess.remove_absolute(path)


func test_override_cfg_is_independent_from_disable_setting() -> void:
	var game_path := "user://test_disable_override_independent"
	DirAccess.make_dir_recursive_absolute(game_path)

	# Game has disable_project_settings_override = true in project.godot
	var project_cfg := ConfigFile.new()
	project_cfg.set_value("application", "config/disable_project_settings_override", true)
	project_cfg.save(game_path.path_join("project.godot"))

	# override.cfg can still be written (GUMM writes it), but the game won't load it
	var override_cfg := ConfigFile.new()
	override_cfg.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")
	override_cfg.save(game_path.path_join("override.cfg"))

	assert_true(
		FileAccess.file_exists(game_path.path_join("override.cfg")),
		"override.cfg can still be written even when the game disables it"
	)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(game_path.path_join("project.godot")), OK)
	assert_true(
		loaded.get_value("application", "config/disable_project_settings_override", false),
		"the disable setting in project.godot is what prevents the game from reading override.cfg"
	)

	DirAccess.remove_absolute(game_path.path_join("override.cfg"))
	DirAccess.remove_absolute(game_path.path_join("project.godot"))
	DirAccess.remove_absolute(game_path)
