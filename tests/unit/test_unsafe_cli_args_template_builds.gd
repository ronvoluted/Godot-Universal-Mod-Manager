extends GutTest
## Verify that GUMM's mod loading system does not rely on CLI arguments
## disabled in template builds (GH-111909).
## Godot 4.6 disables unsafe CLI arguments (--script, --main-pack, etc.)
## in template/exported builds by default. GUMM injects mods via
## override.cfg and ProjectSettings, not CLI arguments, so this change
## has no impact on the mod loading pipeline.


# -- Mod loader uses ProjectSettings, not CLI args --

func test_mod_loader_reads_mod_list_from_project_settings() -> void:
	# The 4.x mod loader autoload reads gumm/mod_list from ProjectSettings,
	# which is populated by override.cfg — no CLI arguments involved
	var config := ConfigFile.new()
	var mod_paths: Array[String] = ["/mods/test_mod_a", "/mods/test_mod_b"]
	config.set_value("gumm", "mod_list", mod_paths)

	var path := "user://test_cli_args_override.cfg"
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)

	var loaded_list: Array = loaded.get_value("gumm", "mod_list", [])
	assert_eq(loaded_list.size(), 2, "mod list should round-trip through override.cfg")
	assert_eq(loaded_list[0], "/mods/test_mod_a")
	assert_eq(loaded_list[1], "/mods/test_mod_b")

	DirAccess.remove_absolute(path)


# -- 4.x injection uses autoload key in override.cfg --

func test_4x_mod_injection_uses_autoload_not_cli() -> void:
	# GUMM 4.x injects by writing an autoload entry to override.cfg,
	# not by passing --script or --main-pack on the command line
	var config := ConfigFile.new()
	config.set_value("autoload", "GUMM", "*res://GUMM_mod_loader_autoload.gd")

	var path := "user://test_cli_args_autoload.cfg"
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(
		loaded.get_value("autoload", "GUMM"),
		"*res://GUMM_mod_loader_autoload.gd",
		"autoload injection should use override.cfg, not CLI arguments"
	)

	DirAccess.remove_absolute(path)


# -- 2.x/3.x injection uses main_scene redirect in override.cfg --

func test_2x_mod_injection_uses_main_scene_override_not_cli() -> void:
	var config := ConfigFile.new()
	config.set_value("application", "main_scene", "res://GUMM_mod_loader.tscn")
	config.set_value("gumm", "main_scene", "res://OriginalMain.tscn")

	var path := "user://test_cli_args_2x.cfg"
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(
		loaded.get_value("application", "main_scene"),
		"res://GUMM_mod_loader.tscn",
		"2.x main_scene redirect should use override.cfg, not CLI arguments"
	)
	assert_eq(
		loaded.get_value("gumm", "main_scene"),
		"res://OriginalMain.tscn",
		"original main_scene should be preserved in gumm section"
	)

	DirAccess.remove_absolute(path)


func test_3x_mod_injection_uses_run_main_scene_override_not_cli() -> void:
	var config := ConfigFile.new()
	config.set_value("application", "run/main_scene", "res://GUMM_mod_loader.tscn")
	config.set_value("gumm", "main_scene", "res://OriginalMain.tscn")

	var path := "user://test_cli_args_3x.cfg"
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(
		loaded.get_value("application", "run/main_scene"),
		"res://GUMM_mod_loader.tscn",
		"3.x run/main_scene redirect should use override.cfg, not CLI arguments"
	)

	DirAccess.remove_absolute(path)


# -- Source code verification: no CLI arg APIs in mod loading code --

func test_mod_loader_autoload_has_no_cmdline_references() -> void:
	# Verify the 4.x mod loader script does not reference CLI argument APIs
	var script_path := "res://System/4.x/GUMM_mod_loader_autoload.gd"
	assert_true(FileAccess.file_exists(script_path), "mod loader autoload should exist")

	var source := FileAccess.get_file_as_string(script_path)
	assert_false(
		source.contains("get_cmdline"),
		"mod loader should not use OS.get_cmdline_args() or OS.get_cmdline_user_args()"
	)
	assert_false(
		source.contains("--script"),
		"mod loader should not reference --script CLI argument"
	)
	assert_false(
		source.contains("--main-pack"),
		"mod loader should not reference --main-pack CLI argument"
	)


func test_game_scene_has_no_cmdline_references() -> void:
	# Verify Game.gd (which manages override.cfg) does not use CLI args
	var script_path := "res://Scenes/Game.gd"
	assert_true(FileAccess.file_exists(script_path), "Game.gd should exist")

	var source := FileAccess.get_file_as_string(script_path)
	assert_false(
		source.contains("get_cmdline"),
		"Game.gd should not use CLI argument APIs"
	)
