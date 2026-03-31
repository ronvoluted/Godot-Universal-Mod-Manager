extends GutTest


var _region_files: Array[String] = [
	"res://Scenes/Game.gd",
	"res://Scenes/Main.gd",
]


func test_regions_are_balanced() -> void:
	for file_path: String in _region_files:
		var script := load(file_path) as GDScript
		assert_not_null(script, "Script should load: %s" % file_path)

		var source: String = script.source_code
		var lines: PackedStringArray = source.split("\n")
		var open_count: int = 0
		var close_count: int = 0

		for line: String in lines:
			var stripped := line.strip_edges()
			if stripped.begins_with("#region"):
				open_count += 1
			elif stripped == "#endregion":
				close_count += 1

		assert_eq(open_count, close_count, "Mismatched regions in %s: %d #region vs %d #endregion" % [file_path, open_count, close_count])
		assert_gt(open_count, 0, "Expected at least one region in %s" % file_path)


func test_game_gd_has_expected_regions() -> void:
	var regions := _get_region_names("res://Scenes/Game.gd")
	assert_has(regions, "Mod CRUD")
	assert_has(regions, "UI Validation")
	assert_has(regions, "Override.cfg Management")
	assert_has(regions, "Navigation")


func test_main_gd_has_expected_regions() -> void:
	var regions := _get_region_names("res://Scenes/Main.gd")
	assert_has(regions, "Game Import")
	assert_has(regions, "Game Creation")
	assert_has(regions, "Entry Management")


func test_no_nested_regions() -> void:
	for file_path: String in _region_files:
		var script := load(file_path) as GDScript
		assert_not_null(script, "Script should load: %s" % file_path)

		var source: String = script.source_code
		var lines: PackedStringArray = source.split("\n")
		var depth: int = 0

		for line: String in lines:
			var stripped := line.strip_edges()
			if stripped.begins_with("#region"):
				depth += 1
				assert_eq(depth, 1, "Nested region found in %s: %s" % [file_path, stripped])
			elif stripped == "#endregion":
				depth -= 1


func _get_region_names(file_path: String) -> Array[String]:
	var script := load(file_path) as GDScript
	var source: String = script.source_code
	var lines: PackedStringArray = source.split("\n")
	var names: Array[String] = []

	for line: String in lines:
		var stripped := line.strip_edges()
		if stripped.begins_with("#region "):
			names.append(stripped.substr(8))

	return names
