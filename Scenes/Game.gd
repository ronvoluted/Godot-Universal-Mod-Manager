extends Control

var descriptor: GameDescriptor
var game: GameData

var entry_to_update: Control
var entry_to_delete: Control

func _ready() -> void:
	var entry_path: String = get_tree().get_meta(&"current_game", "")

	var dir := DirAccess.open(entry_path)
	var game_index := Registry.games.find_custom(func(meta: GameData) -> bool: return dir and dir.is_equivalent(meta.entry_path, entry_path))
	game = Registry.games[game_index]

	descriptor = game.entry

	get_tree().scene_changed.connect(_on_scene_changed, CONNECT_ONE_SHOT)

func _on_scene_changed(_scene_root: Node) -> void:
	var new_missing := false
	for mod: ModData in game.installed_mods:
		add_mod_entry(mod)
		if not mod.active:
			new_missing = true

	if new_missing:
		OverrideCfg.apply(game)

	%GameTitle.text = descriptor.title
	var texture := Icons.load_texture(game.entry_path)
	if texture:
		%GameIcon.texture = texture
	%GodotVersion.text %= descriptor.godot_version
	%ModsEnabled.set_pressed_no_signal(game.mods_enabled)

	if OverrideCfg.is_disabled(game):
		%ModsEnabled.disabled = true
		%ModsEnabled.tooltip_text = "This game has disabled override.cfg via project settings"
		%OverrideCfgWarning.show()

#region Mod CRUD

func import_mod() -> void:
	%ImportModPath.text = ""
	import_mod_update()
	$ImportModDialog.popup_centered()

func import_mod_update() -> void:
	%ImportModName.text = ""
	%ImportModDescription.text = ""
	%ImportModVersion.text = ""
	entry_to_update = null

	var error := ModDescriptor.validate_path(%ImportModPath.text)
	if not error.is_empty():
		set_import_error(error)
		return

	var mod_data := ModDescriptor.new()
	mod_data.load_data(%ImportModPath.text)

	if mod_data.game != descriptor.title:
		set_import_error("Mod isn't made for \"%s\"." % descriptor.title)
		return

	set_import_error("")

	var existing := get_mod_by_name(mod_data.name)
	if existing:
		set_import_warning("A mod with this name already exists, with version %s. It will be replaced." % existing.descriptor.version)
		entry_to_update = existing

	%ImportModName.text = mod_data.name
	%ImportModDescription.text = mod_data.description
	%ImportModVersion.text = mod_data.version

func import_mod_confirmed() -> void:
	var entry := Registry.add_new_mod_entry(game, %ImportModPath.text)
	if entry_to_update:
		refresh_entry(entry_to_update)
	else:
		add_mod_entry(entry)
	OverrideCfg.apply(game)

func update_empty_state() -> void:
	%EmptyLabel.visible = %ModList.get_child_count() <= 1

func add_mod_entry(mod: ModData) -> Control:
	var entry: Control = preload("res://Nodes/ModEntry.tscn").instantiate()
	%ModList.add_child(entry)
	entry.set_mod(mod)

	entry.get_node(^"%Edit").pressed.connect(edit_mod.bind(entry))
	entry.get_node(^"%Remove").pressed.connect(remove_mod.bind(entry))
	entry.active_toggled.connect(func() -> void: OverrideCfg.apply(game))
	entry.recovered.connect(refresh_entry.bind(entry))
	update_empty_state()
	return entry

func create_mod() -> void:
	entry_to_update = null
	%NewModPath.disabled = false
	%NewModPath.clear()
	%IconPath.disabled = false
	%IconPath.clear()
	%NewModName.clear()
	%NewModDescription.clear()
	%NewModVersion.clear()
	validate_new_mod()
	$NewModDialog.popup_centered()

func begin_edit_mod() -> void:
	%NewModPath.disabled = true
	%NewModPath.text = entry_to_update.data.load_path
	%NewModName.text = entry_to_update.descriptor.name
	%NewModDescription.text = entry_to_update.descriptor.description
	%NewModVersion.text = entry_to_update.descriptor.version
	if entry_to_update.has_icon:
		%IconPath.disabled = true
		%IconPath.clear()
	else:
		%IconPath.disabled = false
	validate_new_mod()
	$NewModDialog.popup_centered()

