extends RefCounted

var resource_storage: Array[Resource]
var base_path: String

func initialize(mod_path: String, scene_tree: SceneTree) -> void:
	base_path = mod_path
	_initialize(scene_tree)

func _initialize(scene_tree: SceneTree) -> void:
	pass

func replace_resource_at(target_path: String, resource: Resource) -> void:
	resource.take_over_path(target_path)
	resource_storage.append(resource)

func load_texture(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(get_full_path(path)))

func load_mp3(path: String) -> AudioStreamMP3:
	var full_path := get_full_path(path)
	var file := FileAccess.open(full_path, FileAccess.READ)
	if not file:
		push_error("GUMM: Failed to open audio file: %s" % full_path)
		return null
	var data := file.get_buffer(file.get_length())

	var stream := AudioStreamMP3.new()
	stream.data = data

	return stream

func load_resource(path: String) -> Resource:
	return load(get_full_path(path))

func load_resource_threaded(path: String) -> Resource:
	var full_path := get_full_path(path)
	ResourceLoader.load_threaded_request(full_path)

	while true:
		var status := ResourceLoader.load_threaded_get_status(full_path)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await Engine.get_main_loop().process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				return ResourceLoader.load_threaded_get(full_path)
			_:
				push_error("GUMM: Failed to load resource: %s" % full_path)
				return null
	return null

func get_full_path(path: String) -> String:
	return base_path.path_join(path.trim_prefix("mod://"))
