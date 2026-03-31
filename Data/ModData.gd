extends RefCounted
class_name ModData

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