func create_mod_confirmed() -> void:
	var mod_data := ModDescriptor.new()
	mod_data.game = descriptor.title
	mod_data.name = %NewModName.text
	mod_data.description = %NewModDescription.text
	mod_data.version = %NewModVersion.text
	mod_data.save_data(%NewModPath.text)

	if not %IconPath.text.is_empty() and FileAccess.file_exists(%IconPath.text) and %IconPath.text.has_extension(Icons.FORMATS):
		var image := Image.load_from_file(%IconPath.text)
		if image:
			Icons.resize_to_80(image)
			image.save_png(%NewModPath.text.path_join("icon.png"))

	if entry_to_update:
		refresh_entry(entry_to_update)
		return

	var err := DirAccess.copy_absolute("res://System/%s/GUMM_mod.gd" % descriptor.godot_version, %NewModPath.text.path_join("GUMM_mod.gd"))
	if err != OK:
		push_error("Failed to copy mod template GUMM_mod.gd (error %d)." % err)
	err = DirAccess.copy_absolute("res://System/%s/mod.gd" % descriptor.godot_version, %NewModPath.text.path_join("mod.gd"))
	if err != OK:
		push_error("Failed to copy mod template mod.gd (error %d)." % err)

	var mod_entry := Registry.add_new_mod_entry(game, %NewModPath.text)
	add_mod_entry(mod_entry)
	OverrideCfg.apply(game)

func edit_mod(entry: Control) -> void:
	entry_to_update = entry
	begin_edit_mod()

func remove_mod(entry: Control, confirmed := false) -> void:
	if confirmed:
		entry = entry_to_delete
		entry.missing = true

	if entry.missing:
		Registry.remove_mod_entry(game, entry.data)
		entry.queue_free()
		update_empty_state()
	else:
		entry_to_delete = entry
		$DeleteConfirm.dialog_text = "Delete mod \"%s\"?" % entry.descriptor.name
		$DeleteConfirm.reset_size()
		$DeleteConfirm.popup_centered()

func refresh_entry(old_entry: Control) -> void:
	var new_entry := add_mod_entry(old_entry.data)
	new_entry.get_parent().move_child(new_entry, old_entry.get_index())
	old_entry.queue_free()

func get_mod_by_name(mod_name: String) -> Control:
	var children := %ModList.get_children()
	var index := children.find_custom(func(entry: Node) -> bool: return entry.descriptor.name == mod_name)
	return children[index] if index != -1 else null

#endregion

#region UI Validation

func set_import_error(error: String) -> void:
	%ImportError.add_theme_color_override(&"font_color", Color.RED)
	%ImportError.text = error
	$ImportModDialog.get_ok_button().disabled = not error.is_empty()

func set_import_warning(warning: String) -> void:
	%ImportError.add_theme_color_override(&"font_color", Color.YELLOW)
	%ImportError.text = warning

func validate_new_mod() -> void:
	if %NewModPath.text.strip_edges().is_empty():
		set_create_error("Path can't be empty.")
		return

	if not DirAccess.dir_exists_absolute(%NewModPath.text):
		set_create_error("The provided directory does not exist.")
		return

	if not %NewModPath.disabled and not DirAccess.get_files_at(%NewModPath.text).is_empty():
		set_create_error("The selected directory must not contain any files.")
		return

	if %NewModName.text.strip_edges().is_empty():
		set_create_error("Mod name can't be empty.")
		return

	set_create_error("")

	if not %IconPath.disabled and not %IconPath.text.strip_edges().is_empty() and (not FileAccess.file_exists(%IconPath.text) or not %IconPath.text.has_extension(Icons.FORMATS)):
		set_create_warning("Icon path invalid. The mod will have no icon.")

func set_create_error(error: String) -> void:
	%NewModError.add_theme_color_override(&"font_color", Color.RED)
	%NewModError.text = error
	$NewModDialog.get_ok_button().disabled = not error.is_empty()

func set_create_warning(warning: String) -> void:
	%NewModError.add_theme_color_override(&"font_color", Color.YELLOW)
	%NewModError.text = warning

#endregion

#region Override.cfg Management

func open_game_directory() -> void:
	OS.shell_open(game.game_path)

func toggle_mods(button_pressed: bool) -> void:
	game.mods_enabled = button_pressed
	if button_pressed:
		OverrideCfg.apply(game)
	else:
		OverrideCfg.remove(game)

#endregion

#region Navigation

func go_back() -> void:
	SceneLoader.change_scene(get_tree(), "res://Scenes/Main.tscn")

#endregion
