extends GutTest


func test_untyped_declaration_warning_is_enabled() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")

	assert_eq(err, OK)
	var warning_level: int = config.get_value("debug", "gdscript/warnings/untyped_declaration", 0)
	assert_gt(warning_level, 0, "untyped_declaration warning should be enabled (warn or error)")


func test_untyped_declaration_warning_level_is_warn() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")

	assert_eq(err, OK)
	var warning_level: int = config.get_value("debug", "gdscript/warnings/untyped_declaration", 0)
	assert_eq(warning_level, 1, "untyped_declaration warning should be set to WARN (1)")


func test_core_scripts_have_typed_functions() -> void:
	# Verify key project scripts parse without untyped declarations
	# by checking that all public functions have return type annotations
	var scripts: Array[String] = [
		"res://Data/Registry.gd",
		"res://Data/GameDescriptor.gd",
		"res://Data/ModDescriptor.gd",
	]

	for script_path: String in scripts:
		var script := load(script_path) as GDScript
		assert_not_null(script, "Script should load: %s" % script_path)

		var source: String = script.source_code
		var lines: PackedStringArray = source.split("\n")
		for line: String in lines:
			var stripped := line.strip_edges()
			if stripped.begins_with("func ") and stripped.ends_with(":"):
				assert_true(
					"->" in stripped,
					"Function should have return type annotation in %s: %s" % [script_path, stripped]
				)


func test_ui_scripts_have_typed_functions() -> void:
	var scripts: Array[String] = [
		"res://Scenes/Main.gd",
		"res://Scenes/Game.gd",
		"res://Nodes/GameEntry.gd",
		"res://Nodes/ModEntry.gd",
		"res://Nodes/PathEdit.gd",
	]

	for script_path: String in scripts:
		var script := load(script_path) as GDScript
		assert_not_null(script, "Script should load: %s" % script_path)

		var source: String = script.source_code
		var lines: PackedStringArray = source.split("\n")
		for line: String in lines:
			var stripped := line.strip_edges()
			if stripped.begins_with("func ") and stripped.ends_with(":"):
				assert_true(
					"->" in stripped,
					"Function should have return type annotation in %s: %s" % [script_path, stripped]
				)
