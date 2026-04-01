extends RefCounted
class_name GameData

static var mod_loader_scene := "GUMM_mod_loader.tscn"
static var mod_loader_autoload := "GUMM_mod_loader_autoload.gd"

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
	mods_enabled = FileAccess.file_exists(game_path.path_join(mod_loader_scene)) or FileAccess.file_exists(game_path.path_join(mod_loader_autoload))

	entry = GameDescriptor.new()
	entry.load_data(entry_path)

	installed_mods.assign(Array(config.installed_mods).map(ModData.new))

func get_var() -> Dictionary[StringName, Variant]:
	var mods := installed_mods.map(func(mod: ModData) -> Dictionary[StringName, Variant]: return mod.get_var())
	return {entry_path = entry_path, game_path = game_path, mods_enabled = mods_enabled, installed_mods = mods}
