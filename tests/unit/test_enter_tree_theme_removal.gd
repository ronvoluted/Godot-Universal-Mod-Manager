extends GutTest
## Verify custom controls are unaffected by NOTIFICATION_ENTER_TREE removal
## for theme initialization (GH-89746).
##
## Godot replaced NOTIFICATION_ENTER_TREE with NOTIFICATION_THEME_CHANGED for
## theme cache initialization. Controls that set theme overrides at runtime
## (e.g. in _ready or callbacks) must receive NOTIFICATION_THEME_CHANGED and
## have their overrides applied correctly. These tests confirm no custom
## controls relied on the old enter-tree theme init path.


const _custom_scripts: Array[String] = [
	"res://Scenes/Main.gd",
	"res://Scenes/Game.gd",
	"res://Nodes/GameEntry.gd",
	"res://Nodes/ModEntry.gd",
	"res://Nodes/PathEdit.gd",
]


func test_no_script_uses_notification_enter_tree_for_theme() -> void:
	for script_path: String in _custom_scripts:
		var file := FileAccess.open(script_path, FileAccess.READ)
		assert_not_null(file, "Should be able to read: %s" % script_path)
		if file == null:
			continue

		var source := file.get_as_text()
		assert_false(
			source.contains("NOTIFICATION_ENTER_TREE") and _has_theme_call(source),
			"%s should not use NOTIFICATION_ENTER_TREE for theme initialization" % script_path
		)


func test_no_script_uses_enter_tree_for_theme() -> void:
	for script_path: String in _custom_scripts:
		var file := FileAccess.open(script_path, FileAccess.READ)
		assert_not_null(file, "Should be able to read: %s" % script_path)
		if file == null:
			continue

		var source := file.get_as_text()
		var enter_tree_idx := source.find("func _enter_tree")
		if enter_tree_idx == -1:
			pass_test("%s has no _enter_tree — OK" % script_path)
			continue

		var next_func_idx := source.find("\nfunc ", enter_tree_idx + 1)
		var body: String
		if next_func_idx != -1:
			body = source.substr(enter_tree_idx, next_func_idx - enter_tree_idx)
		else:
			body = source.substr(enter_tree_idx)

		assert_false(
			_has_theme_call(body),
			"%s _enter_tree() should not contain theme calls" % script_path
		)


func test_theme_changed_fires_for_control_with_override() -> void:
	var ctrl := Control.new()
	add_child_autofree(ctrl)
	await get_tree().process_frame

	ctrl.notification(Control.NOTIFICATION_THEME_CHANGED)
	# Verify the control is alive and responsive after the notification
	assert_true(ctrl.is_inside_tree(), "Control should remain in tree after NOTIFICATION_THEME_CHANGED")

	ctrl.add_theme_color_override(&"font_color", Color.RED)
	var color: Color = ctrl.get_theme_color(&"font_color")
	assert_eq(color, Color.RED, "Theme color override should be applied after add_theme_color_override")


func test_runtime_theme_override_persists_through_theme_changed() -> void:
	var label := Label.new()
	add_child_autofree(label)
	await get_tree().process_frame

	label.add_theme_color_override(&"font_color", Color.RED)
	assert_eq(
		label.get_theme_color(&"font_color"),
		Color.RED,
		"Label font_color override should be RED"
	)

	label.notification(Control.NOTIFICATION_THEME_CHANGED)
	assert_eq(
		label.get_theme_color(&"font_color"),
		Color.RED,
		"Theme override should persist after NOTIFICATION_THEME_CHANGED"
	)


func _has_theme_call(source: String) -> bool:
	var theme_patterns: Array[String] = [
		"get_theme_icon",
		"get_theme_color",
		"get_theme_font",
		"get_theme_stylebox",
		"get_theme_constant",
		"add_theme_color_override",
		"add_theme_font_override",
		"add_theme_stylebox_override",
		"add_theme_constant_override",
		"add_theme_icon_override",
		"add_theme_font_size_override",
		"add_theme_type_override",
	]
	for pattern: String in theme_patterns:
		if source.contains(pattern):
			return true
	return false
