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
	var scripts: Array[String] = [
		"res://Data/Registry.gd",
		"res://Data/GameDescriptor.gd",
		"res://Data/ModDescriptor.gd",
	]
	_assert_functions_have_return_types(scripts)


func test_ui_scripts_have_typed_functions() -> void:
	var scripts: Array[String] = [
		"res://Scenes/Main.gd",
		"res://Scenes/Game.gd",
		"res://Nodes/GameEntry.gd",
		"res://Nodes/ModEntry.gd",
		"res://Nodes/PathEdit.gd",
	]
	_assert_functions_have_return_types(scripts)


func test_system_4x_scripts_have_typed_functions() -> void:
	var scripts: Array[String] = [
		"res://System/4.x/GUMM_mod.gd",
		"res://System/4.x/GUMM_mod_loader_autoload.gd",
		"res://System/4.x/mod.gd",
	]
	_assert_functions_have_return_types(scripts)


func test_core_scripts_have_typed_parameters() -> void:
	var scripts: Array[String] = [
		"res://Data/Registry.gd",
		"res://Data/GameDescriptor.gd",
		"res://Data/ModDescriptor.gd",
		"res://Data/Descriptor.gd",
		"res://Scenes/Main.gd",
		"res://Scenes/Game.gd",
		"res://Nodes/GameEntry.gd",
		"res://Nodes/ModEntry.gd",
		"res://Nodes/PathEdit.gd",
		"res://System/4.x/GUMM_mod.gd",
		"res://System/4.x/GUMM_mod_loader_autoload.gd",
	]

	for script_path: String in scripts:
		var script := load(script_path) as GDScript
		assert_not_null(script, "Script should load: %s" % script_path)

		var source: String = script.source_code
		var lines: PackedStringArray = source.split("\n")
		for line: String in lines:
			var stripped := line.strip_edges()
			if not stripped.begins_with("func ") or not stripped.ends_with(":"):
				continue
			# Extract parameter list between first ( and last )
			var paren_open := stripped.find("(")
			var paren_close := stripped.rfind(")")
			if paren_open == -1 or paren_close == -1:
				continue
			var params_str := stripped.substr(paren_open + 1, paren_close - paren_open - 1).strip_edges()
			if params_str.is_empty():
				continue
			# Split params respecting brackets (e.g. Dictionary[K, V] has commas inside)
			var params := _split_params(params_str)
			for param: String in params:
				param = param.strip_edges()
				if param.is_empty():
					continue
				# Parameters should have : for type annotation or := for inferred type
				assert_true(
					":" in param,
					"Parameter should have type annotation in %s: %s (param: %s)" % [script_path, stripped, param]
				)


func test_directory_rules_suppress_legacy_scripts() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")
	assert_eq(err, OK)

	var rules: Dictionary = config.get_value("debug", "gdscript/warnings/directory_rules", {})
	assert_true(rules.has("res://System/2.x/"), "Should suppress warnings for System/2.x/")
	assert_true(rules.has("res://System/3.x/"), "Should suppress warnings for System/3.x/")
	assert_true(rules.has("res://Examples/"), "Should suppress warnings for Examples/")


func _split_params(params_str: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var depth: int = 0
	var current := ""
	for i: int in params_str.length():
		var ch := params_str[i]
		if ch == "[":
			depth += 1
			current += ch
		elif ch == "]":
			depth -= 1
			current += ch
		elif ch == "," and depth == 0:
			result.append(current)
			current = ""
		else:
			current += ch
	if not current.strip_edges().is_empty():
		result.append(current)
	return result


func _assert_functions_have_return_types(scripts: Array[String]) -> void:
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
