extends VBoxContainer

var entry_to_delete: Control

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed, CONNECT_ONE_SHOT)
	for game: GameData in Registry.games:
		add_game_entry(game)
	update_empty_state()

func _on_scene_changed(_scene_root: Node) -> void:
	if get_tree().has_meta(&"current_game"):
		get_tree().remove_meta(&"current_game")

#region Game Import

func on_add_game_entry() -> void:
	%ImportPath.clear()
	%ImportGame.clear()
	%CopyLocal.button_pressed = true
	validate_add()

	$AddGame.reset_size()
	$AddGame.popup_centered()

func validate_add() -> void:
	var error := GameDescriptor.validate_path(%ImportPath.text)
	if not error.is_empty():
		set_add_error(error)
		return

	var data := GameDescriptor.new()
	data.load_data(%ImportPath.text)
	if %GameList.get_children().find_custom(func(game: Node) -> bool: return game.descriptor.title == data.title) != -1:
		set_add_error("Game already on the list. Delete it first.")
		return

	if %ImportGame.text.strip_edges().is_empty():
		set_add_error("Game directory name can't be empty.")
		return

	if not DirAccess.dir_exists_absolute(%ImportGame.text):
		set_add_error("The provided game directory does not exist.")
		return

	if DirAccess.get_files_at(%ImportGame.text).is_empty():
		set_add_error("The provided directory does not contain any files.")
		return

	set_add_error("")

func set_add_error(error: String) -> void:
	%AddError.text = error
	$AddGame.get_ok_button().disabled = not error.is_empty()

func import_game_entry() -> void:
	var entry_folder: String = %ImportPath.text.simplify_path()

	if %CopyLocal.button_pressed:
		var descriptor := GameDescriptor.new()
		descriptor.load_data(entry_folder)

		var new_folder: String = "user://Games/" + descriptor.title.validate_filename()
		var err := DirAccess.make_dir_recursive_absolute(new_folder)
		if err != OK:
			push_error("Failed to create directory '%s' (error %d)." % [new_folder, err])
			return
		err = DirAccess.copy_absolute(entry_folder.path_join(GameDescriptor.config_file), new_folder.path_join(GameDescriptor.config_file))
		if err != OK:
			push_error("Failed to copy game descriptor to '%s' (error %d)." % [new_folder, err])
			return
		DirAccess.copy_absolute(entry_folder.path_join("icon.png"), new_folder.path_join("icon.png"))

		entry_folder = new_folder

	var entry_data := Registry.add_new_game_entry(entry_folder, %ImportGame.text.simplify_path())
	add_game_entry(entry_data)

#endregion

#region Game Creation

func on_create_game_entry() -> void:
	%CreateTitle.clear()
	%CreateIcon.clear()
	%CreateScene.clear()
	%CreateDirectory.clear()
	validate_create()

	$CreateGame.reset_size()
	$CreateGame.popup_centered()

func validate_create() -> void:
	if %CreateTitle.text.strip_edges().is_empty():
		set_create_error("Title can't be empty.")
		return

	if %GameList.get_children().find_custom(func(game: Node) -> bool: return game.descriptor.title == %CreateTitle.text) != -1:
		set_create_error("Game already on the list.")
		return

	if not %CreateIcon.text.strip_edges().is_empty():
		if not %CreateIcon.text.has_extension(Icons.FORMATS):
			set_create_error("Icon format invalid. Supported extensions: %s" % ", ".join(Icons.FORMATS))
			return

		if not FileAccess.file_exists(%CreateIcon.text):
			set_create_error("Icon file does not exist.")
			return

	if %CreateScene.text.strip_edges().is_empty():
		set_create_error("Scene can't be empty.")
		return

	if not %CreateScene.text.begins_with("res://") or not %CreateScene.text.has_extension(["tscn", "scn"]):
		set_create_error("Scene path needs to point to a scn/tscn file inside res://.")
		return

	if %CreateDirectory.text.strip_edges().is_empty():
		set_create_error("Game directory name can't be empty.")
		return

	if not DirAccess.dir_exists_absolute(%CreateDirectory.text):
		set_create_error("The provided game directory does not exist.")
		return

	if DirAccess.get_files_at(%CreateDirectory.text).is_empty():
		set_create_error("The provided directory does not contain any files.")
		return

	set_create_error("")

func set_create_error(error: String) -> void:
	%CreateError.text = error
	$CreateGame.get_ok_button().disabled = not error.is_empty()

func create_game_entry() -> void:
	var descriptor := GameDescriptor.new()
	descriptor.title = %CreateTitle.text
	descriptor.godot_version = %CreateVersion.get_item_text(%CreateVersion.selected)
	descriptor.main_scene = %CreateScene.text

	var entry_path: String = "user://Games/" + %CreateTitle.text.validate_filename()
	var err := DirAccess.make_dir_recursive_absolute(entry_path)
	if err != OK:
		push_error("Failed to create directory '%s' (error %d)." % [entry_path, err])
		return
	descriptor.save_data(entry_path)

	if not %CreateIcon.text.is_empty():
		var image := Image.load_from_file(%CreateIcon.text)
		Icons.resize_to_80(image)
		image.save_png(entry_path.path_join("icon.png"))

	var entry_data := Registry.add_new_game_entry(entry_path, %CreateDirectory.text.simplify_path())
	add_game_entry(entry_data)

#endregion

#region Entry Management

func update_empty_state() -> void:
	%EmptyLabel.visible = %GameList.get_child_count() <= 1

func add_game_entry(game: GameData) -> Control:
	var entry: Control = preload("res://Nodes/GameEntry.tscn").instantiate()
	%GameList.add_child(entry)
	entry.set_game(game)
	if not entry.missing:
		entry.button.pressed.connect(open_game.bind(game.entry_path))
	entry.get_node(^"%Remove").pressed.connect(remove_game.bind(entry))
	entry.recovered.connect(refresh_entry.bind(entry))
	update_empty_state()
	return entry

func open_game(path: String) -> void:
	get_tree().set_meta(&"current_game", path)
	SceneLoader.change_scene(get_tree(), "res://Scenes/Game.tscn")

func refresh_entry(old_entry: Control) -> void:
	var new_entry := add_game_entry(old_entry.data)
	new_entry.get_parent().move_child(new_entry, old_entry.get_index())
	old_entry.queue_free()

func remove_game(entry: Control, confirmed := false) -> void:
	if confirmed:
		entry = entry_to_delete
		entry.missing = true

	if entry.missing:
		Registry.remove_game_entry(entry.data)
		entry.queue_free()
		update_empty_state()
	else:
		entry_to_delete = entry
		$DeleteConfirm.dialog_text = "Delete game \"%s\"?" % entry.descriptor.title
		$DeleteConfirm.reset_size()
		$DeleteConfirm.popup_centered()

#endregion
