extends GutTest
## Verify typed Dictionary[String, Variant] annotations in Registry.gd.
## Coverage for Godot GH-78656 (typed dictionary support in 4.4).


# -- ModData typed dictionary --

func test_mod_data_defaults_is_typed_dictionary() -> void:
	var defaults := Registry.GameData.ModData._defaults
	assert_true(defaults is Dictionary[String, Variant])


func test_mod_data_get_var_returns_typed_dictionary() -> void:
	var mod := Registry.GameData.ModData.new({load_path = "/mods/test", active = true})
	var result := mod.get_var()
	assert_true(result is Dictionary[String, Variant])


func test_mod_data_get_var_has_expected_keys() -> void:
	var mod := Registry.GameData.ModData.new({load_path = "/mods/test", active = true})
	var result := mod.get_var()
	assert_true(result.has("load_path"))
	assert_true(result.has("active"))
	assert_eq(result.size(), 2)


func test_mod_data_get_var_preserves_load_path() -> void:
	var mod := Registry.GameData.ModData.new({load_path = "/mods/test", active = true})
	assert_eq(mod.get_var()["load_path"], "/mods/test")


# -- GameData typed dictionary --

func test_game_data_defaults_is_typed_dictionary() -> void:
	var defaults := Registry.GameData._defaults
	assert_true(defaults is Dictionary[String, Variant])


func test_game_data_get_var_returns_typed_dictionary() -> void:
	var game := Registry.GameData.new({entry_path = "/test", game_path = "/gp", installed_mods = []})
	var result := game.get_var()
	assert_true(result is Dictionary[String, Variant])


func test_game_data_get_var_has_expected_keys() -> void:
	var game := Registry.GameData.new({entry_path = "/test", game_path = "/gp", installed_mods = []})
	var result := game.get_var()
	assert_true(result.has("entry_path"))
	assert_true(result.has("game_path"))
	assert_true(result.has("mods_enabled"))
	assert_true(result.has("installed_mods"))
	assert_eq(result.size(), 4)


func test_game_data_get_var_preserves_values() -> void:
	var game := Registry.GameData.new({entry_path = "/test/path", game_path = "/gp/path", installed_mods = []})
	var result := game.get_var()
	assert_eq(result["entry_path"], "/test/path")
	assert_eq(result["game_path"], "/gp/path")


# -- Typed dict survives serialization round-trip --

func test_typed_dict_round_trip_via_var_to_str() -> void:
	var game := Registry.GameData.new({entry_path = "/rt", game_path = "/gp", installed_mods = []})
	var dict := game.get_var()
	var serialized := var_to_str([dict])
	var deserialized: Array = str_to_var(serialized)
	assert_eq(deserialized[0]["entry_path"], "/rt")
	assert_eq(deserialized[0]["game_path"], "/gp")


func test_typed_dict_mod_round_trip() -> void:
	var game := Registry.GameData.new({
		entry_path = "/rt",
		game_path = "/gp",
		installed_mods = [{load_path = "/mods/a", active = true}],
	})
	var serialized := var_to_str([game.get_var()])
	var deserialized: Array = str_to_var(serialized)
	var restored := Registry.GameData.new(deserialized[0])
	assert_eq(restored.installed_mods.size(), 1)
	assert_eq(restored.installed_mods[0].load_path, "/mods/a")


# -- Deserialized (untyped) dicts accepted by _init --

func test_untyped_dict_accepted_by_mod_data() -> void:
	# str_to_var returns untyped Dictionary; _init must accept it
	var data: Dictionary = {load_path = "/mods/from_str", active = true}
	var mod := Registry.GameData.ModData.new(data)
	assert_eq(mod.load_path, "/mods/from_str")


func test_untyped_dict_accepted_by_game_data() -> void:
	var data: Dictionary = {entry_path = "/ep", game_path = "/gp", installed_mods = []}
	var game := Registry.GameData.new(data)
	assert_eq(game.entry_path, "/ep")
	assert_eq(game.game_path, "/gp")
