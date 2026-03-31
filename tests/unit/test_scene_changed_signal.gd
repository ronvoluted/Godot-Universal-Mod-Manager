extends GutTest
## Verify SceneTree.scene_changed signal usage for scene transitions (GH-102986).
## Main.gd and Game.gd should connect to scene_changed for cleanup/setup logic
## rather than relying solely on _ready().


# -- Signal existence --

func test_scene_tree_has_scene_changed_signal() -> void:
	var tree := SceneTree.new()
	assert_true(tree.has_signal("scene_changed"),
		"SceneTree should have scene_changed signal")
	tree.free()


# -- Main.gd connects scene_changed in _ready --

func test_main_ready_connects_scene_changed() -> void:
	var source: String = (load("res://Scenes/Main.gd") as GDScript).source_code
	var ready_body := _extract_function_body(source, "func _ready")
	assert_false(ready_body.is_empty(), "Should find _ready function in Main.gd")

	assert_true(ready_body.contains("scene_changed.connect"),
		"Main._ready should connect to scene_changed signal")


func test_main_on_scene_changed_cleans_up_current_game_meta() -> void:
	var source: String = (load("res://Scenes/Main.gd") as GDScript).source_code
	var handler_body := _extract_function_body(source, "func _on_scene_changed")
	assert_false(handler_body.is_empty(),
		"Should find _on_scene_changed function in Main.gd")

	assert_true(handler_body.contains("remove_meta") and handler_body.contains("current_game"),
		"Main._on_scene_changed should remove current_game metadata")


# -- Game.gd connects scene_changed in _ready --

func test_game_ready_connects_scene_changed() -> void:
	var source: String = (load("res://Scenes/Game.gd") as GDScript).source_code
	var ready_body := _extract_function_body(source, "func _ready")
	assert_false(ready_body.is_empty(), "Should find _ready function in Game.gd")

	assert_true(ready_body.contains("scene_changed.connect"),
		"Game._ready should connect to scene_changed signal")


func test_game_on_scene_changed_populates_ui() -> void:
	var source: String = (load("res://Scenes/Game.gd") as GDScript).source_code
	var handler_body := _extract_function_body(source, "func _on_scene_changed")
	assert_false(handler_body.is_empty(),
		"Should find _on_scene_changed function in Game.gd")

	assert_true(handler_body.contains("%GameTitle"),
		"Game._on_scene_changed should set GameTitle")
	assert_true(handler_body.contains("%ModsEnabled"),
		"Game._on_scene_changed should set ModsEnabled")


# -- Connection uses CONNECT_ONE_SHOT --

func test_main_scene_changed_is_one_shot() -> void:
	var source: String = (load("res://Scenes/Main.gd") as GDScript).source_code
	var ready_body := _extract_function_body(source, "func _ready")

	assert_true(ready_body.contains("CONNECT_ONE_SHOT"),
		"Main scene_changed connection should use CONNECT_ONE_SHOT")


func test_game_scene_changed_is_one_shot() -> void:
	var source: String = (load("res://Scenes/Game.gd") as GDScript).source_code
	var ready_body := _extract_function_body(source, "func _ready")

	assert_true(ready_body.contains("CONNECT_ONE_SHOT"),
		"Game scene_changed connection should use CONNECT_ONE_SHOT")


# -- _ready still handles data initialization --

func test_game_ready_still_loads_metadata() -> void:
	var source: String = (load("res://Scenes/Game.gd") as GDScript).source_code
	var ready_body := _extract_function_body(source, "func _ready")

	assert_true(ready_body.contains("get_meta") and ready_body.contains("current_game"),
		"Game._ready should still read current_game metadata")
	assert_true(ready_body.contains("game_metadata"),
		"Game._ready should still initialize game_metadata")


func test_main_ready_still_populates_game_list() -> void:
	var source: String = (load("res://Scenes/Main.gd") as GDScript).source_code
	var ready_body := _extract_function_body(source, "func _ready")

	assert_true(ready_body.contains("add_game_entry"),
		"Main._ready should still populate the game list")


# -- Helpers --

func _extract_function_body(source: String, func_signature: String) -> String:
	var lines: PackedStringArray = source.split("\n")
	var capturing := false
	var body_lines: PackedStringArray = []
	var base_indent := -1

	for line: String in lines:
		if not capturing:
			if line.strip_edges().begins_with(func_signature):
				capturing = true
			continue

		if line.strip_edges().is_empty():
			body_lines.append(line)
			continue

		var indent: int = line.length() - line.lstrip("\t").length()
		if base_indent < 0:
			base_indent = indent

		if indent < base_indent and not line.strip_edges().is_empty():
			break

		body_lines.append(line)

	return "\n".join(body_lines)
