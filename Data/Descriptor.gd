@abstract
extends RefCounted
class_name Descriptor

@abstract
func load_data(path: String) -> bool

@abstract
func save_data(path: String) -> Error

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
