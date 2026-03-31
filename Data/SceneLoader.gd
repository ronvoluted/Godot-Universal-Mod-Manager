extends RefCounted
class_name SceneLoader

static func change_scene(tree: SceneTree, scene_path: String) -> void:
	ResourceLoader.load_threaded_request(scene_path)
	while true:
		var status := ResourceLoader.load_threaded_get_status(scene_path)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await tree.process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				tree.change_scene_to_packed(
					ResourceLoader.load_threaded_get(scene_path) as PackedScene
				)
				return
			_:
				push_error("Failed to load scene: %s" % scene_path)
				tree.change_scene_to_file(scene_path)
				return
