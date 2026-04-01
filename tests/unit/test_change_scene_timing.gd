extends GutTest
## Verify change_scene_to_file/change_scene_to_packed timing safety (GH-78988).
## Since Godot 4, the current scene is freed immediately on scene change.
## These tests ensure SceneLoader.change_scene returns immediately after the
## scene change call, and that open_game/go_back delegate to SceneLoader.


# -- SceneLoader structural verification --

func test_scene_loader_returns_after_change_scene_to_packed() -> void:
	var script: GDScript = load("res://Data/SceneLoader.gd")
	var source: String = script.source_code
	var lines: PackedStringArray = source.split("\n")

	var found_change_scene_packed := false
	for i: int in lines.size():
		var stripped: String = lines[i].strip_edges()
		if stripped.begins_with("tree.change_scene_to_packed("):
			var j: int = _skip_past_call(lines, i)
			if j < lines.size():
				assert_eq(lines[j].strip_edges(), "return",
					"SceneLoader: return must immediately follow change_scene_to_packed (line %d)" % (j + 1))
			found_change_scene_packed = true

	assert_true(found_change_scene_packed,
		"SceneLoader.gd should contain a change_scene_to_packed call")


func test_scene_loader_returns_after_change_scene_to_file() -> void:
	var script: GDScript = load("res://Data/SceneLoader.gd")
	var source: String = script.source_code
	var lines: PackedStringArray = source.split("\n")

	for i: int in lines.size():
		var stripped: String = lines[i].strip_edges()
		if stripped.begins_with("tree.change_scene_to_file("):
			assert_true(i + 1 < lines.size(),
				"SceneLoader.gd: change_scene_to_file must not be the last line")
			assert_eq(lines[i + 1].strip_edges(), "return",
				"SceneLoader: return must immediately follow change_scene_to_file (line %d)" % (i + 2))


# -- Delegation verification: Main.gd and Game.gd use SceneLoader --

func test_open_game_delegates_to_scene_loader() -> void:
	var source: String = (load("res://Scenes/Main.gd") as GDScript).source_code
	var func_body := _extract_function_body(source, "func open_game")
	assert_false(func_body.is_empty(), "Should find open_game function")
	assert_true(func_body.contains("SceneLoader.change_scene"),
		"open_game should delegate to SceneLoader.change_scene")


func test_go_back_delegates_to_scene_loader() -> void:
	var source: String = (load("res://Scenes/Game.gd") as GDScript).source_code
	var func_body := _extract_function_body(source, "func go_back")
	assert_false(func_body.is_empty(), "Should find go_back function")
	assert_true(func_body.contains("SceneLoader.change_scene"),
		"go_back should delegate to SceneLoader.change_scene")


# -- No post-scene-change member access in SceneLoader --

func test_scene_loader_no_self_access_after_scene_change() -> void:
	var script: GDScript = load("res://Data/SceneLoader.gd")
	var source: String = script.source_code
	var func_body := _extract_function_body(source, "static func change_scene")
	assert_false(func_body.is_empty(), "Should find change_scene function")
	_assert_no_post_scene_change_access(func_body, "change_scene")


# -- SceneTree.change_scene_to_file API exists --

func test_scene_tree_has_change_scene_to_file() -> void:
	var tree := SceneTree.new()
	assert_true(tree.has_method("change_scene_to_file"),
		"SceneTree should have change_scene_to_file method")
	tree.free()


func test_scene_tree_has_change_scene_to_packed() -> void:
	var tree := SceneTree.new()
	assert_true(tree.has_method("change_scene_to_packed"),
		"SceneTree should have change_scene_to_packed method")
	tree.free()


# -- Helpers --

## Skip past a multi-line function call starting at line i, returning the index
## of the first line after the closing parenthesis.
func _skip_past_call(lines: PackedStringArray, start: int) -> int:
	var depth := 0
	for j: int in range(start, lines.size()):
		for ch: String in lines[j]:
			if ch == "(":
				depth += 1
			elif ch == ")":
				depth -= 1
		if depth <= 0:
			return j + 1
	return lines.size()


func _assert_no_post_scene_change_access(func_body: String, label: String) -> void:
	var lines: PackedStringArray = func_body.split("\n")
	var i := 0
	while i < lines.size():
		var stripped: String = lines[i].strip_edges()
		if stripped.contains("change_scene_to_packed") or stripped.contains("change_scene_to_file"):
			# Skip past the (possibly multi-line) call
			i = _skip_past_call(lines, i)
			# Now only 'return' (or match wildcard) should follow
			while i < lines.size():
				var next: String = lines[i].strip_edges()
				i += 1
				if next.is_empty():
					continue
				assert_true(next == "return" or next == "_:",
					"%s: unexpected code after scene change: '%s'" % [label, next])
				if next == "return":
					break
		else:
			i += 1


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
