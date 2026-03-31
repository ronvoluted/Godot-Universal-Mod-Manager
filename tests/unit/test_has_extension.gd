extends GutTest
## Verify String.has_extension() replaces get_extension() in [...] pattern
## (GH-109433). Used for icon format checks in Main.gd and Game.gd, and
## scene extension checks in Main.gd.


# -- Single extension matching --

func test_has_extension_matches_png() -> void:
	assert_true("icon.png".has_extension("png"))


func test_has_extension_matches_jpg() -> void:
	assert_true("photo.jpg".has_extension("jpg"))


func test_has_extension_no_match() -> void:
	assert_false("file.bmp".has_extension("png"))


# -- Array of extensions (icon format checks) --

func test_has_extension_array_matches_first() -> void:
	assert_true("icon.png".has_extension(["png", "jpg"]))


func test_has_extension_array_matches_second() -> void:
	assert_true("icon.jpg".has_extension(["png", "jpg"]))


func test_has_extension_array_no_match() -> void:
	assert_false("icon.bmp".has_extension(["png", "jpg"]))


# -- Scene extension checks (as used in Main.gd) --

func test_has_extension_tscn() -> void:
	assert_true("res://Scenes/Main.tscn".has_extension(["tscn", "scn"]))


func test_has_extension_scn() -> void:
	assert_true("res://Scenes/Main.scn".has_extension(["tscn", "scn"]))


func test_has_extension_gd_not_scene() -> void:
	assert_false("res://Scripts/Main.gd".has_extension(["tscn", "scn"]))


# -- Case insensitivity (extensions should match regardless of case) --

func test_has_extension_case_insensitive() -> void:
	assert_true("icon.PNG".has_extension("png"),
		"has_extension() should be case-insensitive")


func test_has_extension_mixed_case_array() -> void:
	assert_true("scene.TSCN".has_extension(["tscn", "scn"]),
		"has_extension() with array should be case-insensitive")


# -- Edge cases --

func test_has_extension_no_extension() -> void:
	assert_false("README".has_extension("md"))


func test_has_extension_empty_string() -> void:
	assert_false("".has_extension("png"))


func test_has_extension_dot_only() -> void:
	assert_false(".".has_extension("png"))


# -- PackedStringArray (as used with Icons.FORMATS) --

func test_has_extension_packed_string_array() -> void:
	var formats: PackedStringArray = ["png", "jpg"]
	assert_true("icon.png".has_extension(formats))


func test_has_extension_packed_string_array_no_match() -> void:
	var formats: PackedStringArray = ["png", "jpg"]
	assert_false("icon.webp".has_extension(formats))
