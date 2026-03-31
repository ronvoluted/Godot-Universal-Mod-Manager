extends PanelContainer

signal active_toggled
signal recovered

var descriptor: ModDescriptor
var data: ModData

var missing: bool
var has_icon: bool

func set_mod(meta: ModData) -> void:
	data = meta

	descriptor = ModDescriptor.new()
	if not descriptor.load_data(data.load_path):
		missing = true
		%Name.text = "MISSING"
		%Name.modulate = Color.RED
		%Description.text = "Mod not found at path: %s." % data.load_path
		%Active.disabled = true
		%Edit.disabled = true
		%OpenFolder.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		return

	%Name.text = descriptor.name
	%Description.text = descriptor.description
	if descriptor.version.is_empty():
		%Version.hide()
	else:
		%Version.text = "v.%s" % descriptor.version
	%Active.set_pressed_no_signal(data.active)

	%OpenFolder.pressed.connect(OS.shell_open.bind(ProjectSettings.globalize_path(data.load_path)))

	var texture := Icons.load_texture(data.load_path)
	if texture:
		%Icon.texture = texture
		has_icon = true

func toggle_active(button_pressed: bool) -> void:
	data.active = button_pressed
	active_toggled.emit()

func try_recover(dir: String) -> void:
	var error := ModDescriptor.validate_path(dir)
	if not error.is_empty():
		shoot_error.call_deferred(error)
		return

	data.load_path = dir
	Registry.save_game_entry_list()

	recovered.emit()

func shoot_error(error: String) -> void:
	$AcceptDialog.dialog_text = error
	$AcceptDialog.popup_centered()
