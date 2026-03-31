extends GutTest
## Verify dialogs in Main.tscn and Game.tscn are compatible with the
## PopupMenu/Panel shadow rendering changes (GH-91333).
##
## Godot 4.4 changed how shadows are drawn on popups and panels.
## These tests ensure our dialogs carry no custom shadow overrides that
## could conflict with the new default shadow behaviour, and that every
## dialog relies on standard types whose shadows are engine-managed.


const SHADOW_PROPERTIES: Array[String] = [
	"shadow_color",
	"shadow_size",
	"shadow_offset",
]

var _dialog_scenes: Dictionary = {
	"res://Scenes/Main.tscn": [
		"AddGame",
		"CreateGame",
		"DeleteConfirm",
	],
	"res://Scenes/Game.tscn": [
		"ImportModDialog",
		"NewModDialog",
		"DeleteConfirm",
	],
	"res://Nodes/GameEntry.tscn": [
		"AcceptDialog",
	],
	"res://Nodes/ModEntry.tscn": [
		"AcceptDialog",
	],
}


func test_no_dialog_has_shadow_theme_overrides() -> void:
	for scene_path: String in _dialog_scenes:
		var scene_text := _read_scene_file(scene_path)
		for prop: String in SHADOW_PROPERTIES:
			assert_false(
				scene_text.contains(prop),
				"%s should not contain shadow override '%s' (GH-91333)" % [scene_path, prop]
			)


func test_no_scene_has_custom_popup_stylebox_with_shadow() -> void:
	var scene_paths: Array[String] = [
		"res://Scenes/Main.tscn",
		"res://Scenes/Game.tscn",
	]
	for scene_path: String in scene_paths:
		var scene_text := _read_scene_file(scene_path)
		assert_false(
			scene_text.contains("theme_override_styles/panel"),
			"%s should not override the popup panel style (GH-91333)" % scene_path
		)


func test_dialogs_use_only_standard_dialog_types() -> void:
	var standard_types: Array[String] = [
		"AcceptDialog",
		"ConfirmationDialog",
	]
	for scene_path: String in _dialog_scenes:
		var scene_text := _read_scene_file(scene_path)
		for dialog_name: String in _dialog_scenes[scene_path]:
			var found_standard := false
			for dialog_type: String in standard_types:
				if scene_text.contains("[node name=\"%s\" type=\"%s\"" % [dialog_name, dialog_type]):
					found_standard = true
					break
			assert_true(
				found_standard,
				"%s: dialog '%s' should use a standard dialog type" % [scene_path, dialog_name]
			)


func test_game_scene_stylebox_empty_has_no_shadow_fields() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")
	assert_string_contains(scene_text, "StyleBoxEmpty")
	for prop: String in SHADOW_PROPERTIES:
		var stylebox_section := scene_text.get_slice("StyleBoxEmpty", 1)
		assert_false(
			stylebox_section.contains(prop),
			"Game.tscn StyleBoxEmpty should not contain '%s'" % prop
		)


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
