extends GutTest
## Verify var_to_str/str_to_var serialization round-trips correctly.
## Regression coverage for Godot GH-78219 (typed array serialization change in 4.3).
## Legacy coverage: Registry.gd previously used these functions for persistence
## (now uses ConfigFile). These tests remain for Godot engine regression coverage
## and to validate the legacy migration path in Registry._load_legacy().


# -- Round-trip: primitives and collections --

func test_round_trip_empty_array() -> void:
	var original: Array = []
	var result: Variant = str_to_var(var_to_str(original))
	assert_eq(result, [])
	assert_true(result is Array)


func test_round_trip_array_of_dictionaries() -> void:
	var original: Array = [
		{entry_path = "/path/a", game_path = "/game/a", installed_mods = []},
		{entry_path = "/path/b", game_path = "/game/b", installed_mods = []},
	]
	var result: Variant = str_to_var(var_to_str(original))
	assert_eq(result.size(), 2)
	assert_eq(result[0]["entry_path"], "/path/a")
	assert_eq(result[1]["game_path"], "/game/b")
	assert_eq(result[1]["installed_mods"], [])


func test_round_trip_nested_mod_dictionaries() -> void:
	var original: Array = [{
		entry_path = "/path/a",
		game_path = "/game/a",
		installed_mods = [
			{load_path = "/mods/x", active = true},
			{load_path = "/mods/y", active = false},
		],
	}]
	var result: Variant = str_to_var(var_to_str(original))
	assert_eq(result[0]["installed_mods"].size(), 2)
	assert_eq(result[0]["installed_mods"][0]["load_path"], "/mods/x")
	assert_true(result[0]["installed_mods"][0]["active"])
	assert_false(result[0]["installed_mods"][1]["active"])


# -- Pre-4.3 format compatibility: untyped array literal strings --

func test_pre_43_empty_game_list_loads() -> void:
	# Pre-4.3 var_to_str output for an empty array
	var saved := "[  ]"
	var result: Variant = str_to_var(saved)
	assert_not_null(result, "str_to_var should parse pre-4.3 empty array")
	assert_eq(result, [])


func test_pre_43_single_game_loads() -> void:
	# Simulates a game_list.txt written by a pre-4.3 Godot engine
	var saved := '[{\n"entry_path": "/games/rpg",\n"game_path": "/usr/games/rpg",\n"installed_mods": [  ],\n"mods_enabled": false\n}]'
	var result: Variant = str_to_var(saved)
	assert_not_null(result, "str_to_var should parse pre-4.3 single game entry")
	assert_eq(result.size(), 1)
	assert_eq(result[0]["entry_path"], "/games/rpg")
	assert_eq(result[0]["game_path"], "/usr/games/rpg")
	assert_eq(result[0]["installed_mods"], [])


func test_pre_43_game_with_mods_loads() -> void:
	var saved := '[{\n"entry_path": "/games/rpg",\n"game_path": "/usr/games/rpg",\n"installed_mods": [{\n"load_path": "/mods/ui_fix",\n"active": true\n}, {\n"load_path": "/mods/retexture",\n"active": false\n}],\n"mods_enabled": true\n}]'
	var result: Variant = str_to_var(saved)
	assert_not_null(result, "str_to_var should parse pre-4.3 game with mods")
	assert_eq(result[0]["installed_mods"].size(), 2)
	assert_eq(result[0]["installed_mods"][0]["load_path"], "/mods/ui_fix")
	assert_true(result[0]["installed_mods"][0]["active"])
	assert_false(result[0]["installed_mods"][1]["active"])


# -- Registry pipeline: get_var() → var_to_str → str_to_var → GameData.new() --

func test_game_data_round_trip_preserves_entry_path() -> void:
	var game := GameData.new({entry_path = "/test/path", game_path = "/test/game", installed_mods = []})
	var serialized := var_to_str([game.get_var()])
	var deserialized: Array = str_to_var(serialized)
	var restored := GameData.new(deserialized[0])
	assert_eq(restored.entry_path, "/test/path")


func test_game_data_round_trip_preserves_game_path() -> void:
	var game := GameData.new({entry_path = "/test/path", game_path = "/test/game", installed_mods = []})
	var serialized := var_to_str([game.get_var()])
	var deserialized: Array = str_to_var(serialized)
	var restored := GameData.new(deserialized[0])
	assert_eq(restored.game_path, "/test/game")


