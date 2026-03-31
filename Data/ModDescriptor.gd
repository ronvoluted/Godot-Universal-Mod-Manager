extends RefCounted
class_name ModDescriptor

static var config_file := "mod.cfg"
static var section := "Godot Mod"

var game: String
var name: String
var description: String
var version: String
var dependencies: PackedStringArray

func load_data(path: String) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(path.path_join(config_file)) != OK:
		return false

	game = cfg.get_value(section, "game")
	name = cfg.get_value(section, "name")
	description = cfg.get_value(section, "description")
	version = cfg.get_value(section, "version")

	return true

func save_data(path: String):
	var cfg := ConfigFile.new()
	cfg.set_value(section, "game", game)
	cfg.set_value(section, "name", name)
	cfg.set_value(section, "description", description)
	cfg.set_value(section, "version", version)
	cfg.save(path.path_join(config_file))
