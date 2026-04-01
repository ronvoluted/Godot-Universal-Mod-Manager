extends GutTest

## Tests for dialog and form input validation improvements.


#region GameEntry.try_recover validation

func test_game_entry_recover_rejects_whitespace_only_path() -> void:
	var entry := preload("res://Nodes/GameEntry.tscn").instantiate()
	add_child_autofree(entry)

	var game := GameData.new({entry_path = "/nonexistent", game_path = "/nonexistent", installed_mods = []})
	entry.set_game(game)
	assert_true(entry.missing)

	entry.try_recover("   ")
	await get_tree().process_frame

	assert_eq(entry.data.entry_path, "/nonexistent")


func test_game_entry_recover_rejects_malformed_descriptor() -> void:
	var tmp := "user://test_val_game_malformed"
	DirAccess.make_dir_recursive_absolute(tmp)
	var file := FileAccess.open(tmp.path_join(GameDescriptor.config_file), FileAccess.WRITE)
	file.store_string("not a valid config file")
	file.close()

	var entry := preload("res://Nodes/GameEntry.tscn").instantiate()
	add_child_autofree(entry)

	var game := GameData.new({entry_path = "/nonexistent", game_path = "/nonexistent", installed_mods = []})
	entry.set_game(game)

	entry.try_recover(tmp)
	await get_tree().process_frame

	assert_eq(entry.data.entry_path, "/nonexistent", "Recovery should be rejected for malformed descriptor")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


func test_game_entry_recover_accepts_valid_descriptor() -> void:
	var tmp := "user://test_val_game_valid"
	DirAccess.make_dir_recursive_absolute(tmp)
	var descriptor := GameDescriptor.new()
	descriptor.title = "Test Game"
	descriptor.godot_version = "4.x"
	descriptor.main_scene = "res://Main.tscn"
	descriptor.save_data(tmp)

	var entry := preload("res://Nodes/GameEntry.tscn").instantiate()
	add_child_autofree(entry)

	var game := GameData.new({entry_path = "/nonexistent", game_path = "/nonexistent", installed_mods = []})
	entry.set_game(game)
	assert_true(entry.missing)

	entry.try_recover(tmp)

	assert_eq(entry.data.entry_path, tmp, "Recovery should update path for valid descriptor")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)

#endregion

#region ModEntry.try_recover validation

func test_mod_entry_recover_rejects_whitespace_only_path() -> void:
	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({load_path = "/nonexistent", active = true})
	entry.set_mod(mod)
	assert_true(entry.missing)

	entry.try_recover("   ")
	await get_tree().process_frame

	assert_eq(entry.data.load_path, "/nonexistent")


func test_mod_entry_recover_rejects_malformed_descriptor() -> void:
	var tmp := "user://test_val_mod_malformed"
	DirAccess.make_dir_recursive_absolute(tmp)
	var file := FileAccess.open(tmp.path_join(ModDescriptor.config_file), FileAccess.WRITE)
	file.store_string("not a valid config file")
	file.close()

	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({load_path = "/nonexistent", active = true})
	entry.set_mod(mod)

	entry.try_recover(tmp)
	await get_tree().process_frame

	assert_eq(entry.data.load_path, "/nonexistent", "Recovery should be rejected for malformed descriptor")

	DirAccess.remove_absolute(tmp.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


func test_mod_entry_recover_accepts_valid_descriptor() -> void:
	var tmp := "user://test_val_mod_valid"
	DirAccess.make_dir_recursive_absolute(tmp)
	var descriptor := ModDescriptor.new()
	descriptor.game = "Test Game"
	descriptor.name = "Test Mod"
	descriptor.description = "A test mod"
	descriptor.version = "1.0"
	descriptor.save_data(tmp)

	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({load_path = "/nonexistent", active = true})
	entry.set_mod(mod)
	assert_true(entry.missing)

	entry.try_recover(tmp)

	assert_eq(entry.data.load_path, tmp, "Recovery should update path for valid descriptor")

	DirAccess.remove_absolute(tmp.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp)

#endregion

#region Whitespace-only input rejection

func test_strip_edges_catches_whitespace_only() -> void:
	assert_true("   ".strip_edges().is_empty())
	assert_true("\t\n".strip_edges().is_empty())
	assert_false("  valid  ".strip_edges().is_empty())

#endregion

#region Game.tscn NewModVersion signal connection

func test_game_scene_new_mod_version_connected_to_validate() -> void:
	var game := preload("res://Scenes/Game.tscn").instantiate()
	var version_edit: LineEdit = game.get_node(^"%NewModVersion")
	assert_true(version_edit.text_changed.get_connections().size() > 0,
		"NewModVersion text_changed should be connected for validation")
	game.free()

#endregion

#region Malformed descriptor rejection

func test_game_descriptor_load_malformed_config_returns_false() -> void:
	var tmp := "user://test_val_game_malformed_cfg"
	DirAccess.make_dir_recursive_absolute(tmp)
	var file := FileAccess.open(tmp.path_join(GameDescriptor.config_file), FileAccess.WRITE)
	file.store_string("not a valid config file")
	file.close()

	var descriptor := GameDescriptor.new()
	var result := descriptor.load_data(tmp)
	assert_false(result, "Malformed config file should return false from load_data")

	DirAccess.remove_absolute(tmp.path_join(GameDescriptor.config_file))
	DirAccess.remove_absolute(tmp)


func test_mod_descriptor_load_malformed_config_returns_false() -> void:
	var tmp := "user://test_val_mod_malformed_cfg"
	DirAccess.make_dir_recursive_absolute(tmp)
	var file := FileAccess.open(tmp.path_join(ModDescriptor.config_file), FileAccess.WRITE)
	file.store_string("not a valid config file")
	file.close()

	var descriptor := ModDescriptor.new()
	var result := descriptor.load_data(tmp)
	assert_false(result, "Malformed config file should return false from load_data")

	DirAccess.remove_absolute(tmp.path_join(ModDescriptor.config_file))
	DirAccess.remove_absolute(tmp)

#endregion
