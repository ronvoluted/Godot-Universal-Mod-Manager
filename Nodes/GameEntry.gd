extends PanelContainer

signal recovered

@onready var button: Button = $Button

var descriptor: GameDescriptor
var data: GameData

var missing: bool

func set_game(game: GameData) -> void:
	data = game

	descriptor = GameDescriptor.new()
	if not descriptor.load_data(data.entry_path):
		missing = true
		%Title.text = "MISSING"
		%Title.modulate = Color.RED
		%Installed.text = "Game info not found at path: %s." % data.entry_path
		%Active.hide()
		%OpenFolder.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		$Button.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		return

	%Title.text = descriptor.title

	var texture := Icons.load_texture(data.entry_path)
	if texture:
		%Icon.texture = texture

	%Installed.text %= data.installed_mods.size()
	if data.mods_enabled:
		%Active.text %= data.installed_mods.filter(func(mod: ModData) -> bool: return mod.active).size()
	else:
		%Active.text %= 0

	%OpenFolder.pressed.connect(OS.shell_open.bind(ProjectSettings.globalize_path(data.entry_path)))

func try_recover(dir: String) -> void:
	var error := GameDescriptor.validate_path(dir)
	if not error.is_empty():
		shoot_error.call_deferred(error)
		return

	data.entry_path = dir
	Registry.save_game_entry_list()

	recovered.emit()

func shoot_error(error: String) -> void:
	$AcceptDialog.dialog_text = error
	$AcceptDialog.popup_centered()
