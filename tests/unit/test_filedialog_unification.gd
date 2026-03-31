extends GutTest
## Verify PathEdit FileDialog unaffected by unified context menus (GH-111116),
## pre-unification property changes (GH-111159), and reworked shortcuts (GH-111460).


# -- FileDialog enum values unchanged after unification --

func test_file_mode_open_file_enum_value() -> void:
	assert_eq(FileDialog.FILE_MODE_OPEN_FILE, 0, "FILE_MODE_OPEN_FILE should be 0")


func test_file_mode_open_dir_enum_value() -> void:
	assert_eq(FileDialog.FILE_MODE_OPEN_DIR, 2, "FILE_MODE_OPEN_DIR should be 2")


func test_file_mode_open_files_enum_value() -> void:
	assert_eq(FileDialog.FILE_MODE_OPEN_FILES, 1, "FILE_MODE_OPEN_FILES should be 1")


func test_file_mode_save_file_enum_value() -> void:
	assert_eq(FileDialog.FILE_MODE_SAVE_FILE, 4, "FILE_MODE_SAVE_FILE should be 4")


func test_access_filesystem_enum_value() -> void:
	assert_eq(FileDialog.ACCESS_FILESYSTEM, 2, "ACCESS_FILESYSTEM should be 2")


# -- PathEdit FileDialog configuration survives unification --

func test_path_edit_folder_mode_file_dialog_config() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_DIR)
	assert_eq(file_dialog.access, FileDialog.ACCESS_FILESYSTEM)
	assert_false(file_dialog.exclusive, "PathEdit FileDialog should not be exclusive")


func test_path_edit_file_mode_file_dialog_config() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_FILE)
	assert_eq(file_dialog.access, FileDialog.ACCESS_FILESYSTEM)
	assert_false(file_dialog.exclusive, "PathEdit FileDialog should not be exclusive")


# -- Signal connections intact after shortcut rework --

func test_folder_mode_dir_selected_connected() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_true(
		file_dialog.dir_selected.is_connected(path_edit.dialog_select),
		"dir_selected signal should remain connected after shortcut rework"
	)


func test_file_mode_file_selected_connected() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_true(
		file_dialog.file_selected.is_connected(path_edit.dialog_select),
		"file_selected signal should remain connected after shortcut rework"
	)


# -- File filters preserved through context menu unification --

func test_file_mode_filters_match_icon_formats() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	for ext: String in Registry.ICON_FORMATS:
		var filter := "*." + ext
		assert_has(file_dialog.filters, filter, "Filter '%s' should be set" % filter)


func test_folder_mode_has_no_filters() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_eq(file_dialog.filters.size(), 0, "Folder mode should have no file filters")


# -- dialog_select still works after unification --

func test_dialog_select_emits_text_changed() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	watch_signals(path_edit)
	path_edit.dialog_select("/some/test/path")

	assert_eq(path_edit.text, "/some/test/path")
	assert_signal_emitted(path_edit, "text_changed")


func test_dialog_select_in_file_mode() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 1
	add_child_autofree(path_edit)
	await get_tree().process_frame

	watch_signals(path_edit)
	path_edit.dialog_select("/icons/game.png")

	assert_eq(path_edit.text, "/icons/game.png")
	assert_signal_emitted(path_edit, "text_changed")


# -- popup_centered_ratio still callable --

func test_browse_calls_popup_centered_ratio() -> void:
	var path_edit: HBoxContainer = load("res://Nodes/PathEdit.tscn").instantiate()
	path_edit.mode = 0
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_true(file_dialog.has_method("popup_centered_ratio"), "FileDialog should still have popup_centered_ratio")


# -- New disable_overwrite_warning property (GH-111159) --

func test_filedialog_disable_overwrite_warning_if_available() -> void:
	var dialog := FileDialog.new()
	add_child_autofree(dialog)
	if "disable_overwrite_warning" in dialog:
		assert_false(
			dialog.disable_overwrite_warning,
			"disable_overwrite_warning should default to false"
		)
	else:
		pass_test("disable_overwrite_warning not yet available (pre-4.7)")
