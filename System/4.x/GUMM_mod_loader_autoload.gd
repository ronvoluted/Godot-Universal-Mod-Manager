extends Node

var loaded_mods: Array[RefCounted] = []

func _enter_tree() -> void:
	var mod_list: PackedStringArray = ProjectSettings.get_setting("gumm/mod_list")
	for mod: String in mod_list:
		load_mod(mod)
	get_tree().set_meta(&"GUMM_mods", loaded_mods)

func load_mod(mod_path: String) -> void:
	var mod_cfg := ConfigFile.new()
	mod_cfg.load(mod_path.path_join("mod.cfg"))
	print("Loading mod: ", mod_cfg.get_value("Godot Mod", "name", "[unknown]"))

	var script: GDScript = load(mod_path.path_join("mod.gd"))
	if not script:
		push_error("GUMM: Failed to load mod script: %s" % mod_path.path_join("mod.gd"))
		return

	var mod_ref: RefCounted = script.new()
	mod_ref.initialize(mod_path, get_tree())
	loaded_mods.append(mod_ref)
