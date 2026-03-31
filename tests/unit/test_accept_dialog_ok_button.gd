extends GutTest
## Verify AcceptDialog ok button text and behavior after the ok_button_text
## rework (GH-81178).
##
## The project uses `get_ok_button().disabled` in Main.gd and Game.gd to
## prevent confirmation when validation errors exist. These tests confirm
## that `get_ok_button()` returns a valid Button whose `disabled` and `text`
## properties work as expected after the internal rework.


func test_accept_dialog_get_ok_button_returns_button() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)

	var ok_button := dialog.get_ok_button()
	assert_not_null(ok_button, "get_ok_button() should return a non-null Button")
	assert_is(ok_button, Button, "get_ok_button() should return a Button instance")


func test_accept_dialog_ok_button_default_text() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)

	# After GH-81178, ok_button_text defaults to "" (empty), with the actual
	# button text "OK" set via the translation system instead.
	assert_eq(dialog.ok_button_text, "", "Default ok_button_text should be empty after GH-81178")
	assert_eq(
		dialog.get_ok_button().text, "OK",
		"get_ok_button().text should display 'OK' via translation"
	)


func test_accept_dialog_ok_button_disabled_toggle() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)

	var ok_button := dialog.get_ok_button()
	assert_false(ok_button.disabled, "OK button should be enabled by default")

	ok_button.disabled = true
	assert_true(ok_button.disabled, "OK button should be disableable via get_ok_button()")

	ok_button.disabled = false
	assert_false(ok_button.disabled, "OK button should be re-enableable")


func test_accept_dialog_ok_button_text_property_syncs() -> void:
	var dialog := AcceptDialog.new()
	add_child_autofree(dialog)

	dialog.ok_button_text = "Confirm"
	assert_eq(
		dialog.get_ok_button().text, "Confirm",
		"Setting ok_button_text should update the button's text"
	)


func test_confirmation_dialog_ok_button_works() -> void:
	var dialog := ConfirmationDialog.new()
	add_child_autofree(dialog)

	var ok_button := dialog.get_ok_button()
	assert_not_null(ok_button, "ConfirmationDialog.get_ok_button() should return a Button")

	ok_button.disabled = true
	assert_true(ok_button.disabled, "ConfirmationDialog OK button should be disableable")


func test_add_game_dialog_ok_button() -> void:
	var main_scene: PackedScene = load("res://Scenes/Main.tscn")
	var main: Node = main_scene.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame

	var dialog: AcceptDialog = main.get_node("AddGame")
	assert_not_null(dialog, "AddGame dialog should exist")

	var ok_button := dialog.get_ok_button()
	assert_not_null(ok_button, "AddGame OK button should exist")
	assert_eq(ok_button.text, "OK", "AddGame OK button should have default text")


func test_create_game_dialog_ok_button() -> void:
	var main_scene: PackedScene = load("res://Scenes/Main.tscn")
	var main: Node = main_scene.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame

	var dialog: AcceptDialog = main.get_node("CreateGame")
	assert_not_null(dialog, "CreateGame dialog should exist")

	var ok_button := dialog.get_ok_button()
	assert_not_null(ok_button, "CreateGame OK button should exist")
	assert_eq(ok_button.text, "OK", "CreateGame OK button should have default text")


func test_file_dialog_ok_button_text_preserved() -> void:
	var path_edit: Node = load("res://Nodes/PathEdit.tscn").instantiate()
	add_child_autofree(path_edit)
	await get_tree().process_frame

	var file_dialog: FileDialog = path_edit.get_node("FileDialog")
	assert_eq(
		file_dialog.ok_button_text, "Select Current Folder",
		"PathEdit FileDialog should retain custom ok_button_text after rework"
	)
	assert_eq(
		file_dialog.get_ok_button().text, "Select Current Folder",
		"PathEdit FileDialog get_ok_button().text should match ok_button_text"
	)
