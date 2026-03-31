extends Descriptor
class_name GameDescriptor

static var config_file := "game.cfg"
static var section := "Godot Game"

var title: String
var godot_version: String
var main_scene: String

func load_data(path: String) -> bool:
	var file_path := path.path_join(config_file)
	if not FileAccess.file_exists(file_path):
		push_warning("Game descriptor not found: '%s'." % file_path)
		return false
	if FileAccess.get_size(file_path) == 0:
		push_warning("Game descriptor is empty: '%s'." % file_path)
		return false

	var cfg := ConfigFile.new()
	var err := cfg.load(file_path)
	if err != OK:
		push_error("Failed to parse game descriptor '%s' (error %d)." % [file_path, err])
		return false

	title = cfg.get_value(section, "title")
	godot_version = cfg.get_value(section, "godot_version")
	main_scene = cfg.get_value(section, "main_scene")
	return true

func save_data(path: String) -> Error:
	var cfg := ConfigFile.new()
	cfg.set_value(section, "title", title)
	cfg.set_value(section, "godot_version", godot_version)
	cfg.set_value(section, "main_scene", main_scene)
	var err := cfg.save(path.path_join(config_file))
	if err != OK:
		push_error("Failed to save game descriptor to '%s' (error %d)." % [path.path_join(config_file), err])
	return err
