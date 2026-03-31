extends GutTest
## Verify that native file dialogs respect `set_visible(false)` (GH-92943).
##
## Before this Godot fix, calling `set_visible(false)` on a FileDialog with
## `use_native_dialog = true` would paradoxically show the dialog instead of
## hiding it. These tests confirm PathEdit and scene FileDialogs are not
## affected by this regression.


var _scene_paths: Array[String] = [
	"res://Nodes/PathEdit.tscn",
	"res://Nodes/GameEntry.tscn",
	"res://Nodes/ModEntry.tscn",
]


func test_native_file_dialog_stays_hidden_after_set_visible_false() -> void:
	var dialog := FileDialog.new()
	dialog.use_native_dialog = true
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	add_child_autofree(dialog)

	dialog.visible = false

	assert_false(dialog.visible, "Native FileDialog should remain hidden after set_visible(false)")


func test_path_edit_dialog_stays_hidden_after_set_visible_false() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_true(file_dialog.use_native_dialog, "PathEdit FileDialog should use native dialog")

	file_dialog.visible = false

	assert_false(file_dialog.visible, "PathEdit FileDialog should stay hidden after set_visible(false)")


func test_path_edit_dialog_hidden_by_default() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_false(file_dialog.visible, "PathEdit FileDialog should be hidden by default")


func test_scene_file_dialogs_hidden_after_set_visible_false() -> void:
	for scene_path: String in _scene_paths:
		var scene: PackedScene = load(scene_path)
		var instance: Node = scene.instantiate()
		add_child_autofree(instance)
		await get_tree().process_frame

		var file_dialog: FileDialog = instance.get_node("FileDialog")
		assert_not_null(file_dialog, "Scene %s should have a FileDialog" % scene_path)

		file_dialog.visible = false
		assert_false(
			file_dialog.visible,
			"FileDialog in %s should stay hidden after set_visible(false)" % scene_path
		)


func test_path_edit_dialog_has_exclusive_false() -> void:
	var scene_text := _read_scene_file("res://Nodes/PathEdit.tscn")
	assert_string_contains(
		scene_text,
		"exclusive = false",
		"PathEdit FileDialog should have exclusive = false to avoid blocking on visibility bugs"
	)


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
