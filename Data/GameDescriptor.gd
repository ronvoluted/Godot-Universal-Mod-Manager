extends Descriptor
class_name GameDescriptor

static var config_file := "game.cfg"
static var section := "Godot Game"

var title: String
var godot_version: String
var main_scene: String

func _read_fields(cfg: ConfigFile) -> void:
	title = cfg.get_value(section, "title")
	godot_version = cfg.get_value(section, "godot_version")
	main_scene = cfg.get_value(section, "main_scene")

func _write_fields(cfg: ConfigFile) -> void:
	cfg.set_value(section, "title", title)
	cfg.set_value(section, "godot_version", godot_version)
	cfg.set_value(section, "main_scene", main_scene)

func load_data(path: String) -> bool:
	var cfg := Descriptor.load_config(path, config_file)
	if not cfg or not cfg.has_section(section):
		return false
	_read_fields(cfg)
	return true

func save_data(path: String) -> Error:
	var cfg := ConfigFile.new()
	_write_fields(cfg)
	return Descriptor.save_config(cfg, path, config_file)

static func validate_path(path: String) -> String:
	var error := Descriptor.validate_directory(path, config_file)
	if not error.is_empty():
		return error
	var desc := GameDescriptor.new()
	if not desc.load_data(path):
		return "\"%s\" is malformed or unreadable." % config_file
	return ""
