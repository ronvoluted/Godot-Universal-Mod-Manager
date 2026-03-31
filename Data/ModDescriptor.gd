extends Descriptor
class_name ModDescriptor

static var config_file := "mod.cfg"
static var section := "Godot Mod"

var game: String
var name: String
var description: String
var version: String
var dependencies: PackedStringArray

func load_data(path: String) -> bool:
	var file_path := path.path_join(config_file)
	if not FileAccess.file_exists(file_path) or FileAccess.get_size(file_path) == 0:
		return false

	var cfg := ConfigFile.new()
	if cfg.load(file_path) != OK:
		return false

	game = cfg.get_value(section, "game")
	name = cfg.get_value(section, "name")
	description = cfg.get_value(section, "description")
	var raw_version: Variant = cfg.get_value(section, "version")
	if raw_version is float and raw_version == int(raw_version):
		version = str(int(raw_version))
	else:
		version = str(raw_version)

	return true

func save_data(path: String) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(section, "game", game)
	cfg.set_value(section, "name", name)
	cfg.set_value(section, "description", description)
	cfg.set_value(section, "version", version)
	cfg.save(path.path_join(config_file))
