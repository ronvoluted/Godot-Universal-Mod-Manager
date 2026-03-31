extends VBoxContainer

enum {DIRECTORY_CREATE_GAME, DIRECTORY_ADD_GAME, DIRECTORY_ADD_DESCRIPTIOR}
var directory_mode: int = -1

var entry_to_delete: Control

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed, CONNECT_ONE_SHOT)
	for game: Registry.GameData in Registry.games:
		add_game_entry(game)

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
	if %ImportPath.text.is_empty():
		set_add_error("Descriptor path can't be empty.")
		return
	
	var descriptor_path: String = %ImportPath.text.path_join(GameDescriptor.config_file)
	if not FileAccess.file_exists(descriptor_path):
		set_add_error("Descriptor directory invalid. Missing \"%s\"." % GameDescriptor.config_file)
		return

	if FileAccess.get_size(descriptor_path) == 0:
		set_add_error("\"%s\" is empty." % GameDescriptor.config_file)
		return
	
	var data := GameDescriptor.new()
	data.load_data(%ImportPath.text)
	if %GameList.get_children().find_custom(func(game: Node) -> bool: return game.entry.title == data.title) != -1:
		set_add_error("Game already on the list. Delete it first.")
		return
	
	if %ImportGame.text.is_empty():
		set_add_error("Game directory name can't be empty.")
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
		var entry := GameDescriptor.new()
		entry.load_data(entry_folder)
		
		var new_folder: String = "user://Games/" + entry.title.validate_filename()
		DirAccess.make_dir_recursive_absolute(new_folder)
		DirAccess.copy_absolute(entry_folder.path_join(GameDescriptor.config_file), new_folder.path_join(GameDescriptor.config_file))
		DirAccess.copy_absolute(entry_folder.path_join("icon.png"), new_folder.path_join("icon.png"))
		
		entry_folder = new_folder
	
	var entry_data := Registry.add_new_game_entry(entry_folder, %ImportGame.text.simplify_path())
	add_game_entry(entry_data)

#endregion

#region Game Creation

func on_create_game_entry() -> void:
	%CreateTitle.clear()
	%CreateScene.clear()
	%CreateDirectory.clear()
	
	$CreateGame.reset_size()
	$CreateGame.popup_centered()

func validate_create() -> void:
	if %CreateTitle.text.is_empty():
		set_create_error("Title can't be empty.")
		return
	
	if %GameList.get_children().find_custom(func(game: Node) -> bool: return game.entry.title == %CreateTitle.text) != -1:
		set_create_error("Game already on the list.")
		return
	
	if not %CreateIcon.text.is_empty():
		if not %CreateIcon.text.get_extension() in Registry.ICON_FORMATS:
			set_create_error("Icon format invalid. Supported extensions: %s" % ", ".join(Registry.ICON_FORMATS))
			return
		
		if not FileAccess.file_exists(%CreateIcon.text):
			set_create_error("Icon file does not exist.")
			return
	
	if %CreateScene.text.is_empty():
		set_create_error("Scene can't be empty.")
		return
	
	if not %CreateScene.text.begins_with("res://") or not %CreateScene.text.get_extension() in ["tscn", "scn"]:
		set_create_error("Scene path needs to point to a scn/tscn file inside res://.")
		return
	
	if %CreateDirectory.text.is_empty():
		set_create_error("Game directory name can't be empty.")
		return
	
	if DirAccess.get_files_at(%CreateDirectory.text).is_empty():
		set_create_error("The provided directory does not contain any files.")
		return
	
	set_create_error("")

func set_create_error(error: String) -> void:
	%CreateError.text = error
	$CreateGame.get_ok_button().disabled = not error.is_empty()

func create_game_entry() -> void:
	var entry := GameDescriptor.new()
	entry.title = %CreateTitle.text
	entry.godot_version = %CreateVersion.get_item_text(%CreateVersion.selected)
	entry.main_scene = %CreateScene.text
	
	var entry_path: String = "user://Games/" + %CreateTitle.text.validate_filename()
	DirAccess.make_dir_recursive_absolute(entry_path)
	entry.save_data(entry_path)
	
	if not %CreateIcon.text.is_empty():
		var image := Image.load_from_file(%CreateIcon.text)
		Registry.smart_resize_to_80(image)
		image.save_png(entry_path.path_join("icon.png"))
	
	var entry_data := Registry.add_new_game_entry(entry_path, %CreateDirectory.text.simplify_path())
	add_game_entry(entry_data)

#endregion

#region Entry Management

func add_game_entry(game: Registry.GameData) -> Control:
	var entry: Control = preload("res://Nodes/GameEntry.tscn").instantiate()
	%GameList.add_child(entry)
	entry.owner = self
	entry.set_game(game)
	if not entry.missing:
		entry.button.pressed.connect(open_game.bind(game.entry_path))
	entry.get_node(^"%Remove").pressed.connect(remove_game.bind(entry))
	return entry

func open_game(path: String) -> void:
	get_tree().set_meta(&"current_game", path)
	var scene_path := "res://Scenes/Game.tscn"
	ResourceLoader.load_threaded_request(scene_path)
	while true:
		var status := ResourceLoader.load_threaded_get_status(scene_path)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await get_tree().process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				get_tree().change_scene_to_packed(
					ResourceLoader.load_threaded_get(scene_path) as PackedScene
				)
				return
			_:
				push_error("Failed to load scene: %s" % scene_path)
				get_tree().change_scene_to_file(scene_path)
				return

func set_text(edit: LineEdit, text: String) -> void:
	edit.text = text
	edit.text_changed.emit(text)

func refresh_entry(old_entry: Control) -> void:
	var new_entry := add_game_entry(old_entry.metadata)
	new_entry.get_parent().move_child(new_entry, old_entry.get_index())
	old_entry.queue_free()

func remove_game(entry: Control, confirmed := false) -> void:
	if confirmed:
		entry = entry_to_delete
		entry.missing = true
	
	if entry.missing:
		Registry.remove_game_entry(entry.metadata)
		entry.queue_free()
	else:
		entry_to_delete = entry
		$DeleteConfirm.dialog_text = "Delete game \"%s\"?" % entry.entry.title
		$DeleteConfirm.reset_size()
		$DeleteConfirm.popup_centered()

#endregion
