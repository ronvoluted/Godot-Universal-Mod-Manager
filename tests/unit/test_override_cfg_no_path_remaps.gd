extends GutTest
## Verify override.cfg and Resource.take_over_path() are unaffected by the
## removal of the old path remaps system (GH-91594). The mod manager writes
## standard ConfigFile sections ("application", "gumm") and uses
## take_over_path() for runtime resource replacement — neither depends on the
## removed path_remap mechanism.


# -- override.cfg uses standard ConfigFile, not path remaps --

func test_override_cfg_roundtrips_main_scene() -> void:
	var path := "user://test_override.cfg"
	var config := ConfigFile.new()
	config.set_value("application", "run/main_scene", "res://GUMM_mod_loader.tscn")
	config.set_value("gumm", "main_scene", "res://Scenes/Main.tscn")
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(
		loaded.get_value("application", "run/main_scene"),
		"res://GUMM_mod_loader.tscn",
		"override.cfg should preserve application/run/main_scene"
	)
	assert_eq(
		loaded.get_value("gumm", "main_scene"),
		"res://Scenes/Main.tscn",
		"override.cfg should preserve gumm/main_scene"
	)

	DirAccess.remove_absolute(path)


func test_override_cfg_roundtrips_mod_list() -> void:
	var path := "user://test_override_mods.cfg"
	var mod_list: Array[String] = ["mods/ModA", "mods/ModB"]
	var config := ConfigFile.new()
	config.set_value("gumm", "mod_list", mod_list)
	config.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	var restored: Array = loaded.get_value("gumm", "mod_list")
	assert_eq(restored.size(), 2, "mod_list should round-trip with correct size")
	assert_eq(str(restored[0]), "mods/ModA")
	assert_eq(str(restored[1]), "mods/ModB")

	DirAccess.remove_absolute(path)


func test_override_cfg_contains_no_path_remap_section() -> void:
	var path := "user://test_override_no_remap.cfg"
	var config := ConfigFile.new()
	config.set_value("application", "run/main_scene", "res://GUMM_mod_loader.tscn")
	config.set_value("gumm", "main_scene", "res://Scenes/Main.tscn")
	config.save(path)

	var loaded := ConfigFile.new()
	loaded.load(path)
	for section: String in loaded.get_sections():
		assert_false(
			section.contains("path_remap"),
			"override.cfg should not contain path_remap sections (GH-91594)"
		)

	DirAccess.remove_absolute(path)


# -- Resource.take_over_path() still works for runtime replacement --

func test_take_over_path_replaces_resource() -> void:
	var original_path := "user://test_takeover_target.tres"

	var original := Resource.new()
	original.resource_path = original_path

	var replacement := Resource.new()
	replacement.take_over_path(original_path)

	assert_eq(
		replacement.resource_path, original_path,
		"take_over_path() should assign the target path to the replacement resource"
	)
	assert_ne(
		original.resource_path, original_path,
		"take_over_path() should clear the path from the original resource"
	)


func test_take_over_path_makes_resource_loadable() -> void:
	var target_path := "user://test_takeover_load.tres"
	var res := Resource.new()
	ResourceSaver.save(res, target_path)

	var replacement := Resource.new()
	replacement.set_meta("gumm_mod", true)
	replacement.take_over_path(target_path)

	var loaded := ResourceLoader.load(target_path)
	assert_not_null(loaded, "Should be able to load resource at taken-over path")
	assert_true(
		loaded.get_meta("gumm_mod", false),
		"Loading a taken-over path should return the replacement resource"
	)

	replacement.resource_path = ""
	DirAccess.remove_absolute(target_path)


func test_take_over_path_persists_with_storage_array() -> void:
	var target_path := "user://test_takeover_storage.tres"
	var storage: Array[Resource] = []

	var res := Resource.new()
	ResourceSaver.save(res, target_path)

	var replacement := Resource.new()
	replacement.set_meta("stored", true)
	replacement.take_over_path(target_path)
	storage.append(replacement)

	var loaded := ResourceLoader.load(target_path)
	assert_true(
		loaded.get_meta("stored", false),
		"Resource held in storage array should remain loadable at taken-over path"
	)

	storage.clear()
	DirAccess.remove_absolute(target_path)
