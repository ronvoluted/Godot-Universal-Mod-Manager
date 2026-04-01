@abstract
extends RefCounted
class_name Descriptor

@abstract
func _read_fields(cfg: ConfigFile) -> void

@abstract
func _write_fields(cfg: ConfigFile) -> void

static func validate_directory(path: String, cfg_file: String) -> String:
	if path.strip_edges().is_empty():
		return "Path can't be empty."
	if not DirAccess.dir_exists_absolute(path):
		return "The provided directory does not exist."
	var file_path := path.path_join(cfg_file)
	if not FileAccess.file_exists(file_path):
		return "No \"%s\" found at the given location." % cfg_file
	if FileAccess.get_size(file_path) == 0:
		return "\"%s\" is empty." % cfg_file
	return ""

static func load_config(path: String, cfg_file: String) -> ConfigFile:
	var file_path := path.path_join(cfg_file)
	if not FileAccess.file_exists(file_path):
		push_warning("Descriptor not found: '%s'." % file_path)
		return null
	if FileAccess.get_size(file_path) == 0:
		push_warning("Descriptor is empty: '%s'." % file_path)
		return null
	var cfg := ConfigFile.new()
	var err := cfg.load(file_path)
	if err != OK:
		push_error("Failed to parse descriptor '%s' (error %d)." % [file_path, err])
		return null
	return cfg

static func save_config(cfg: ConfigFile, path: String, cfg_file: String) -> Error:
	var file_path := path.path_join(cfg_file)
	var err := cfg.save(file_path)
	if err != OK:
		push_error("Failed to save descriptor to '%s' (error %d)." % [file_path, err])
	return err

@abstract
func load_data(path: String) -> bool

@abstract
func save_data(path: String) -> Error
