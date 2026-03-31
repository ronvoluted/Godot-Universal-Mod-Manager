extends PanelContainer

signal recovered

@onready var button: Button = $Button

var entry: GameDescriptor
var metadata: GameData

var missing: bool
var has_icon: bool

func set_game(meta: GameData) -> void:
	metadata = meta
	
	entry = GameDescriptor.new()
	if not entry.load_data(metadata.entry_path):
		missing = true
		%Title.text = "MISSING"
		%Title.modulate = Color.RED
		%Installed.text = "Game info not found at path: %s." % metadata.entry_path
		%Active.hide()
		%OpenFolder.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		$Button.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		return

	%Title.text = entry.title

	var icon_path := metadata.entry_path.path_join("icon.png")
	if FileAccess.file_exists(icon_path):
		var image := Image.load_from_file(icon_path)
		if image:
			%Icon.texture = ImageTexture.create_from_image(image)
	
	%Installed.text %= metadata.installed_mods.size()
	if metadata.mods_enabled:
		%Active.text %= metadata.installed_mods.filter(func(mod: ModData) -> bool: return mod.active).size()
	else:
		%Active.text %= 0
	
	%OpenFolder.pressed.connect(OS.shell_open.bind(ProjectSettings.globalize_path(metadata.entry_path)))

func try_recover(dir: String) -> void:
	if dir.strip_edges().is_empty():
		shoot_error.call_deferred("Path can't be empty.")
		return

	if not DirAccess.dir_exists_absolute(dir):
		shoot_error.call_deferred("The provided directory does not exist.")
		return

	if not FileAccess.file_exists(dir.path_join(GameDescriptor.config_file)):
		shoot_error.call_deferred("No \"%s\" found at the given location." % GameDescriptor.config_file)
		return

	if FileAccess.get_size(dir.path_join(GameDescriptor.config_file)) == 0:
		shoot_error.call_deferred("\"%s\" is empty." % GameDescriptor.config_file)
		return

	var data := GameDescriptor.new()
	if not data.load_data(dir):
		shoot_error.call_deferred("\"%s\" is malformed or unreadable." % GameDescriptor.config_file)
		return

	metadata.entry_path = dir
	Registry.save_game_entry_list()

	recovered.emit()

func shoot_error(error: String) -> void:
	$AcceptDialog.dialog_text = error
	$AcceptDialog.popup_centered()
