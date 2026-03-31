extends Node

const GAME_ENTRIES_FILE = "user://game_list.txt"
const ICON_FORMATS: PackedStringArray = ["png", "jpg"]

var games: Array[GameData]

func _enter_tree() -> void:
	var game_entries := FileAccess.open(GAME_ENTRIES_FILE, FileAccess.READ)
	if game_entries:
		var game_list: Array = str_to_var(game_entries.get_as_text())
		games.assign(game_list.map(GameData.new))

func save_game_entry_list() -> Error:
	var game_entries := FileAccess.open(GAME_ENTRIES_FILE, FileAccess.WRITE)
	if not game_entries:
		return FileAccess.get_open_error()
	var game_list := games.map(func(game: GameData) -> Dictionary[StringName, Variant]: return game.get_var())
	game_entries.store_string(var_to_str(game_list))
	return game_entries.get_error()

func add_new_game_entry(entry_path: String, game_path: String) -> GameData:
	var game := GameData.new({entry_path = entry_path, game_path = game_path, installed_mods = []})
	games.append(game)
	save_game_entry_list()
	return game

func add_new_mod_entry(game: GameData, load_path: String) -> GameData.ModData:
	var mod := GameData.ModData.new({load_path = load_path, active = true})
	
	var dir := DirAccess.open(load_path)
	var existing_index := game.installed_mods.find_custom(func(mod_meta: GameData.ModData) -> bool: return dir and dir.is_equivalent(mod_meta.load_path, load_path))
	if existing_index != -1:
		game.installed_mods[existing_index].load_path = load_path
		return game.installed_mods[existing_index]
	
	game.installed_mods.append(mod)
	save_game_entry_list()
	return mod

func remove_game_entry(game: GameData) -> void:
	games.erase(game)
	save_game_entry_list()

func remove_mod_entry(game: GameData, mod: GameData.ModData) -> void:
	game.installed_mods.erase(mod)
	save_game_entry_list()

func smart_resize_to_80(image: Image) -> void:
	if image.get_width() == image.get_height():
		image.resize(80, 80, Image.INTERPOLATE_LANCZOS)
	elif image.get_width() > image.get_height():
		image.resize(80, roundi(80.0 * image.get_height() / image.get_width()))
	elif image.get_width() < image.get_height():
		image.resize(roundi(80.0 * image.get_width() / image.get_height()), 80)
	else:
		get_tree().quit(1) # impossible

class GameData:
	static var mod_loader_scene := "GUMM_mod_loader.tscn"

	class ModData:
		static var _defaults: Dictionary[StringName, Variant] = {load_path = "", active = false}

		var load_path: String
		var active: bool
		var entry: ModDescriptor

		func _init(data: Dictionary) -> void:
			var config: Dictionary[StringName, Variant] = _defaults.duplicate()
			config.merge(data, true)
			load_path = config.load_path
			active = config.active

			entry = ModDescriptor.new()
			if not entry.load_data(load_path):
				active = false

		func get_var() -> Dictionary[StringName, Variant]:
			return {load_path = load_path, active = active}

	static var _defaults: Dictionary[StringName, Variant] = {entry_path = "", game_path = "", installed_mods = []}

	var entry: GameDescriptor
	var entry_path: String
	var game_path: String
	var mods_enabled: bool
	var installed_mods: Array[ModData]

	func _init(data: Dictionary) -> void:
		var config: Dictionary[StringName, Variant] = _defaults.duplicate()
		config.merge(data, true)
		entry_path = config.entry_path
		game_path = config.game_path
		mods_enabled = FileAccess.file_exists(game_path.path_join(mod_loader_scene))

		entry = GameDescriptor.new()
		entry.load_data(entry_path)

		installed_mods.assign(Array(config.installed_mods).map(ModData.new))

	func get_var() -> Dictionary[StringName, Variant]:
		var mods := installed_mods.map(func(mod: ModData) -> Dictionary[StringName, Variant]: return mod.get_var())
		return {entry_path = entry_path, game_path = game_path, mods_enabled = mods_enabled, installed_mods = mods}