func test_game_data_round_trip_preserves_mod_data() -> void:
	var game := GameData.new({
		entry_path = "/test/path",
		game_path = "/test/game",
		installed_mods = [
			{load_path = "/mods/a", active = true},
			{load_path = "/mods/b", active = false},
		],
	})
	var serialized := var_to_str([game.get_var()])
	var deserialized: Array = str_to_var(serialized)
	var restored := GameData.new(deserialized[0])
	assert_eq(restored.installed_mods.size(), 2)
	assert_eq(restored.installed_mods[0].load_path, "/mods/a")
	assert_eq(restored.installed_mods[1].load_path, "/mods/b")


func test_multi_game_round_trip() -> void:
	var games: Array[GameData] = [
		GameData.new({entry_path = "/game1", game_path = "/gp1", installed_mods = []}),
		GameData.new({entry_path = "/game2", game_path = "/gp2", installed_mods = [{load_path = "/mod", active = true}]}),
		GameData.new({entry_path = "/game3", game_path = "/gp3", installed_mods = []}),
	]
	var game_list := games.map(func(game: GameData) -> Dictionary[StringName, Variant]: return game.get_var())
	var serialized := var_to_str(game_list)
	var deserialized: Array = str_to_var(serialized)
	var restored: Array[GameData] = []
	restored.assign(deserialized.map(GameData.new))

	assert_eq(restored.size(), 3)
	assert_eq(restored[0].entry_path, "/game1")
	assert_eq(restored[1].entry_path, "/game2")
	assert_eq(restored[1].installed_mods.size(), 1)
	assert_eq(restored[2].entry_path, "/game3")


# -- File-based round-trip mimicking Registry._enter_tree / save_game_entry_list --

func test_file_round_trip() -> void:
	var test_file := "user://test_var_to_str_serialization.txt"
	var game_list: Array = [
		{entry_path = "/games/alpha", game_path = "/gp/alpha", installed_mods = [], mods_enabled = false},
		{entry_path = "/games/beta", game_path = "/gp/beta", installed_mods = [{load_path = "/mods/fix", active = true}], mods_enabled = true},
	]

	# Write (mirrors Registry.save_game_entry_list)
	var file := FileAccess.open(test_file, FileAccess.WRITE)
	file.store_string(var_to_str(game_list))
	assert_eq(file.get_error(), OK, "get_error() should be OK after store_string() (GH-78289)")
	file = null

	# Read (mirrors Registry._enter_tree)
	var loaded_file := FileAccess.open(test_file, FileAccess.READ)
	var loaded: Array = str_to_var(loaded_file.get_as_text())
	loaded_file = null

	assert_eq(loaded.size(), 2)
	assert_eq(loaded[0]["entry_path"], "/games/alpha")
	assert_eq(loaded[1]["installed_mods"][0]["load_path"], "/mods/fix")
	assert_true(loaded[1]["installed_mods"][0]["active"])

	# Cleanup
	DirAccess.remove_absolute(test_file)


# -- Edge cases: types that var_to_str must handle --

func test_bool_values_preserved() -> void:
	var original := [{active = true}, {active = false}]
	var result: Variant = str_to_var(var_to_str(original))
	assert_true(result[0]["active"])
	assert_false(result[1]["active"])


func test_empty_string_values_preserved() -> void:
	var original := [{entry_path = "", game_path = ""}]
	var result: Variant = str_to_var(var_to_str(original))
	assert_eq(result[0]["entry_path"], "")
	assert_eq(result[0]["game_path"], "")


func test_paths_with_special_characters() -> void:
	var original := [{entry_path = "/path/with spaces/game", game_path = "C:\\Users\\test\\games"}]
	var result: Variant = str_to_var(var_to_str(original))
	assert_eq(result[0]["entry_path"], "/path/with spaces/game")
	assert_eq(result[0]["game_path"], "C:\\Users\\test\\games")


func test_str_to_var_returns_null_for_invalid_input() -> void:
	var result: Variant = str_to_var("not valid var_to_str output {{{")
	assert_null(result, "str_to_var should return null for malformed input")
