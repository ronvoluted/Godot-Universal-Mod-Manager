extends RefCounted
class_name Icons

const FORMATS: PackedStringArray = ["png", "jpg"]

static func load_texture(directory: String) -> ImageTexture:
	var icon_path := directory.path_join("icon.png")
	if not FileAccess.file_exists(icon_path):
		return null
	var image := Image.load_from_file(icon_path)
	if not image:
		return null
	return ImageTexture.create_from_image(image)

static func save_icon(source_path: String, dest_dir: String) -> void:
	var image := Image.load_from_file(source_path)
	if not image:
		return
	resize_to_80(image)
	image.save_png(dest_dir.path_join("icon.png"))

static func resize_to_80(image: Image) -> void:
	var w := image.get_width()
	var h := image.get_height()
	if w == h:
		image.resize(80, 80, Image.INTERPOLATE_LANCZOS)
	elif w > h:
		image.resize(80, roundi(80.0 * h / w), Image.INTERPOLATE_LANCZOS)
	else:
		image.resize(roundi(80.0 * w / h), 80, Image.INTERPOLATE_LANCZOS)
