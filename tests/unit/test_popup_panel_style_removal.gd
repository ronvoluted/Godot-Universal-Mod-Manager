extends GutTest
## Verify dialog theming in Main.tscn and Game.tscn is unaffected by
## popup "panel" style removal (GH-90633).
##
## Godot removed the implicit "panel" theme_type_variation from popups.
## These tests ensure our dialogs never relied on it and that existing
## theme overrides remain intact.


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


func test_no_dialog_uses_panel_theme_type_variation() -> void:
	for scene_path: String in _dialog_scenes:
		var scene_text := _read_scene_file(scene_path)
		assert_false(
			scene_text.contains("theme_type_variation") and scene_text.contains("panel"),
			"%s should not use deprecated 'panel' theme_type_variation" % scene_path
		)


func test_main_scene_dialogs_are_correct_types() -> void:
	var scene_text := _read_scene_file("res://Scenes/Main.tscn")
	assert_string_contains(scene_text, "[node name=\"AddGame\" type=\"AcceptDialog\"")
	assert_string_contains(scene_text, "[node name=\"CreateGame\" type=\"AcceptDialog\"")
	assert_string_contains(scene_text, "[node name=\"DeleteConfirm\" type=\"ConfirmationDialog\"")


func test_game_scene_dialogs_are_correct_types() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")
	assert_string_contains(scene_text, "[node name=\"ImportModDialog\" type=\"ConfirmationDialog\"")
	assert_string_contains(scene_text, "[node name=\"NewModDialog\" type=\"ConfirmationDialog\"")
	assert_string_contains(scene_text, "[node name=\"DeleteConfirm\" type=\"ConfirmationDialog\"")


func test_main_scene_error_labels_preserve_red_font_color() -> void:
	var scene_text := _read_scene_file("res://Scenes/Main.tscn")
	var error_label_count := scene_text.count("theme_override_colors/font_color = Color(1, 0, 0, 1)")
	assert_eq(error_label_count, 2, "Main.tscn should have 2 red error labels (AddError, CreateError)")


func test_game_scene_error_labels_preserve_red_font_color() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")
	var error_label_count := scene_text.count("theme_override_colors/font_color = Color(1, 0, 0, 1)")
	assert_eq(error_label_count, 2, "Game.tscn should have 2 red error labels (ImportError, NewModError)")


func test_game_scene_grid_containers_preserve_h_separation() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")
	var sep_count := scene_text.count("theme_override_constants/h_separation = 30")
	assert_eq(sep_count, 2, "Game.tscn should have 2 GridContainers with h_separation = 30")


func test_game_scene_text_edit_preserves_empty_stylebox() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")
	assert_string_contains(scene_text, "StyleBoxEmpty")
	assert_string_contains(scene_text, "theme_override_styles/normal")


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
