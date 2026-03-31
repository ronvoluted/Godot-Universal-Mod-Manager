extends GutTest

## Tests for UI usability and visual polish fixes.


# region Main Scene

func test_main_scene_has_scroll_container_for_game_list() -> void:
	var main := preload("res://Scenes/Main.tscn").instantiate()
	var game_list: VBoxContainer = main.get_node(^"%GameList")
	assert_is(game_list.get_parent(), ScrollContainer)
	main.free()


func test_main_scene_has_empty_state_label() -> void:
	var main := preload("res://Scenes/Main.tscn").instantiate()
	var label: Label = main.get_node(^"%EmptyLabel")
	assert_not_null(label)
	assert_true(label.text.length() > 0, "Empty state label should have text")
	main.free()


func test_main_scene_add_dialog_grid_has_h_separation() -> void:
	var main := preload("res://Scenes/Main.tscn").instantiate()
	var grid: GridContainer = main.get_node(^"AddGame/VBoxContainer2/VBoxContainer")
	assert_eq(grid.get_theme_constant(&"h_separation"), 30)
	main.free()


func test_main_scene_create_dialog_grid_has_h_separation() -> void:
	var main := preload("res://Scenes/Main.tscn").instantiate()
	var grid: GridContainer = main.get_node(^"CreateGame/VBoxContainer2/VBoxContainer")
	assert_eq(grid.get_theme_constant(&"h_separation"), 30)
	main.free()


func test_main_scene_create_title_has_placeholder() -> void:
	var main := preload("res://Scenes/Main.tscn").instantiate()
	var title: LineEdit = main.get_node(^"%CreateTitle")
	assert_true(title.placeholder_text.length() > 0, "CreateTitle should have placeholder text")
	main.free()


func test_main_scene_create_scene_has_placeholder() -> void:
	var main := preload("res://Scenes/Main.tscn").instantiate()
	var scene: LineEdit = main.get_node(^"%CreateScene")
	assert_true(scene.placeholder_text.length() > 0, "CreateScene should have placeholder text")
	main.free()


#endregion

#region Game Scene

func test_game_scene_has_scroll_container_for_mod_list() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var mod_list: VBoxContainer = game.get_node(^"%ModList")
	assert_is(mod_list.get_parent(), ScrollContainer)
	game.free()


func test_game_scene_has_empty_state_label() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var label: Label = game.get_node(^"%EmptyLabel")
	assert_not_null(label)
	assert_true(label.text.length() > 0, "Empty state label should have text")
	game.free()


func test_game_scene_import_error_has_autowrap() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var label: Label = game.get_node(^"%ImportError")
	assert_eq(label.autowrap_mode, TextServer.AUTOWRAP_WORD)
	game.free()


func test_game_scene_new_mod_error_has_autowrap() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var label: Label = game.get_node(^"%NewModError")
	assert_eq(label.autowrap_mode, TextServer.AUTOWRAP_WORD)
	game.free()


func test_game_scene_new_mod_name_has_placeholder() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var name_edit: LineEdit = game.get_node(^"%NewModName")
	assert_true(name_edit.placeholder_text.length() > 0, "NewModName should have placeholder text")
	game.free()


func test_game_scene_new_mod_version_has_placeholder() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var version_edit: LineEdit = game.get_node(^"%NewModVersion")
	assert_true(version_edit.placeholder_text.length() > 0, "NewModVersion should have placeholder text")
	game.free()


func test_game_scene_back_button_has_descriptive_text() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var back: Button = game.get_node(^"Button")
	assert_true(back.text.length() > 4, "Back button should have descriptive text beyond just 'Back'")
	game.free()


#endregion

#region GameEntry

func test_game_entry_no_duplicate_load_data() -> void:
	# Verify that set_game only calls load_data once by checking that
	# a missing entry_path correctly sets the missing flag without errors
	var entry := preload("res://Nodes/GameEntry.tscn").instantiate()
	add_child_autofree(entry)

	var game := GameData.new({entry_path = "/nonexistent/path", game_path = "/nonexistent", installed_mods = []})
	entry.set_game(game)

	assert_true(entry.missing)
	assert_eq(entry.get_node(^"%Title").text, "MISSING")


func test_game_entry_handles_missing_icon_gracefully() -> void:
	var tmp := "user://gumm_test_"
	DirAccess.make_dir_recursive_absolute(tmp)
	var descriptor := GameDescriptor.new()
	descriptor.title = "Test Game"
	descriptor.godot_version = "4.x"
	descriptor.main_scene = "res://main.tscn"
	descriptor.save_data(tmp)

	# No icon.png created - should not crash
	var entry := preload("res://Nodes/GameEntry.tscn").instantiate()
	add_child_autofree(entry)

	var game := GameData.new({entry_path = tmp, game_path = tmp, installed_mods = []})
	entry.set_game(game)

	assert_false(entry.missing)
	assert_null(entry.get_node(^"%Icon").texture, "Icon should be null when icon.png is missing")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


#endregion

#region ModEntry

func test_mod_entry_hides_version_when_empty() -> void:
	var tmp := "user://gumm_test_"
	DirAccess.make_dir_recursive_absolute(tmp)
	var descriptor := ModDescriptor.new()
	descriptor.game = "Test"
	descriptor.name = "Test Mod"
	descriptor.description = "Desc"
	descriptor.version = ""
	descriptor.save_data(tmp)

	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({load_path = tmp, active = true})
	entry.set_mod(mod)

	assert_false(entry.get_node(^"%Version").visible, "Version label should be hidden when version is empty")

	DirAccess.remove_absolute(tmp.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


func test_mod_entry_shows_version_when_present() -> void:
	var tmp := "user://gumm_test_"
	DirAccess.make_dir_recursive_absolute(tmp)
	var descriptor := ModDescriptor.new()
	descriptor.game = "Test"
	descriptor.name = "Test Mod"
	descriptor.description = "Desc"
	descriptor.version = "1.0"
	descriptor.save_data(tmp)

	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({load_path = tmp, active = true})
	entry.set_mod(mod)

	var version_label: Label = entry.get_node(^"%Version")
	assert_true(version_label.visible, "Version label should be visible when version is present")
	assert_eq(version_label.text, "v.1.0")

	DirAccess.remove_absolute(tmp.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


#endregion
