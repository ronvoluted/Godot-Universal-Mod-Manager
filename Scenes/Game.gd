extends Control

var game_data: GameDescriptor
var game_metadata: Registry.GameData

var entry_to_update: Control
var entry_to_delete: Control

func _ready() -> void:
	var entry_path: String = get_tree().get_meta(&"current_game", "")

	var dir := DirAccess.open(entry_path)
	var game_index := Registry.games.find_custom(func(meta: Registry.GameData) -> bool: return dir and dir.is_equivalent(meta.entry_path, entry_path))
	game_metadata = Registry.games[game_index]

	game_data = game_metadata.entry

	get_tree().scene_changed.connect(_on_scene_changed, CONNECT_ONE_SHOT)

func _on_scene_changed(_scene_root: Node) -> void:
	var new_missing := false
	for mod: Registry.GameData.ModData in game_metadata.installed_mods:
		add_mod_entry(mod)
		if not mod.active:
			new_missing = true

	if new_missing:
		apply_mods()

	%GameTitle.text = game_data.title
	%GameIcon.texture = ImageTexture.create_from_image(Image.load_from_file(game_metadata.entry_path.path_join("icon.png")))
	%GodotVersion.text %= game_data.godot_version
	%ModsEnabled.set_pressed_no_signal(game_metadata.mods_enabled)

	if is_override_cfg_disabled():
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

	if %ImportModPath.text.is_empty():
		set_import_error("Path can't be empty.")
		return

	if not DirAccess.dir_exists_absolute(%ImportModPath.text):
		set_import_error("The provided directory does not exist.")
		return

	var descriptor_path: String = %ImportModPath.text.path_join(ModDescriptor.config_file)
	if not FileAccess.file_exists(descriptor_path):
		set_import_error("No \"%s\" found at the given location." % ModDescriptor.config_file)
		return

	if FileAccess.get_size(descriptor_path) == 0:
		set_import_error("\"%s\" is empty." % ModDescriptor.config_file)
		return

	var mod_data := ModDescriptor.new()
	mod_data.load_data(%ImportModPath.text)

	if mod_data.game != game_data.title:
		set_import_error("Mod isn't made for \"%s\"." % game_data.title)
		return

	set_import_error("")

	var existing := get_mod_by_name(mod_data.name)
	if existing:
		set_import_warning("A mod with this name already exists, with version %s. It will be replaced." % existing.entry.version)
		entry_to_update = existing

	%ImportModName.text = mod_data.name
	%ImportModDescription.text = mod_data.description
	%ImportModVersion.text = mod_data.version

func import_mod_confirmed() -> void:
	var entry := Registry.add_new_mod_entry(game_metadata, %ImportModPath.text)
	if entry_to_update:
		refresh_entry(entry_to_update)
	else:
		add_mod_entry(entry)
	apply_mods()

func add_mod_entry(mod: Registry.GameData.ModData) -> Control:
	var entry: Control = preload("res://Nodes/ModEntry.tscn").instantiate()
	%ModList.add_child(entry)
	entry.owner = self
	entry.set_mod(mod)

	entry.get_node(^"%Edit").pressed.connect(edit_mod.bind(entry))
	entry.get_node(^"%Remove").pressed.connect(remove_mod.bind(entry))
	return entry

func create_mod() -> void:
	entry_to_update = null
	%NewModPath.disabled = false
	%NewModPath.clear()
	%IconPath.disabled = false
	%IconPath.clear()
	%NewModDescription.clear()
	%NewModVersion.clear()
	$NewModDialog.popup_centered()

func begin_edit_mod() -> void:
	%NewModPath.disabled = true
	%NewModPath.text = entry_to_update.metadata.load_path
	%NewModName.text = entry_to_update.entry.name
	%NewModDescription.text = entry_to_update.entry.description
	%NewModVersion.text = entry_to_update.entry.version
	if entry_to_update.has_icon:
		%IconPath.disabled = true
		%IconPath.clear()
	else:
		%IconPath.disabled = false
	validate_new_mod()
	$NewModDialog.popup_centered()

func create_mod_confirmed() -> void:
	var mod_data := ModDescriptor.new()
	mod_data.game = game_data.title
	mod_data.name = %NewModName.text
	mod_data.description = %NewModDescription.text
	mod_data.version = %NewModVersion.text
	mod_data.save_data(%NewModPath.text)

	if not %IconPath.text.is_empty() and FileAccess.file_exists(%IconPath.text) and %IconPath.text.has_extension(Registry.ICON_FORMATS):
		var image := Image.load_from_file(%IconPath.text)
		if image:
			Registry.smart_resize_to_80(image)
			image.save_png(%NewModPath.text.path_join("icon.png"))

	if entry_to_update:
		refresh_entry(entry_to_update)
		return

	DirAccess.copy_absolute("res://System/%s/GUMM_mod.gd" % game_data.godot_version, %NewModPath.text.path_join("GUMM_mod.gd"))
	DirAccess.copy_absolute("res://System/%s/mod.gd" % game_data.godot_version, %NewModPath.text.path_join("mod.gd"))

	var mod_entry := Registry.add_new_mod_entry(game_metadata, %NewModPath.text)
	add_mod_entry(mod_entry)
	apply_mods()

func edit_mod(entry: Control) -> void:
	entry_to_update = entry
	begin_edit_mod()

