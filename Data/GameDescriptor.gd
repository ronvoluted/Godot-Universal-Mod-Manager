extends Descriptor
class_name GameDescriptor

static var config_file := "game.cfg"
static var section := "Godot Game"

var title: String
var godot_version: String
var main_scene: String

func load_data(path: String) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(path.path_join(config_file)) != OK:
		return false

	title = cfg.get_value(section, "title")
	godot_version = cfg.get_value(section, "godot_version")
	main_scene = cfg.get_value(section, "main_scene")
	return true

func save_data(path: String) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(section, "title", title)
	cfg.set_value(section, "godot_version", godot_version)
	cfg.set_value(section, "main_scene", main_scene)
	cfg.save(path.path_join(config_file))
