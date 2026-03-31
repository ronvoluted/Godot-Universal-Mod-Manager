extends GutTest
## Verify FileDialog usage is unaffected by Tree → ItemList overhaul (GH-105641).
## All project FileDialogs use native OS dialogs and only access the public API,
## so the internal widget change should have no impact.


var _scene_paths: Array[String] = [
	"res://Nodes/PathEdit.tscn",
	"res://Nodes/GameEntry.tscn",
	"res://Nodes/ModEntry.tscn",
]


func test_no_file_dialog_accesses_internal_tree_node() -> void:
	for scene_path: String in _scene_paths:
		var scene: PackedScene = load(scene_path)
		var instance: Node = scene.instantiate()
		add_child_autofree(instance)

		var file_dialog: FileDialog = instance.find_child("FileDialog", true, false)
		assert_not_null(file_dialog, "%s should contain a FileDialog" % scene_path)
		if file_dialog == null:
			continue

		# The overhaul replaced the internal Tree with an ItemList.
		# Verify no child named "Tree" exists — accessing it would break.
		var tree_child: Node = file_dialog.find_child("Tree", true, false)
		assert_null(
			tree_child,
			"%s FileDialog should not have an internal Tree child (removed in GH-105641)" % scene_path
		)


func test_all_file_dialogs_use_native_bypassing_internal_widgets() -> void:
	for scene_path: String in _scene_paths:
		var scene: PackedScene = load(scene_path)
		var instance: Node = scene.instantiate()
		add_child_autofree(instance)

		var file_dialog: FileDialog = instance.find_child("FileDialog", true, false)
		assert_not_null(file_dialog, "%s should contain a FileDialog" % scene_path)
		if file_dialog == null:
			continue

		assert_true(
			file_dialog.use_native_dialog,
			"%s FileDialog must use native dialog to bypass internal widget changes" % scene_path
		)


func test_path_edit_folder_mode_public_api_intact() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")

	# Verify public API properties used by PathEdit are accessible
	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_DIR,
		"Folder mode should set FILE_MODE_OPEN_DIR via public API")
	assert_eq(file_dialog.access, FileDialog.ACCESS_FILESYSTEM,
		"Should use filesystem access via public API")
	assert_true(file_dialog.dir_selected.is_connected(path_edit.dialog_select),
		"dir_selected signal should be connected")


func test_path_edit_file_mode_public_api_intact() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")

	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_FILE,
		"File mode should set FILE_MODE_OPEN_FILE via public API")
	assert_true(file_dialog.file_selected.is_connected(path_edit.dialog_select),
		"file_selected signal should be connected")
	assert_gt(file_dialog.filters.size(), 0,
		"File mode should set filters via public API")


func test_path_edit_popup_method_exists() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	add_child_autofree(path_edit)

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")

	# popup_centered_ratio is the public API used by browse() — verify it exists
	assert_true(file_dialog.has_method("popup_centered_ratio"),
		"FileDialog should still expose popup_centered_ratio after overhaul")


func test_game_entry_dir_selected_signal_connected() -> void:
	var scene_text := FileAccess.open("res://Nodes/GameEntry.tscn", FileAccess.READ).get_as_text()
	assert_string_contains(scene_text, "dir_selected",
		"GameEntry FileDialog should use dir_selected signal (public API)")


func test_mod_entry_dir_selected_signal_connected() -> void:
	var scene_text := FileAccess.open("res://Nodes/ModEntry.tscn", FileAccess.READ).get_as_text()
	assert_string_contains(scene_text, "dir_selected",
		"ModEntry FileDialog should use dir_selected signal (public API)")


func test_no_script_references_file_dialog_internals() -> void:
	var script_paths: Array[String] = [
		"res://Nodes/PathEdit.gd",
		"res://Nodes/GameEntry.gd",
		"res://Nodes/ModEntry.gd",
	]

	# These patterns would indicate dependency on FileDialog internals
	var forbidden_patterns: Array[String] = [
		"get_vbox",       # Accessing internal VBox layout
		"ItemList",       # Directly referencing the new internal widget
		"Tree",           # Directly referencing the old internal widget
	]

	for script_path: String in script_paths:
		var file := FileAccess.open(script_path, FileAccess.READ)
		assert_not_null(file, "Should be able to read %s" % script_path)
		if file == null:
			continue

		var source := file.get_as_text()
		for pattern: String in forbidden_patterns:
			# Check for FileDialog-specific internal access patterns
			var context := "file_dialog.%s" % pattern.to_lower()
			var context2 := "FileDialog.%s" % pattern
			assert_false(
				source.contains(context) or source.contains(context2),
				"%s should not reference FileDialog internal '%s'" % [script_path, pattern]
			)
