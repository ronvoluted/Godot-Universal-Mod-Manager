extends GutTest
## Verify System/2.x/ and 3.x/ compat layers are correct for their target
## engines and properly isolated from the 4.6 editor via .gdignore.


# -- .gdignore isolation --

func test_system_gdignore_exists() -> void:
	assert_true(FileAccess.file_exists("res://System/.gdignore"),
		"System/.gdignore must exist to prevent 4.6 editor from parsing legacy scripts")


func test_examples_gdignore_exists() -> void:
	assert_true(FileAccess.file_exists("res://Examples/.gdignore"),
		"Examples/.gdignore must exist to prevent editor from scanning example projects")


# -- 2.x compat layer file accessibility --

func test_2x_gumm_mod_accessible_via_diraccess() -> void:
	assert_true(FileAccess.file_exists("res://System/2.x/GUMM_mod.gd"),
		"2.x GUMM_mod.gd should be accessible via FileAccess despite .gdignore")


func test_2x_mod_template_accessible_via_diraccess() -> void:
	assert_true(FileAccess.file_exists("res://System/2.x/mod.gd"),
		"2.x mod.gd should be accessible via FileAccess despite .gdignore")


func test_2x_loader_scene_accessible_via_diraccess() -> void:
	assert_true(FileAccess.file_exists("res://System/2.x/GUMM_mod_loader.tscn"),
		"2.x loader scene should be accessible via FileAccess despite .gdignore")


# -- 3.x compat layer file accessibility --

func test_3x_gumm_mod_accessible_via_diraccess() -> void:
	assert_true(FileAccess.file_exists("res://System/3.x/GUMM_mod.gd"),
		"3.x GUMM_mod.gd should be accessible via FileAccess despite .gdignore")


func test_3x_mod_template_accessible_via_diraccess() -> void:
	assert_true(FileAccess.file_exists("res://System/3.x/mod.gd"),
		"3.x mod.gd should be accessible via FileAccess despite .gdignore")


func test_3x_loader_scene_accessible_via_diraccess() -> void:
	assert_true(FileAccess.file_exists("res://System/3.x/GUMM_mod_loader.tscn"),
		"3.x loader scene should be accessible via FileAccess despite .gdignore")


# -- 2.x scene format correctness --

func test_2x_loader_scene_uses_format_1() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("format=1"),
		"2.x loader scene must use Scene format 1 (Godot 2.x)")


func test_2x_loader_uses_globals_api() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("Globals.get("),
		"2.x loader must use Globals.get() (Godot 2.x API)")


func test_2x_loader_uses_change_scene_string() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("change_scene("),
		"2.x loader must use change_scene() with string path")


# -- 2.x GUMM_mod.gd API correctness --

func test_2x_mod_extends_reference() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod.gd")
	assert_true(content.begins_with("extends Reference"),
		"2.x GUMM_mod must extend Reference (not RefCounted)")


func test_2x_mod_uses_image_constructor() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod.gd")
	assert_true(content.contains("Image()"),
		"2.x GUMM_mod must use Image() constructor (not Image.new())")


func test_2x_mod_uses_plus_file() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod.gd")
	assert_true(content.contains("plus_file("),
		"2.x GUMM_mod must use plus_file() (not path_join)")


func test_2x_mod_does_not_use_4x_apis() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod.gd")
	assert_false(content.contains("RefCounted"),
		"2.x GUMM_mod must not reference RefCounted (4.x class)")
	assert_false(content.contains("path_join"),
		"2.x GUMM_mod must not use path_join (4.x method)")
	assert_false(content.contains("load_from_file"),
		"2.x GUMM_mod must not use Image.load_from_file (4.x method)")


# -- 3.x scene format correctness --

func test_3x_loader_scene_uses_format_2() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("format=2"),
		"3.x loader scene must use Scene format 2 (Godot 3.x)")


func test_3x_loader_uses_project_settings() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("ProjectSettings.get_setting("),
		"3.x loader must use ProjectSettings.get_setting() (not Globals.get)")


func test_3x_loader_uses_change_scene_string() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("change_scene("),
		"3.x loader must use change_scene() with string path")


# -- 3.x GUMM_mod.gd API correctness --

func test_3x_mod_extends_reference() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod.gd")
	assert_true(content.begins_with("extends Reference"),
		"3.x GUMM_mod must extend Reference (not RefCounted)")


func test_3x_mod_uses_file_class() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod.gd")
	assert_true(content.contains("File.new()"),
		"3.x GUMM_mod must use File class (not FileAccess)")


func test_3x_mod_uses_plus_file() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod.gd")
	assert_true(content.contains("plus_file("),
		"3.x GUMM_mod must use plus_file() (not path_join)")


func test_3x_mod_has_ogg_loader() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod.gd")
	assert_true(content.contains("func load_ogg("),
		"3.x GUMM_mod should have OGG loader (available in Godot 3.x)")


func test_3x_mod_has_mp3_loader() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod.gd")
	assert_true(content.contains("func load_mp3("),
		"3.x GUMM_mod should have MP3 loader")


func test_3x_mod_does_not_use_4x_apis() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod.gd")
	assert_false(content.contains("RefCounted"),
		"3.x GUMM_mod must not reference RefCounted (4.x class)")
	assert_false(content.contains("path_join"),
		"3.x GUMM_mod must not use path_join (4.x method)")
	assert_false(content.contains("FileAccess"),
		"3.x GUMM_mod must not use FileAccess (4.x class)")


# -- Mod template correctness --

func test_2x_mod_template_extends_gumm_mod() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/mod.gd")
	assert_true(content.contains('extends "GUMM_mod.gd"'),
		"2.x mod template must extend GUMM_mod.gd")


func test_3x_mod_template_extends_gumm_mod() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/mod.gd")
	assert_true(content.contains('extends "GUMM_mod.gd"'),
		"3.x mod template must extend GUMM_mod.gd")


func test_2x_mod_template_has_initialize_hook() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/mod.gd")
	assert_true(content.contains("func _initialize(scene_tree)"),
		"2.x mod template must have _initialize override point")


func test_3x_mod_template_has_initialize_hook() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/mod.gd")
	assert_true(content.contains("func _initialize(scene_tree)"),
		"3.x mod template must have _initialize override point")


# -- Version-specific loader features --

func test_2x_loader_reads_mod_cfg() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("mod.cfg"),
		"2.x loader must read mod.cfg for mod metadata")


func test_3x_loader_reads_mod_cfg() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod_loader.tscn")
	assert_true(content.contains("mod.cfg"),
		"3.x loader must read mod.cfg for mod metadata")


func test_2x_loader_stores_mods_in_tree_meta() -> void:
	var content := FileAccess.get_file_as_string("res://System/2.x/GUMM_mod_loader.tscn")
	assert_true(content.contains('set_meta(\\"GUMM_mods\\"'),
		"2.x loader must store loaded mods in tree metadata")


func test_3x_loader_stores_mods_in_tree_meta() -> void:
	var content := FileAccess.get_file_as_string("res://System/3.x/GUMM_mod_loader.tscn")
	assert_true(content.contains('set_meta(\\"GUMM_mods\\"'),
		"3.x loader must store loaded mods in tree metadata")
