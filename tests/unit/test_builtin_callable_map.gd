extends GutTest
## Verify constructor functions work as Callable in .map() chains (GH-84808).
## Passing constructors directly avoids wrapping them in lambdas.


# -- Constructor Callable in .map() --

func test_mod_data_constructor_callable_in_map() -> void:
	var dicts := [
		{load_path = "/mod/a", active = true},
		{load_path = "/mod/b", active = false},
	]
	var mods: Array = dicts.map(ModData.new)
	assert_eq(mods.size(), 2)
	assert_eq(mods[0].load_path, "/mod/a")
	assert_eq(mods[1].load_path, "/mod/b")


func test_game_data_constructor_callable_in_map() -> void:
	var dicts := [{entry_path = "/game", game_path = "/path", installed_mods = []}]
	var games: Array = dicts.map(GameData.new)
	assert_eq(games.size(), 1)
	assert_eq(games[0].entry_path, "/game")
	assert_eq(games[0].game_path, "/path")


# -- Typed array .assign() with .map() constructor --

func test_assign_typed_array_with_map_constructor() -> void:
	var dicts := [
		{load_path = "/mod/x", active = false},
		{load_path = "/mod/y", active = true},
	]
	var mods: Array[ModData] = []
	mods.assign(dicts.map(ModData.new))
	assert_eq(mods.size(), 2)
	assert_true(mods[0] is ModData)
	assert_true(mods[1] is ModData)


func test_assign_typed_array_with_empty_input() -> void:
	var dicts: Array = []
	var mods: Array[ModData] = []
	mods.assign(dicts.map(ModData.new))
	assert_eq(mods.size(), 0)


# -- Variant array .map() with constructor --

func test_variant_array_map_with_constructor() -> void:
	var raw: Array = [{load_path = "/a", active = true}, {load_path = "/b", active = false}]
	var mods: Array[ModData] = []
	mods.assign(Array(raw).map(ModData.new))
	assert_eq(mods.size(), 2)
	assert_eq(mods[0].load_path, "/a")
	assert_eq(mods[1].load_path, "/b")


# -- Equivalence: lambda vs direct constructor Callable --

func test_lambda_and_direct_constructor_produce_same_result() -> void:
	var dicts := [{load_path = "/mod/eq", active = false}]
	var via_lambda := dicts.map(func(d: Dictionary) -> ModData: return ModData.new(d))
	var via_direct := dicts.map(ModData.new)
	assert_eq(via_lambda.size(), via_direct.size())
	assert_eq(via_lambda[0].load_path, via_direct[0].load_path)
	assert_eq(via_lambda[0].active, via_direct[0].active)
