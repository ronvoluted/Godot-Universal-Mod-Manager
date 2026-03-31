extends GutTest


# -- GH-70096: Dictionary keys default to StringName in GDScript --


func test_literal_dictionary_keys_are_stringname() -> void:
	var dict := {name = "test", value = 42}
	for key: Variant in dict.keys():
		assert_typeof(key, TYPE_STRING_NAME)


func test_stringname_key_accessible_with_string() -> void:
	var dict := {name = "test"}
	assert_eq(dict[&"name"], "test")
	assert_eq(dict["name"], "test")


func test_string_key_accessible_with_stringname() -> void:
	var dict: Dictionary = {}
	dict["name"] = "test"
	assert_eq(dict[&"name"], "test")
	assert_eq(dict["name"], "test")


func test_has_works_with_both_key_types() -> void:
	var dict := {active = true}
	assert_true(dict.has(&"active"))
	assert_true(dict.has("active"))


func test_merge_string_and_stringname_keys() -> void:
	var base := {name = "original"}
	var override: Dictionary = {}
	override["name"] = "updated"
	base.merge(override, true)
	assert_eq(base[&"name"], "updated")


func test_dot_access_works_with_stringname_keys() -> void:
	var dict := {load_path = "/mods/test", active = true}
	assert_eq(dict.load_path, "/mods/test")
	assert_eq(dict.active, true)


# -- Registry.gd: GameData dictionary interop --


func test_game_data_get_var_returns_stringname_keys() -> void:
	var game := Registry.GameData.new({})
	var result := game.get_var()
	for key: Variant in result.keys():
		assert_typeof(key, TYPE_STRING_NAME)


func test_game_data_defaults_use_stringname_keys() -> void:
	var defaults := Registry.GameData._defaults
	for key: Variant in defaults.keys():
		assert_typeof(key, TYPE_STRING_NAME)


func test_mod_data_get_var_returns_stringname_keys() -> void:
	var mod := Registry.GameData.ModData.new({})
	var result := mod.get_var()
	for key: Variant in result.keys():
		assert_typeof(key, TYPE_STRING_NAME)


func test_mod_data_defaults_use_stringname_keys() -> void:
	var defaults := Registry.GameData.ModData._defaults
	for key: Variant in defaults.keys():
		assert_typeof(key, TYPE_STRING_NAME)


func test_game_data_merge_preserves_string_input_values() -> void:
	var input: Dictionary = {}
	input["entry_path"] = "/games/test"
	var game := Registry.GameData.new(input)
	assert_eq(game.entry_path, "/games/test")


func test_mod_data_merge_preserves_string_input_values() -> void:
	var input: Dictionary = {}
	input["load_path"] = "/mods/test"
	var mod := Registry.GameData.ModData.new(input)
	assert_eq(mod.load_path, "/mods/test")
