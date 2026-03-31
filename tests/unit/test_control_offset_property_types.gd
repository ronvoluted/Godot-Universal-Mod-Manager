extends GutTest
## Verify all .tscn offset properties use float literals after Control
## offset type change from INT to float (GH-98443).
##
## Godot changed offset_left/right/top/bottom property declarations from
## Variant::INT to float to match getters/setters. Scene files must use
## float notation (e.g., 8.0 not 8) to avoid type mismatch warnings.


const SCENE_PATHS: Array[String] = [
	"res://Scenes/Main.tscn",
	"res://Scenes/Game.tscn",
	"res://Nodes/GameEntry.tscn",
	"res://Nodes/ModEntry.tscn",
	"res://Nodes/PathEdit.tscn",
]

const OFFSET_KEYS: Array[String] = [
	"offset_left",
	"offset_right",
	"offset_top",
	"offset_bottom",
]


func _read_scene_file(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Should be able to read scene file: %s" % scene_path)
	if file == null:
		return ""
	return file.get_as_text()


func _is_float_literal(value: String) -> bool:
	## A float literal contains a decimal point (e.g., "8.0", "-3.5").
	return value.contains(".")


func test_all_offset_values_are_float_literals() -> void:
	for scene_path: String in SCENE_PATHS:
		var scene_text := _read_scene_file(scene_path)
		if scene_text.is_empty():
			continue

		for key: String in OFFSET_KEYS:
			var search := key + " = "
			var start := 0
			while true:
				var idx := scene_text.find(search, start)
				if idx == -1:
					break
				var value_start := idx + search.length()
				var value_end := value_start
				while value_end < scene_text.length() and scene_text[value_end] != "\n":
					value_end += 1
				var value := scene_text.substr(value_start, value_end - value_start).strip_edges()
				assert_true(
					_is_float_literal(value),
					"%s: %s = %s should be a float literal (e.g., %s.0)" % [scene_path, key, value, value]
				)
				start = value_end


func test_no_scene_uses_integer_offset_values() -> void:
	## Regression guard: integer offsets (no decimal) would trigger warnings
	## after GH-98443 changed the property type to float.
	var integer_pattern := RegEx.new()
	integer_pattern.compile("offset_(?:left|right|top|bottom) = -?\\d+\\n")

	for scene_path: String in SCENE_PATHS:
		var scene_text := _read_scene_file(scene_path)
		if scene_text.is_empty():
			continue
		var matches := integer_pattern.search_all(scene_text)
		assert_eq(
			matches.size(), 0,
			"%s has integer offset values that need '.0' suffix: %s" % [
				scene_path,
				", ".join(matches.map(func(m: RegExMatch) -> String: return m.get_string().strip_edges()))
			]
		)
