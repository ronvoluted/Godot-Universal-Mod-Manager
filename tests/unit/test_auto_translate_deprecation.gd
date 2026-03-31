extends GutTest
## Verify `auto_translate_mode` deprecation (GH-87530): scenes should not contain
## the deprecated `auto_translate` property. Godot 4.3 replaced it with
## `auto_translate_mode` which defaults to AUTO_TRANSLATE_INHERIT (inherits from
## parent). If any node had `auto_translate = false`, child nodes may unexpectedly
## stop translating under the new inheritance-based system.


var _scene_paths: Array[String] = [
	"res://Scenes/Main.tscn",
	"res://Scenes/Game.tscn",
	"res://Nodes/GameEntry.tscn",
	"res://Nodes/ModEntry.tscn",
	"res://Nodes/PathEdit.tscn",
	"res://System/4.x/GUMM_mod_loader.tscn",
]

var _deprecated_property_pattern := RegEx.create_from_string(
	'(?m)^auto_translate\\s*='
)

var _explicit_mode_pattern := RegEx.create_from_string(
	'(?m)^auto_translate_mode\\s*='
)


func test_no_deprecated_auto_translate_property() -> void:
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		assert_null(
			_deprecated_property_pattern.search(text),
			"%s should not contain deprecated 'auto_translate' property (GH-87530)" % scene_path
		)


func test_no_explicit_auto_translate_mode_override() -> void:
	for scene_path: String in _scene_paths:
		var text := _read_scene_file(scene_path)
		if text.is_empty():
			continue
		assert_null(
			_explicit_mode_pattern.search(text),
			"%s should not override auto_translate_mode; inherit from parent is preferred" % scene_path
		)


func test_nodes_default_to_inherit_mode() -> void:
	for scene_path: String in _scene_paths:
		var scene: PackedScene = load(scene_path)
		assert_not_null(scene, "Should be able to load %s" % scene_path)
		if scene == null:
			continue
		var state: SceneState = scene.get_state()
		for i: int in state.get_node_count():
			for j: int in state.get_node_property_count(i):
				var prop_name: StringName = state.get_node_property_name(i, j)
				assert_ne(
					prop_name, &"auto_translate",
					"Node '%s' in %s has deprecated auto_translate property"
						% [state.get_node_name(i), scene_path]
				)


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
