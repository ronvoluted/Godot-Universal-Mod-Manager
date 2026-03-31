extends GutTest
## Verify that typed array properties create independent instances per object.
## Regression coverage for Godot GH-108216 (typed collections reference fix).


# -- Each GameData gets its own installed_mods array --

func test_game_data_installed_mods_are_independent() -> void:
	var game_a := Registry.GameData.new({entry_path = "/a", game_path = "/ga", installed_mods = []})
	var game_b := Registry.GameData.new({entry_path = "/b", game_path = "/gb", installed_mods = []})

	game_a.installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/only_a", active = true}))

	assert_eq(game_a.installed_mods.size(), 1, "game_a should have 1 mod")
	assert_eq(game_b.installed_mods.size(), 0, "game_b should remain empty")


func test_game_data_mod_mutation_does_not_leak() -> void:
	var game_a := Registry.GameData.new({entry_path = "/a", game_path = "/ga", installed_mods = []})
	var game_b := Registry.GameData.new({entry_path = "/b", game_path = "/gb", installed_mods = []})

	game_b.installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/b1", active = true}))
	game_b.installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/b2", active = false}))

	assert_eq(game_a.installed_mods.size(), 0, "game_a must not see game_b mods")
	assert_eq(game_b.installed_mods.size(), 2)


# -- Multiple games from deserialized data have independent arrays --

func test_deserialized_games_have_independent_mod_lists() -> void:
	var raw_games: Array = [
		{entry_path = "/a", game_path = "/ga", installed_mods = [{load_path = "/mods/a1", active = true}]},
		{entry_path = "/b", game_path = "/gb", installed_mods = []},
	]
	var games: Array[Registry.GameData] = []
	games.assign(raw_games.map(Registry.GameData.new))

	assert_eq(games[0].installed_mods.size(), 1)
	assert_eq(games[1].installed_mods.size(), 0)

	games[1].installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/b1", active = true}))

	assert_eq(games[0].installed_mods.size(), 1, "game_a must stay at 1 mod")
	assert_eq(games[1].installed_mods.size(), 1, "game_b should now have 1 mod")


# -- Round-trip serialization preserves independence --

func test_round_trip_preserves_array_independence() -> void:
	var game_a := Registry.GameData.new({entry_path = "/a", game_path = "/ga", installed_mods = [{load_path = "/mods/a1", active = true}]})
	var game_b := Registry.GameData.new({entry_path = "/b", game_path = "/gb", installed_mods = []})

	var serialized := var_to_str([game_a.get_var(), game_b.get_var()])
	var deserialized: Array = str_to_var(serialized)
	var restored: Array[Registry.GameData] = []
	restored.assign(deserialized.map(Registry.GameData.new))

	restored[1].installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/new", active = true}))

	assert_eq(restored[0].installed_mods.size(), 1, "restored game_a must keep original mod count")
	assert_eq(restored[1].installed_mods.size(), 1, "restored game_b should have the newly added mod")


# -- Empty typed arrays are distinct objects --

func test_empty_typed_arrays_are_distinct() -> void:
	var game_a := Registry.GameData.new({entry_path = "/a", game_path = "/ga", installed_mods = []})
	var game_b := Registry.GameData.new({entry_path = "/b", game_path = "/gb", installed_mods = []})

	# Appending to one must not affect the other (proves distinct backing arrays)
	game_a.installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/proof", active = true}))
	assert_eq(game_a.installed_mods.size(), 1)
	assert_eq(game_b.installed_mods.size(), 0, "Distinct arrays must not share elements")


# -- Clearing one game's mods does not affect another --

func test_clearing_mods_does_not_affect_other_game() -> void:
	var game_a := Registry.GameData.new({
		entry_path = "/a", game_path = "/ga",
		installed_mods = [{load_path = "/mods/a1", active = true}],
	})
	var game_b := Registry.GameData.new({
		entry_path = "/b", game_path = "/gb",
		installed_mods = [{load_path = "/mods/b1", active = true}, {load_path = "/mods/b2", active = false}],
	})

	game_a.installed_mods.clear()

	assert_eq(game_a.installed_mods.size(), 0)
	assert_eq(game_b.installed_mods.size(), 2, "game_b mods must survive game_a clear")


# -- Batch construction via .map() produces independent arrays --

func test_map_constructed_games_are_independent() -> void:
	var configs: Array = [
		{entry_path = "/1", game_path = "/g1", installed_mods = []},
		{entry_path = "/2", game_path = "/g2", installed_mods = []},
		{entry_path = "/3", game_path = "/g3", installed_mods = []},
	]
	var games: Array[Registry.GameData] = []
	games.assign(configs.map(Registry.GameData.new))

	games[0].installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/x", active = true}))
	games[2].installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/y", active = true}))
	games[2].installed_mods.append(Registry.GameData.ModData.new({load_path = "/mods/z", active = false}))

	assert_eq(games[0].installed_mods.size(), 1)
	assert_eq(games[1].installed_mods.size(), 0, "middle game must remain empty")
	assert_eq(games[2].installed_mods.size(), 2)
