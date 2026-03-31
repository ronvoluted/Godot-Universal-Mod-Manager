extends GutTest
## Verify resource ID stability (GH-65011): .tscn resource IDs should follow
## the deterministic format introduced in Godot 4.2, preventing spurious diffs.


var _scene_paths: Array[String] = [
	"res://Scenes/Main.tscn",
	"res://Scenes/Game.tscn",
	"res://Nodes/GameEntry.tscn",
	"res://Nodes/ModEntry.tscn",
	"res://Nodes/PathEdit.tscn",
]

## Stable ext_resource IDs use the format: <number>_<hash>  (e.g. "1_tstig")
var _ext_resource_id_pattern := RegEx.create_from_string("^\\d+_[a-z0-9]{3,7}$")

## Stable sub_resource IDs use the format: <Type>_<hash>  (e.g. "GDScript_llbit")
var _sub_resource_id_pattern := RegEx.create_from_string("^[A-Z][A-Za-z0-9]+_[a-z0-9]{3,7}$")


func test_ext_resource_ids_use_stable_format() -> void:
	var ext_id_regex := RegEx.create_from_string('\\[ext_resource[^\\]]*id="([^"]+)"')
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		for result: RegExMatch in ext_id_regex.search_all(text):
			var id: String = result.get_string(1)
			assert_not_null(
				_ext_resource_id_pattern.search(id),
				"ext_resource id '%s' in %s should match stable format <number>_<hash>" % [id, scene_path]
			)


func test_sub_resource_ids_use_stable_format() -> void:
	var sub_id_regex := RegEx.create_from_string('\\[sub_resource[^\\]]*id="([^"]+)"')
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		for result: RegExMatch in sub_id_regex.search_all(text):
			var id: String = result.get_string(1)
			assert_not_null(
				_sub_resource_id_pattern.search(id),
				"sub_resource id '%s' in %s should match stable format <Type>_<hash>" % [id, scene_path]
			)


func test_resource_ids_are_unique_within_each_scene() -> void:
	var all_id_regex := RegEx.create_from_string('\\[(ext|sub)_resource[^\\]]*id="([^"]+)"')
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		var seen_ids: Dictionary[String, bool] = {}
		for result: RegExMatch in all_id_regex.search_all(text):
			var id: String = result.get_string(2)
			assert_false(
				seen_ids.has(id),
				"Resource id '%s' in %s should be unique" % [id, scene_path]
			)
			seen_ids[id] = true


func test_scenes_use_format_3() -> void:
	var format_regex := RegEx.create_from_string("\\[gd_scene[^\\]]*format=(\\d+)")
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		var result: RegExMatch = format_regex.search(text)
		assert_not_null(result, "%s should declare a scene format" % scene_path)
		if result:
			assert_eq(
				result.get_string(1), "3",
				"%s should use format 3 (Godot 4.x with stable IDs)" % scene_path
			)


func test_scenes_have_uid() -> void:
	var uid_regex := RegEx.create_from_string('\\[gd_scene[^\\]]*uid="uid://[a-z0-9]+"')
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		assert_not_null(
			uid_regex.search(text),
			"%s should have a stable uid:// identifier" % scene_path
		)


func test_no_purely_numeric_resource_ids() -> void:
	var numeric_id_regex := RegEx.create_from_string('\\[(ext|sub)_resource[^\\]]*id="(\\d+)"')
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		var matches: Array[RegExMatch] = numeric_id_regex.search_all(text)
		assert_eq(
			matches.size(), 0,
			"%s should not have old-style purely numeric resource IDs" % scene_path
		)


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
