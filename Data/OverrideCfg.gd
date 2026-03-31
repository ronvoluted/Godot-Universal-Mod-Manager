extends RefCounted
class_name OverrideCfg
## Manages override.cfg, the core mechanism GUMM uses to inject mods into games.
##
## Godot loads override.cfg from the game directory at startup, letting GUMM
## redirect the main scene (2.x/3.x) or register an autoload (4.x) that
## bootstraps mod loading.

static func get_override_path(game: GameData) -> String:
	return game.game_path.path_join("override.cfg")

static func apply(game: GameData) -> Error:
	var override_path := get_override_path(game)
	var config := ConfigFile.new()
	if FileAccess.file_exists(override_path):
		config.load(override_path)

	var copy_err: Error
	match game.entry.godot_version:
		"2.x":
			config.set_value("application", "main_scene", "res://" + GameData.mod_loader_scene)
			copy_err = DirAccess.copy_absolute("res://System/2.x/%s" % GameData.mod_loader_scene, game.game_path.path_join(GameData.mod_loader_scene))
			if copy_err != OK:
				push_error("Failed to copy mod loader scene for 2.x (error %d)." % copy_err)
			config.set_value("gumm", "main_scene", game.entry.main_scene)
		"3.x":
			config.set_value("application", "run/main_scene", "res://" + GameData.mod_loader_scene)
			copy_err = DirAccess.copy_absolute("res://System/3.x/%s" % GameData.mod_loader_scene, game.game_path.path_join(GameData.mod_loader_scene))
			if copy_err != OK:
				push_error("Failed to copy mod loader scene for 3.x (error %d)." % copy_err)
			config.set_value("gumm", "main_scene", game.entry.main_scene)
		"4.x":
			copy_err = DirAccess.copy_absolute("res://System/4.x/" + GameData.mod_loader_autoload, game.game_path.path_join(GameData.mod_loader_autoload))
			if copy_err != OK:
				push_error("Failed to copy mod loader autoload for 4.x (error %d)." % copy_err)
			config.set_value("autoload", "GUMM", "*res://" + GameData.mod_loader_autoload)

	config.set_value("gumm", "mod_list", game.installed_mods.filter(func(mod: ModData) -> bool: return mod.active).map(func(mod: ModData) -> String: return mod.load_path))

	var save_err := config.save(override_path)
	if save_err != OK:
		push_error("Failed to save override.cfg to '%s' (error %d)." % [override_path, save_err])
	return save_err

static func remove(game: GameData) -> void:
	var override_path := get_override_path(game)
	var config := ConfigFile.new()
	config.load(override_path)

	var deleted := false
	var config_sections := config.get_sections()
	if config_sections.size() == 1 or config_sections.size() == 2:
		match game.entry.godot_version:
			"2.x", "3.x":
				var has := int("application" in config_sections) + int("gumm" in config_sections)
				if has == config_sections.size() and config.get_section_keys("application").size() == 1:
					DirAccess.remove_absolute(override_path)
					deleted = true
			"4.x":
				var has := int("autoload" in config_sections) + int("gumm" in config_sections)
				if has == config_sections.size() and config.get_section_keys("autoload").size() == 1:
					DirAccess.remove_absolute(override_path)
					deleted = true

	if not deleted:
		match game.entry.godot_version:
			"2.x":
				config.erase_section_key("application", "main_scene")
			"3.x":
				config.erase_section_key("application", "run/main_scene")
			"4.x":
				config.erase_section_key("autoload", "GUMM")
				if config.has_section("autoload") and config.get_section_keys("autoload").is_empty():
					config.erase_section("autoload")

		if config.has_section("gumm"):
			config.erase_section("gumm")
		config.save(override_path)

	match game.entry.godot_version:
		"2.x", "3.x":
			DirAccess.remove_absolute(game.game_path.path_join(GameData.mod_loader_scene))
		"4.x":
			DirAccess.remove_absolute(game.game_path.path_join(GameData.mod_loader_autoload))

static func is_disabled(game: GameData) -> bool:
	var project_cfg_path := game.game_path.path_join("project.godot")
	if not FileAccess.file_exists(project_cfg_path):
		return false
	var config := ConfigFile.new()
	if config.load(project_cfg_path) != OK:
		return false
	return config.get_value("application", "config/disable_project_settings_override", false)
