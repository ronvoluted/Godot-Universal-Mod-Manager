extends GutTest


func test_directory_rules_suppress_warnings_in_addons() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")

	assert_eq(err, OK)
	var rules: Dictionary = config.get_value("debug", "gdscript/warnings/directory_rules")
	assert_true(rules.has("res://addons/"), "directory_rules should include res://addons/")
	var addons_rules: Dictionary = rules["res://addons/"]
	assert_eq(addons_rules["untyped_declaration"], 0,
		"addons/ should suppress untyped_declaration warnings")


func test_project_code_retains_strict_warnings() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")

	assert_eq(err, OK)
	var untyped_decl: int = config.get_value("debug", "gdscript/warnings/untyped_declaration")
	assert_eq(untyped_decl, 1,
		"project-wide untyped_declaration should remain enabled")


func test_directory_rules_override_expected_dirs() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")

	assert_eq(err, OK)
	var rules: Dictionary = config.get_value("debug", "gdscript/warnings/directory_rules")
	# Only addons/ needs warning rules — System/2.x/, System/3.x/, and Examples/
	# are excluded via .gdignore (editor never parses them).
	var expected: Array[String] = ["res://addons/"]
	assert_eq(rules.size(), expected.size(), "directory warning overrides should only cover addons/")
	for dir: String in expected:
		assert_true(rules.has(dir), "directory_rules should include %s" % dir)
