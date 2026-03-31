extends GutTest


func test_project_targets_godot_4_6() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")

	assert_eq(err, OK)
	var features: PackedStringArray = config.get_value("application", "config/features")
	assert_true(features.has("4.6"), "project.godot should target Godot 4.6")