func remove_mod(entry: Control, confirmed := false) -> void:
	if confirmed:
		entry = entry_to_delete
		entry.missing = true

	if entry.missing:
		Registry.remove_mod_entry(game_metadata, entry.metadata)
		entry.queue_free()
	else:
		entry_to_delete = entry
		$DeleteConfirm.dialog_text = "Delete mod \"%s\"?" % entry.entry.name
		$DeleteConfirm.reset_size()
		$DeleteConfirm.popup_centered()

func refresh_entry(old_entry: Control) -> void:
	var new_entry := add_mod_entry(old_entry.metadata)
	new_entry.get_parent().move_child(new_entry, old_entry.get_index())
	old_entry.queue_free()

func get_mod_by_name(mod_name: String) -> Control:
	var children := %ModList.get_children()
	var index := children.find_custom(func(entry: Node) -> bool: return entry.entry.name == mod_name)
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
	if %NewModPath.text.is_empty():
		set_create_error("Path can't be empty.")
		return

	if not DirAccess.dir_exists_absolute(%NewModPath.text):
		set_create_error("The provided directory does not exist.")
		return

	if not %NewModPath.disabled and not DirAccess.get_files_at(%NewModPath.text).is_empty():
		set_create_error("The selected directory must not contain any files.")
		return

	if %NewModName.text.is_empty():
		set_create_error("Mod name can't be empty.")
		return

	set_create_error("")

	if not %IconPath.disabled and (%IconPath.text.is_empty() or not FileAccess.file_exists(%IconPath.text) or not %IconPath.text.has_extension(Registry.ICON_FORMATS)):
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
	OS.shell_open(game_metadata.game_path)

func toggle_mods(button_pressed: bool) -> void:
	game_metadata.mods_enabled = button_pressed

	if button_pressed:
		apply_mods()
	else:
		var override_file := get_override_path()
		var config := ConfigFile.new()
		config.load(override_file)

		var deleted := false
		var config_sections := config.get_sections()
		if config_sections.size() == 1 or config_sections.size() == 2:
			match game_data.godot_version:
				"2.x", "3.x":
					var has := int("application" in config_sections) + int("gumm" in config_sections)
					if has == config_sections.size() and config.get_section_keys("application").size() == 1:
						DirAccess.remove_absolute(override_file)
						deleted = true
				"4.x":
					var has := int("autoload" in config_sections) + int("gumm" in config_sections)
					if has == config_sections.size() and config.get_section_keys("autoload").size() == 1:
						DirAccess.remove_absolute(override_file)
						deleted = true

		if not deleted:
			match game_data.godot_version:
				"2.x":
					config.erase_section_key("application", "main_scene")
				"3.x":
					config.erase_section_key("application", "run/main_scene")
				"4.x":
					config.erase_section_key("autoload", "GUMM")
					if config.has_section("autoload") and config.get_section_keys("autoload").is_empty():
						config.erase_section("autoload")

			if config.has_section("gumm"):
				config.erase_section("gumm")
			config.save(override_file)

		match game_data.godot_version:
			"2.x", "3.x":
				DirAccess.remove_absolute(game_metadata.game_path.path_join(Registry.GameData.mod_loader_scene))
			"4.x":
				DirAccess.remove_absolute(game_metadata.game_path.path_join(Registry.GameData.mod_loader_autoload))

func apply_mods() -> void:
	var override_file := get_override_path()
	var config := ConfigFile.new()
	if FileAccess.file_exists(override_file):
		config.load(override_file)

	match game_data.godot_version:
		"2.x":
			config.set_value("application", "main_scene", "res://" + Registry.GameData.mod_loader_scene)
			DirAccess.copy_absolute("res://System/2.x/%s" % Registry.GameData.mod_loader_scene, game_metadata.game_path.path_join(Registry.GameData.mod_loader_scene))
			config.set_value("gumm", "main_scene", game_data.main_scene)
		"3.x":
			config.set_value("application", "run/main_scene", "res://" + Registry.GameData.mod_loader_scene)
			DirAccess.copy_absolute("res://System/3.x/%s" % Registry.GameData.mod_loader_scene, game_metadata.game_path.path_join(Registry.GameData.mod_loader_scene))
			config.set_value("gumm", "main_scene", game_data.main_scene)
		"4.x":
			DirAccess.copy_absolute("res://System/4.x/" + Registry.GameData.mod_loader_autoload, game_metadata.game_path.path_join(Registry.GameData.mod_loader_autoload))
			config.set_value("autoload", "GUMM", "*res://" + Registry.GameData.mod_loader_autoload)

	config.set_value("gumm", "mod_list", game_metadata.installed_mods.filter(func(mod: Registry.GameData.ModData) -> bool: return mod.active).map(func(mod: Registry.GameData.ModData) -> String: return mod.load_path))

	config.save(override_file)

func get_override_path() -> String:
	return game_metadata.game_path.path_join("override.cfg")

func is_override_cfg_disabled() -> bool:
	var project_cfg_path := game_metadata.game_path.path_join("project.godot")
	if not FileAccess.file_exists(project_cfg_path):
		return false
	var config := ConfigFile.new()
	if config.load(project_cfg_path) != OK:
		return false
	return config.get_value("application", "config/disable_project_settings_override", false)

#endregion

#region Navigation

func go_back() -> void:
	var scene_path := "res://Scenes/Main.tscn"
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

#endregion
