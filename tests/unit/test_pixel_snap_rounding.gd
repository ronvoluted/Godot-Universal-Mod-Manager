extends GutTest
## Verify UI dimensions are pixel-snap-safe after the GUI pixel snap
## rounding change (GH-93749).
##
## Godot changed pixel snapping from floor() to round(). Elements with odd
## dimensions that get centered produce .5 positions, causing 1px layout
## shifts. These tests ensure all scene sizes, content areas, and icon
## resize logic use even dimensions compatible with round-based snapping.


# ---------------------------------------------------------------------------
# Scene dimension helpers
# ---------------------------------------------------------------------------

func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()


func _parse_vector2i(scene_text: String, property: String) -> Vector2i:
	## Extract a Vector2i or Vector2 property value from scene text.
	var pattern := property + " = Vector2i("
	var idx := scene_text.find(pattern)
	if idx == -1:
		# Fall back to Vector2 (used for custom_minimum_size etc.)
		pattern = property + " = Vector2("
		idx = scene_text.find(pattern)
	if idx == -1:
		return Vector2i(-1, -1)
	var start := idx + pattern.length()
	var end := scene_text.find(")", start)
	var parts := scene_text.substr(start, end - start).split(",")
	return Vector2i(parts[0].strip_edges().to_int(), parts[1].strip_edges().to_int())


func _parse_offset_pair(scene_text: String, after_marker: String, top_key: String, bottom_key: String) -> Vector2:
	## Extract a pair of offset values from a scene node section.
	var idx := scene_text.find(after_marker)
	if idx == -1:
		return Vector2(-1, -1)
	var section := scene_text.substr(idx, 500)
	var top_val := _extract_float(section, top_key)
	var bottom_val := _extract_float(section, bottom_key)
	return Vector2(top_val, bottom_val)


func _extract_float(text: String, key: String) -> float:
	var pattern := key + " = "
	var idx := text.find(pattern)
	if idx == -1:
		return -1.0
	var start := idx + pattern.length()
	var end := start
	while end < text.length() and (text[end].is_valid_float() or text[end] == "." or text[end] == "-"):
		end += 1
	return text.substr(start, end - start).to_float()


# ---------------------------------------------------------------------------
# Dialog size tests — odd heights cause .5 centering positions
# ---------------------------------------------------------------------------

func test_main_scene_dialog_sizes_are_even() -> void:
	var scene_text := _read_scene_file("res://Scenes/Main.tscn")

	# AddGame dialog
	var add_size := _parse_vector2i(scene_text, "size")
	assert_eq(add_size.x % 2, 0, "AddGame dialog width should be even, got %d" % add_size.x)
	assert_eq(add_size.y % 2, 0, "AddGame dialog height should be even, got %d" % add_size.y)

	# CreateGame dialog — find it after "Create Game Entry"
	var create_idx := scene_text.find("title = \"Create Game Entry\"")
	assert_gt(create_idx, 0, "CreateGame dialog should exist in Main.tscn")
	var create_section := scene_text.substr(create_idx, 200)
	var create_size := _parse_vector2i(create_section, "size")
	assert_eq(create_size.x % 2, 0, "CreateGame dialog width should be even, got %d" % create_size.x)
	assert_eq(create_size.y % 2, 0, "CreateGame dialog height should be even, got %d" % create_size.y)


func test_game_scene_dialog_sizes_are_even() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")

	# ImportModDialog
	var import_idx := scene_text.find("title = \"Import Mod\"")
	assert_gt(import_idx, 0, "ImportModDialog should exist in Game.tscn")
	var import_section := scene_text.substr(import_idx, 200)
	var import_size := _parse_vector2i(import_section, "size")
	assert_eq(import_size.x % 2, 0, "ImportModDialog width should be even, got %d" % import_size.x)
	assert_eq(import_size.y % 2, 0, "ImportModDialog height should be even, got %d" % import_size.y)

	# NewModDialog
	var new_idx := scene_text.find("title = \"Create Mod\"")
	assert_gt(new_idx, 0, "NewModDialog should exist in Game.tscn")
	var new_section := scene_text.substr(new_idx, 200)
	var new_size := _parse_vector2i(new_section, "size")
	assert_eq(new_size.x % 2, 0, "NewModDialog width should be even, got %d" % new_size.x)
	assert_eq(new_size.y % 2, 0, "NewModDialog height should be even, got %d" % new_size.y)


# ---------------------------------------------------------------------------
# Content area height tests — odd heights shift child centering by 1px
# ---------------------------------------------------------------------------

func test_main_scene_dialog_content_heights_are_even() -> void:
	var scene_text := _read_scene_file("res://Scenes/Main.tscn")

	# AddGame content VBoxContainer2
	var add_content := _parse_offset_pair(scene_text, "[node name=\"VBoxContainer2\" type=\"VBoxContainer\" parent=\"AddGame\"]", "offset_top", "offset_bottom")
	var add_height := int(add_content.y - add_content.x)
	assert_eq(add_height % 2, 0, "AddGame content height should be even, got %d" % add_height)

	# CreateGame content VBoxContainer2
	var create_content := _parse_offset_pair(scene_text, "[node name=\"VBoxContainer2\" type=\"VBoxContainer\" parent=\"CreateGame\"]", "offset_top", "offset_bottom")
	var create_height := int(create_content.y - create_content.x)
	assert_eq(create_height % 2, 0, "CreateGame content height should be even, got %d" % create_height)


