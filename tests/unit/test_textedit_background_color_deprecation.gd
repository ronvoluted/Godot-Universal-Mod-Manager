extends GutTest
## Verify TextEdit nodes in Game.tscn do not use the deprecated
## `background_color` property (GH-110543).
##
## Godot 4.6 deprecated TextEdit.background_color in favour of the
## "background_color" theme color override.  Our TextEdit nodes never
## set this property; these tests lock that assumption so a future
## editor re-save cannot silently reintroduce it.


const GAME_SCENE_PATH := "res://Scenes/Game.tscn"

var _textedit_nodes: Array[String] = [
	"ImportModDescription",
	"NewModDescription",
]


func test_no_background_color_property_in_scene() -> void:
	var scene_text := _read_scene_file(GAME_SCENE_PATH)
	assert_false(
		scene_text.contains("background_color"),
		"Game.tscn should not contain deprecated background_color property"
	)


func test_textedit_nodes_exist() -> void:
	var scene_text := _read_scene_file(GAME_SCENE_PATH)
	for node_name: String in _textedit_nodes:
		assert_string_contains(
			scene_text,
			"[node name=\"%s\" type=\"TextEdit\"" % node_name,
			"Game.tscn should have TextEdit node: %s" % node_name
		)


func test_textedit_nodes_use_default_background() -> void:
	var scene_text := _read_scene_file(GAME_SCENE_PATH)
	# Neither the old property nor the new theme override should be present —
	# we rely on the default theme background for these TextEdit nodes.
	assert_false(
		scene_text.contains("theme_override_colors/background_color"),
		"Game.tscn TextEdit nodes should not override background_color via theme"
	)


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()
