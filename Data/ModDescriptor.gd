extends Descriptor
class_name ModDescriptor

static var config_file := "mod.cfg"
static var section := "Godot Mod"

var game: String
var name: String
var description: String
var version: String
var dependencies: PackedStringArray

func _read_fields(cfg: ConfigFile) -> void:
	game = cfg.get_value(section, "game")
	name = cfg.get_value(section, "name")
	description = cfg.get_value(section, "description")
	var raw_version: Variant = cfg.get_value(section, "version")
	if raw_version is float and raw_version == int(raw_version):
		version = str(int(raw_version))
	else:
		version = str(raw_version)

func _write_fields(cfg: ConfigFile) -> void:
	cfg.set_value(section, "game", game)
	cfg.set_value(section, "name", name)
	cfg.set_value(section, "description", description)
	cfg.set_value(section, "version", version)

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
	var desc := ModDescriptor.new()
	if not desc.load_data(path):
		return "\"%s\" is malformed or unreadable." % config_file
	return ""