func test_game_scene_dialog_content_heights_are_even() -> void:
	var scene_text := _read_scene_file("res://Scenes/Game.tscn")

	# ImportModDialog content
	var import_content := _parse_offset_pair(scene_text, "[node name=\"VBoxContainer\" type=\"VBoxContainer\" parent=\"ImportModDialog\"]", "offset_top", "offset_bottom")
	var import_height := int(import_content.y - import_content.x)
	assert_eq(import_height % 2, 0, "ImportModDialog content height should be even, got %d" % import_height)

	# NewModDialog content
	var new_content := _parse_offset_pair(scene_text, "[node name=\"VBoxContainer\" type=\"VBoxContainer\" parent=\"NewModDialog\"]", "offset_top", "offset_bottom")
	var new_height := int(new_content.y - new_content.x)
	assert_eq(new_height % 2, 0, "NewModDialog content height should be even, got %d" % new_height)


# ---------------------------------------------------------------------------
# Container minimum size tests — ensure icon containers use even dimensions
# ---------------------------------------------------------------------------

func test_icon_containers_use_even_minimum_sizes() -> void:
	for scene_path: String in ["res://Nodes/GameEntry.tscn", "res://Nodes/ModEntry.tscn"]:
		var scene_text := _read_scene_file(scene_path)

		# CenterContainer should have even minimum size
		var center_idx := scene_text.find("type=\"CenterContainer\"")
		assert_gt(center_idx, 0, "%s should have a CenterContainer" % scene_path)
		var center_section := scene_text.substr(center_idx, 200)
		var min_size := _parse_vector2i(center_section, "custom_minimum_size")
		assert_eq(min_size.x % 2, 0, "%s CenterContainer min width should be even, got %d" % [scene_path, min_size.x])
		assert_eq(min_size.y % 2, 0, "%s CenterContainer min height should be even, got %d" % [scene_path, min_size.y])

		# Icon TextureRect should have even minimum size
		var icon_idx := scene_text.find("\"Icon\"")
		assert_gt(icon_idx, 0, "%s should have an Icon node" % scene_path)
		var icon_section := scene_text.substr(icon_idx, 200)
		var icon_min := _parse_vector2i(icon_section, "custom_minimum_size")
		assert_eq(icon_min.x % 2, 0, "%s Icon min width should be even, got %d" % [scene_path, icon_min.x])
		assert_eq(icon_min.y % 2, 0, "%s Icon min height should be even, got %d" % [scene_path, icon_min.y])


# ---------------------------------------------------------------------------
# smart_resize_to_80 rounding tests
# ---------------------------------------------------------------------------

func test_smart_resize_uses_rounding_not_truncation() -> void:
	# 80 * 80 / 90 = 71.11 → truncation gives 71 (odd), rounding gives 71
	# 80 * 45 / 80 = 45.0 → exact, no difference
	# 80 * 79 / 100 = 63.2 → truncation gives 63 (odd), rounding gives 63
	# 80 * 75 / 100 = 60.0 → exact
	# 80 * 90 / 100 = 72.0 → exact
	# Key test: 80 * 3 / 7 = 34.285... → int=34, roundi=34
	# Key test: 80 * 5 / 9 = 44.444... → int=44, roundi=44
	# Key test: 80 * 11 / 16 = 55.0 → exact
	# Key test: 80 * 7 / 11 = 50.909... → int=50, roundi=51 — DIFFERENT!
	var image := Image.create(110, 80, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	# With roundi: 80 * 80 / 110 = 58.18 → 58; width = roundi(80*80/110)=58
	# Actually width > height so: resize(80, roundi(80.0 * 80 / 110))
	# = resize(80, roundi(58.18)) = resize(80, 58)
	assert_eq(image.get_width(), 80, "Landscape image width should be 80")
	assert_eq(image.get_height(), 58, "Landscape 110x80 height should round to 58")


func test_smart_resize_portrait_uses_rounding() -> void:
	# Portrait: 80x110 → resize(roundi(80*80/110), 80) = resize(58, 80)
	var image := Image.create(80, 110, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	assert_eq(image.get_width(), 58, "Portrait 80x110 width should round to 58")
	assert_eq(image.get_height(), 80, "Portrait image height should be 80")


func test_smart_resize_square_unchanged() -> void:
	var image := Image.create(200, 200, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	assert_eq(image.get_width(), 80, "Square image should resize to 80x80")
	assert_eq(image.get_height(), 80, "Square image should resize to 80x80")


func test_smart_resize_rounding_differs_from_truncation() -> void:
	# 80 * 60 / 130 = 36.923... → int()=36, roundi()=37
	# This case demonstrates the actual floor-vs-round difference
	var image := Image.create(130, 60, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	assert_eq(image.get_width(), 80, "Wide image width should be 80")
	assert_eq(image.get_height(), 37, "130x60 height should round to 37 (not truncate to 36)")
