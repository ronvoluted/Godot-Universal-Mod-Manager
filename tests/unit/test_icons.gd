extends GutTest


# -- Icons.FORMATS --

func test_formats_contains_png_and_jpg() -> void:
	assert_has(Icons.FORMATS, "png")
	assert_has(Icons.FORMATS, "jpg")


func test_formats_is_packed_string_array() -> void:
	assert_typeof(Icons.FORMATS, TYPE_PACKED_STRING_ARRAY)


# -- Icons.resize_to_80 --

func test_resize_square_to_80x80() -> void:
	var image := Image.create(200, 200, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	assert_eq(image.get_width(), 80)
	assert_eq(image.get_height(), 80)


func test_resize_landscape_keeps_aspect() -> void:
	var image := Image.create(160, 80, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	assert_eq(image.get_width(), 80)
	assert_eq(image.get_height(), 40)


func test_resize_portrait_keeps_aspect() -> void:
	var image := Image.create(80, 160, false, Image.FORMAT_RGBA8)
	Icons.resize_to_80(image)
	assert_eq(image.get_width(), 40)
	assert_eq(image.get_height(), 80)


# -- Icons.load_texture --

func test_load_texture_returns_null_for_missing_dir() -> void:
	var result := Icons.load_texture("user://nonexistent_icons_test")
	assert_null(result)


func test_load_texture_returns_texture_for_valid_icon() -> void:
	var tmp_dir := "user://test_icons"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.save_png(tmp_dir.path_join("icon.png"))

	var result := Icons.load_texture(tmp_dir)
	assert_not_null(result)
	assert_is(result, ImageTexture)

	DirAccess.remove_absolute(tmp_dir.path_join("icon.png"))
	DirAccess.remove_absolute(tmp_dir)
