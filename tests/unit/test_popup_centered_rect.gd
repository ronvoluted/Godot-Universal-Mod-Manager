extends GutTest
## Verify dialogs still appear at expected sizes after popup_centered_*
## rect fix (GH-112604).
##
## The upstream fix corrects how popup_centered() and popup_centered_ratio()
## compute the popup rect. These tests ensure our dialogs remain correctly
## sized and visible.


# -- popup_centered produces valid rect --

func test_accept_dialog_popup_centered_is_visible() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Test"
	add_child_autofree(dialog)
	await get_tree().process_frame

	dialog.popup_centered()
	await get_tree().process_frame

	assert_true(dialog.visible, "Dialog should be visible after popup_centered()")
	assert_gt(dialog.size.x, 0, "Dialog width should be positive")
	assert_gt(dialog.size.y, 0, "Dialog height should be positive")


func test_confirmation_dialog_popup_centered_is_visible() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Confirm action?"
	add_child_autofree(dialog)
	await get_tree().process_frame

	dialog.popup_centered()
	await get_tree().process_frame

	assert_true(dialog.visible, "ConfirmationDialog should be visible after popup_centered()")
	assert_gt(dialog.size.x, 0, "Dialog width should be positive")
	assert_gt(dialog.size.y, 0, "Dialog height should be positive")


# -- popup_centered_ratio produces proportional sizing --

func test_popup_centered_ratio_makes_dialog_visible() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)
	await get_tree().process_frame

	dialog.popup_centered_ratio(0.4)
	await get_tree().process_frame

	assert_true(dialog.visible, "Dialog should be visible after popup_centered_ratio(0.4)")
	assert_gt(dialog.size.x, 0, "Dialog width should be positive")
	assert_gt(dialog.size.y, 0, "Dialog height should be positive")


func test_popup_centered_ratio_respects_proportion() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)
	await get_tree().process_frame

	dialog.popup_centered_ratio(0.4)
	await get_tree().process_frame

	var screen_size := DisplayServer.window_get_size()
	if screen_size.x > 0 and screen_size.y > 0:
		var expected_w: int = int(screen_size.x * 0.4)
		assert_true(
			dialog.size.x >= expected_w,
			"Dialog width should be >= 40%% of screen (size.x=%d, expected=%d)" % [dialog.size.x, expected_w]
		)
	else:
		pass_test("Headless mode — proportion check not applicable")


# -- popup_centered_ratio with different ratios --

func test_popup_centered_ratio_larger_produces_bigger_dialog() -> void:
	var small := AcceptDialog.new()
	add_child_autofree(small)
	await get_tree().process_frame

	small.popup_centered_ratio(0.3)
	await get_tree().process_frame
	var small_size := Vector2i(small.size)
	small.hide()
	await get_tree().process_frame

	var large := AcceptDialog.new()
	add_child_autofree(large)
	await get_tree().process_frame

	large.popup_centered_ratio(0.6)
	await get_tree().process_frame
	var large_size := Vector2i(large.size)

	assert_true(
		large_size.x >= small_size.x and large_size.y >= small_size.y,
		"Ratio 0.6 dialog should be >= ratio 0.3 dialog (small=%s, large=%s)" % [small_size, large_size]
	)


# -- reset_size + popup_centered pattern used in project --

func test_reset_size_then_popup_centered_still_visible() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Delete game?"
	add_child_autofree(dialog)
	await get_tree().process_frame

	dialog.reset_size()
	dialog.popup_centered()
	await get_tree().process_frame

	assert_true(dialog.visible, "Dialog should be visible after reset_size() + popup_centered()")
	assert_gt(dialog.size.x, 0, "Dialog should have positive width after reset_size pattern")
	assert_gt(dialog.size.y, 0, "Dialog should have positive height after reset_size pattern")


# -- FileDialog with popup_centered_ratio(0.4) matches project usage --

func test_file_dialog_popup_centered_ratio_visible() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	add_child_autofree(dialog)
	await get_tree().process_frame

	dialog.popup_centered_ratio(0.4)
	await get_tree().process_frame

	assert_true(dialog.visible, "FileDialog should be visible after popup_centered_ratio(0.4)")
	assert_gt(dialog.size.x, 0, "FileDialog width should be positive")
	assert_gt(dialog.size.y, 0, "FileDialog height should be positive")


# -- popup_centered_clamped still available --

func test_popup_centered_clamped_method_exists() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)
	assert_true(
		dialog.has_method("popup_centered_clamped"),
		"Window should still expose popup_centered_clamped after rect fix"
	)


# -- popup_centered on Window base class --

func test_window_popup_centered_methods_exist() -> void:
	var window := Window.new()
	add_child_autofree(window)
	assert_true(window.has_method("popup_centered"), "Window should have popup_centered")
	assert_true(window.has_method("popup_centered_ratio"), "Window should have popup_centered_ratio")
	assert_true(window.has_method("popup_centered_clamped"), "Window should have popup_centered_clamped")


# -- Verify project dialog nodes exist in scenes --

func test_main_scene_dialogs_exist() -> void:
	var scene_text := _read_scene_file("res://Scenes/Main.tscn")
	for dialog_name: String in ["AddGame", "CreateGame", "DeleteConfirm"]:
		assert_string_contains(
			scene_text,
			"[node name=\"%s\"" % dialog_name,
			"Main.tscn should contain %s dialog" % dialog_name
		)


func test_game_scene_dialogs_exist() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")
	for dialog_name: String in ["ImportModDialog", "NewModDialog", "DeleteConfirm"]:
		assert_string_contains(
			scene_text,
			"[node name=\"%s\"" % dialog_name,
			"Game.tscn should contain %s dialog" % dialog_name
		)


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
