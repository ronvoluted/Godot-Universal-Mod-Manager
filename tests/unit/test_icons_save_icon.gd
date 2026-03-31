extends GutTest


func test_save_icon_creates_icon_png() -> void:
	var src_dir := DirAccess.create_temp("test_icon_src")
	var dst_dir := DirAccess.create_temp("test_icon_dst")

	var image := Image.create(200, 200, false, Image.FORMAT_RGBA8)
	image.save_png(src_dir.path_join("source.png"))

	Icons.save_icon(src_dir.path_join("source.png"), dst_dir)
	assert_true(FileAccess.file_exists(dst_dir.path_join("icon.png")))

	var saved := Image.load_from_file(dst_dir.path_join("icon.png"))
	assert_eq(saved.get_width(), 80)
	assert_eq(saved.get_height(), 80)

	DirAccess.remove_absolute(src_dir.path_join("source.png"))
	DirAccess.remove_absolute(src_dir)
	DirAccess.remove_absolute(dst_dir.path_join("icon.png"))
	DirAccess.remove_absolute(dst_dir)


func test_save_icon_resizes_landscape() -> void:
	var src_dir := DirAccess.create_temp("test_icon_landscape_src")
	var dst_dir := DirAccess.create_temp("test_icon_landscape_dst")

	var image := Image.create(160, 80, false, Image.FORMAT_RGBA8)
	image.save_png(src_dir.path_join("wide.png"))

	Icons.save_icon(src_dir.path_join("wide.png"), dst_dir)
	var saved := Image.load_from_file(dst_dir.path_join("icon.png"))
	assert_eq(saved.get_width(), 80)
	assert_eq(saved.get_height(), 40)

	DirAccess.remove_absolute(src_dir.path_join("wide.png"))
	DirAccess.remove_absolute(src_dir)
	DirAccess.remove_absolute(dst_dir.path_join("icon.png"))
	DirAccess.remove_absolute(dst_dir)


func test_save_icon_does_nothing_for_missing_source() -> void:
	var dst_dir := DirAccess.create_temp("test_icon_missing_dst")

	Icons.save_icon("user://nonexistent_icon.png", dst_dir)
	assert_false(FileAccess.file_exists(dst_dir.path_join("icon.png")))

	DirAccess.remove_absolute(dst_dir)
