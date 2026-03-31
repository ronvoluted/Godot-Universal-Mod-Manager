extends GutTest
## Verify System/4.x mod loader files are updated for Godot 4.6 conventions.
## Checks type safety, StringName meta keys, consistent path resolution,
## and alignment with the project's threaded loading pattern.


# -- GUMM_mod_loader.tscn type safety --

func test_mod_loader_script_has_typed_loaded_mods() -> void:
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	var source: String = node.get_script().source_code
	assert_true(source.contains("Array[RefCounted]"),
		"loaded_mods should be typed as Array[RefCounted]")
	node.free()


func test_mod_loader_script_has_typed_for_loop() -> void:
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	var source: String = node.get_script().source_code
	assert_true(source.contains("for mod: String in"),
		"for loop should have typed iteration variable")
	node.free()


func test_mod_loader_script_has_typed_mod_list() -> void:
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	var source: String = node.get_script().source_code
	assert_true(source.contains("var mod_list: PackedStringArray"),
		"mod_list should be typed as PackedStringArray")
	node.free()


func test_mod_loader_script_has_return_types() -> void:
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	var source: String = node.get_script().source_code
	assert_true(source.contains("func _ready() -> void"),
		"_ready should have void return type")
	assert_true(source.contains("func load_mod(mod_path: String) -> void"),
		"load_mod should have void return type")
	node.free()


# -- Inline threaded loading (no separate helper for scene transition) --

func test_mod_loader_inlines_scene_transition_loading() -> void:
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	var source: String = node.get_script().source_code
	assert_true(source.contains("change_scene_to_packed("),
		"should use change_scene_to_packed for loaded scenes")
	assert_true(source.contains("change_scene_to_file("),
		"should fall back to change_scene_to_file on error")
	node.free()


# -- StringName meta keys --

func test_mod_loader_scene_uses_stringname_meta_key() -> void:
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	var source: String = node.get_script().source_code
	assert_true(source.contains('set_meta(&"GUMM_mods"'),
		"should use StringName literal for meta key")
	node.free()


func test_autoload_loader_uses_stringname_meta_key() -> void:
	var source: String = load("res://System/4.x/GUMM_mod_loader_autoload.gd").source_code
	assert_true(source.contains('set_meta(&"GUMM_mods"'),
		"autoload loader should use StringName literal for meta key")


# -- GUMM_mod.gd load_mp3 path resolution --

func test_gumm_mod_load_mp3_uses_get_full_path() -> void:
	var source: String = load("res://System/4.x/GUMM_mod.gd").source_code
	var in_load_mp3 := false
	for line: String in source.split("\n"):
		var stripped := line.strip_edges()
		if stripped.begins_with("func load_mp3"):
			in_load_mp3 = true
		elif in_load_mp3 and stripped.begins_with("func "):
			break
		elif in_load_mp3 and stripped.contains("get_full_path"):
			pass_test("load_mp3 resolves mod:// paths via get_full_path")
			return
	fail_test("load_mp3 should call get_full_path to resolve mod:// paths")


func test_gumm_mod_load_mp3_has_null_guard() -> void:
	var source: String = load("res://System/4.x/GUMM_mod.gd").source_code
	var in_load_mp3 := false
	for line: String in source.split("\n"):
		var stripped := line.strip_edges()
		if stripped.begins_with("func load_mp3"):
			in_load_mp3 = true
		elif in_load_mp3 and stripped.begins_with("func "):
			break
		elif in_load_mp3 and stripped.contains("not file"):
			pass_test("load_mp3 guards against null FileAccess")
			return
	fail_test("load_mp3 should guard against FileAccess.open returning null")


# -- GUMM_mod.gd path resolution consistency --

func test_all_load_methods_use_get_full_path() -> void:
	var source: String = load("res://System/4.x/GUMM_mod.gd").source_code
	var load_methods: PackedStringArray = ["load_texture", "load_mp3", "load_resource", "load_resource_threaded"]
	for method: String in load_methods:
		var in_method := false
		var found := false
		for line: String in source.split("\n"):
			var stripped := line.strip_edges()
			if stripped.begins_with("func %s" % method):
				in_method = true
			elif in_method and stripped.begins_with("func "):
				break
			elif in_method and stripped.contains("get_full_path"):
				found = true
				break
		assert_true(found, "%s should call get_full_path for consistent path resolution" % method)
