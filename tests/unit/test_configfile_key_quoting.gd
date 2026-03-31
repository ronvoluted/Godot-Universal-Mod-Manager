extends GutTest
## Verify ConfigFile keys with special characters roundtrip correctly.
## Regression coverage for Godot GH-52180 (ConfigFile key quoting).

var tmp_dir := "user://test_configfile_key_quoting"


func before_each():
	DirAccess.make_dir_recursive_absolute(tmp_dir)


func after_each():
	var dir := DirAccess.open(tmp_dir)
	if dir:
		for file in dir.get_files():
			DirAccess.remove_absolute(tmp_dir.path_join(file))
	DirAccess.remove_absolute(tmp_dir)


# -- override.cfg: slash in key (run/main_scene) --

func test_override_cfg_slash_key_roundtrip():
	var path := tmp_dir.path_join("override.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://GUMM_Loader.tscn")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("application", "run/main_scene"), "res://GUMM_Loader.tscn")


func test_override_cfg_gumm_section_with_slash_key():
	var path := tmp_dir.path_join("override.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://GUMM_Loader.tscn")
	cfg.set_value("gumm", "main_scene", "res://Main.tscn")
	cfg.set_value("gumm", "mod_list", PackedStringArray(["mod_a", "mod_b"]))
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("application", "run/main_scene"), "res://GUMM_Loader.tscn")
	assert_eq(loaded.get_value("gumm", "main_scene"), "res://Main.tscn")
	assert_eq(loaded.get_value("gumm", "mod_list"), PackedStringArray(["mod_a", "mod_b"]))


func test_override_cfg_erase_slash_key():
	var path := tmp_dir.path_join("override.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://GUMM_Loader.tscn")
	cfg.save(path)

	var loaded := ConfigFile.new()
	loaded.load(path)
	loaded.erase_section_key("application", "run/main_scene")
	loaded.save(path)

	var reloaded := ConfigFile.new()
	assert_eq(reloaded.load(path), OK)
	assert_false(reloaded.has_section_key("application", "run/main_scene"))


# -- game.cfg: section name with space ("Godot Game") --

func test_game_cfg_section_with_space():
	var path := tmp_dir.path_join("game.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("Godot Game", "title", "Test Game")
	cfg.set_value("Godot Game", "godot_version", "4.x")
	cfg.set_value("Godot Game", "main_scene", "res://Main.tscn")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("Godot Game", "title"), "Test Game")
	assert_eq(loaded.get_value("Godot Game", "godot_version"), "4.x")
	assert_eq(loaded.get_value("Godot Game", "main_scene"), "res://Main.tscn")


# -- mod.cfg: section name with space ("Godot Mod") --

func test_mod_cfg_section_with_space():
	var path := tmp_dir.path_join("mod.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("Godot Mod", "game", "Test Game")
	cfg.set_value("Godot Mod", "name", "Cool Mod")
	cfg.set_value("Godot Mod", "description", "A cool mod")
	cfg.set_value("Godot Mod", "version", "1.0.0")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("Godot Mod", "game"), "Test Game")
	assert_eq(loaded.get_value("Godot Mod", "name"), "Cool Mod")


# -- Keys with special characters --

func test_key_with_spaces():
	var path := tmp_dir.path_join("special.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("section", "key with spaces", "value")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("section", "key with spaces"), "value")


func test_key_with_dots():
	var path := tmp_dir.path_join("special.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("section", "network.server.port", 8080)
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("section", "network.server.port"), 8080)


func test_key_with_equals():
	var path := tmp_dir.path_join("special.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("section", "key=value", "data")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("section", "key=value"), "data")


func test_key_with_unicode():
	var path := tmp_dir.path_join("special.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("section", "日本語キー", "value")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("section", "日本語キー"), "value")


func test_key_with_brackets():
	var path := tmp_dir.path_join("special.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("section", "key[0]", "first")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("section", "key[0]"), "first")


func test_value_with_special_characters():
	var path := tmp_dir.path_join("special.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("Godot Mod", "description", 'Replaces "all" enemies & adds new boss [v2]')
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("Godot Mod", "description"), 'Replaces "all" enemies & adds new boss [v2]')


# -- Mixed special characters in a single file --

func test_mixed_special_keys_in_single_file():
	var path := tmp_dir.path_join("mixed.cfg")
	var cfg := ConfigFile.new()
	cfg.set_value("application", "run/main_scene", "res://Main.tscn")
	cfg.set_value("application", "config/name", "My Game")
	cfg.set_value("display", "window/size/viewport_width", 1920)
	cfg.set_value("Godot Game", "title", "Test")
	cfg.save(path)

	var loaded := ConfigFile.new()
	assert_eq(loaded.load(path), OK)
	assert_eq(loaded.get_value("application", "run/main_scene"), "res://Main.tscn")
	assert_eq(loaded.get_value("application", "config/name"), "My Game")
	assert_eq(loaded.get_value("display", "window/size/viewport_width"), 1920)
	assert_eq(loaded.get_value("Godot Game", "title"), "Test")


# -- Descriptor roundtrips with special character values --

func test_game_descriptor_special_title():
	var descriptor := GameDescriptor.new()
	descriptor.title = 'Game "Deluxe" [2024]'
	descriptor.godot_version = "4.x"
	descriptor.main_scene = "res://Scenes/Main Scene.tscn"
	descriptor.save_data(tmp_dir)

	var loaded := GameDescriptor.new()
	assert_true(loaded.load_data(tmp_dir))
	assert_eq(loaded.title, 'Game "Deluxe" [2024]')
	assert_eq(loaded.main_scene, "res://Scenes/Main Scene.tscn")


func test_mod_descriptor_special_values():
	var descriptor := ModDescriptor.new()
	descriptor.game = 'Game "Deluxe" [2024]'
	descriptor.name = "Über Mod/Patch"
	descriptor.description = "Fixes bug #42 & adds <new> feature"
	descriptor.version = "2.0.0-beta.1"
	descriptor.save_data(tmp_dir)

	var loaded := ModDescriptor.new()
	assert_true(loaded.load_data(tmp_dir))
	assert_eq(loaded.game, 'Game "Deluxe" [2024]')
	assert_eq(loaded.name, "Über Mod/Patch")
	assert_eq(loaded.description, "Fixes bug #42 & adds <new> feature")
	assert_eq(loaded.version, "2.0.0-beta.1")
