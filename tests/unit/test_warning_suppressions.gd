extends GutTest


var _warning_types: Array[String] = [
	"unassigned_variable",
	"unassigned_variable_op_assign",
	"unused_variable",
	"unused_local_constant",
	"unused_private_class_variable",
	"unused_parameter",
	"unused_signal",
	"integer_division",
	"confusable_identifier",
]


func test_no_globally_suppressed_warnings() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")
	assert_eq(err, OK)

	for warning: String in _warning_types:
		var key := "gdscript/warnings/%s" % warning
		if config.has_section_key("debug", key):
			var value: int = config.get_value("debug", key, -1)
			assert_ne(value, 0, "Warning '%s' should not be globally suppressed (=0)" % warning)


func test_directory_rules_only_cover_addons() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")
	assert_eq(err, OK)

	var rules: Dictionary = config.get_value("debug", "gdscript/warnings/directory_rules", {})
	assert_eq(rules.size(), 1, "directory warning overrides should only cover addons/")
	assert_true(rules.has("res://addons/"), "directory_rules should include res://addons/")


func test_addon_directory_rules_suppress_warnings() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")
	assert_eq(err, OK)

	var rules: Variant = config.get_value("debug", "gdscript/warnings/directory_rules", {})
	assert_typeof(rules, TYPE_DICTIONARY)

	var addon_rules: Variant = (rules as Dictionary).get("res://addons/", null)
	assert_not_null(addon_rules, "directory_rules should have entry for res://addons/")

	for warning: String in _warning_types:
		var level: Variant = (addon_rules as Dictionary).get(warning, null)
		assert_eq(level, 0, "Warning '%s' should be suppressed in addons via directory_rules" % warning)


func test_game_script_variables_are_explicitly_initialized() -> void:
	var script := load("res://Scenes/Game.gd") as GDScript
	assert_not_null(script)

	var source: String = script.source_code
	# The old patterns "var new_missing: bool\n" and "var deleted: bool\n"
	# and "var has: int\n" should no longer appear without initialization
	var lines: PackedStringArray = source.split("\n")
	for line: String in lines:
		var stripped := line.strip_edges()
		if stripped.begins_with("var ") and not stripped.begins_with("var _"):
			# Local variables (inside functions) that declare a type but no assignment
			# should use := initialization, not bare type declarations
			if ":" in stripped and ":=" not in stripped and "=" not in stripped.split(":")[1]:
				# This is a bare "var x: Type" with no default — only allowed for class-level vars
				# In this test we only flag known-problematic patterns
				assert_false(
					stripped in ["var new_missing: bool", "var deleted: bool", "var has: int"],
					"Variable should be explicitly initialized: %s" % stripped
				)
