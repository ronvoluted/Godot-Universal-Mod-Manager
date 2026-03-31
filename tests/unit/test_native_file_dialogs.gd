extends GutTest


var _scene_paths: Array[String] = [
	"res://Nodes/PathEdit.tscn",
	"res://Nodes/GameEntry.tscn",
	"res://Nodes/ModEntry.tscn",
]


func test_all_file_dialogs_use_native_dialog() -> void:
	for scene_path: String in _scene_paths:
		var scene_text := _read_scene_file(scene_path)
		assert_string_contains(
			scene_text,
			"use_native_dialog = true",
			"FileDialog in %s should have use_native_dialog enabled" % scene_path
		)


func test_all_file_dialogs_use_filesystem_access() -> void:
	for scene_path: String in _scene_paths:
		var scene_text := _read_scene_file(scene_path)
		assert_string_contains(
			scene_text,
			"access = 2",
			"FileDialog in %s should use filesystem access (2)" % scene_path
		)


func test_all_file_dialogs_default_to_directory_mode() -> void:
	for scene_path: String in _scene_paths:
		var scene_text := _read_scene_file(scene_path)
		assert_string_contains(
			scene_text,
			"file_mode = 2",
			"FileDialog in %s should default to FILE_MODE_OPEN_DIR (2)" % scene_path
		)


func test_path_edit_instantiates_with_native_dialog() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	add_child_autofree(path_edit)

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_not_null(file_dialog, "PathEdit should have a FileDialog child")
	assert_true(file_dialog.use_native_dialog, "PathEdit FileDialog should use native dialog")
	assert_eq(file_dialog.access, FileDialog.ACCESS_FILESYSTEM, "PathEdit FileDialog should use filesystem access")


func test_path_edit_folder_mode_uses_dir_selected() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_DIR, "Folder mode should use FILE_MODE_OPEN_DIR")
	assert_true(file_dialog.dir_selected.is_connected(path_edit.dialog_select), "dir_selected should be connected in folder mode")


func test_path_edit_file_mode_uses_file_selected() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_FILE, "File mode should use FILE_MODE_OPEN_FILE")
	assert_true(file_dialog.file_selected.is_connected(path_edit.dialog_select), "file_selected should be connected in file mode")


func test_path_edit_file_mode_has_icon_filters() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_gt(file_dialog.filters.size(), 0, "File mode should have icon format filters")


func test_path_edit_dialog_select_updates_text() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	watch_signals(path_edit)
	path_edit.dialog_select("/tmp/test_path")

	assert_eq(path_edit.text, "/tmp/test_path", "dialog_select should update the text")
	assert_signal_emitted(path_edit, "text_changed", "dialog_select should emit text_changed")


func test_game_entry_file_dialog_has_native_dialog() -> void:
	var scene: PackedScene = load("res://Nodes/GameEntry.tscn")
	var state: SceneState = scene.get_state()

	var found_native := false
	for i: int in state.get_node_count():
		if state.get_node_name(i) == &"FileDialog":
			for j: int in state.get_node_property_count(i):
				if state.get_node_property_name(i, j) == &"use_native_dialog":
					found_native = state.get_node_property_value(i, j) as bool
			break

	assert_true(found_native, "GameEntry FileDialog should have use_native_dialog = true")


func test_mod_entry_file_dialog_has_native_dialog() -> void:
	var scene: PackedScene = load("res://Nodes/ModEntry.tscn")
	var state: SceneState = scene.get_state()

	var found_native := false
	for i: int in state.get_node_count():
		if state.get_node_name(i) == &"FileDialog":
			for j: int in state.get_node_property_count(i):
				if state.get_node_property_name(i, j) == &"use_native_dialog":
					found_native = state.get_node_property_value(i, j) as bool
			break

	assert_true(found_native, "ModEntry FileDialog should have use_native_dialog = true")


func _read_scene_file(scene_path: String) -> String:
	var global_path := ProjectSettings.globalize_path(scene_path)
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
