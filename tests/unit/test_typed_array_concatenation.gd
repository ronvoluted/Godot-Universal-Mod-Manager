extends GutTest
## Verify typed array concatenation operator (+) works correctly.
## Regression coverage for Godot GH-73540 (typed array concatenation fix).


# -- Basic typed array concatenation --

func test_typed_int_array_concatenation() -> void:
	var a: Array[int] = [1, 2]
	var b: Array[int] = [3, 4]
	var result := a + b
	assert_eq(result, [1, 2, 3, 4])
	assert_true(result is Array[int])


func test_typed_string_array_concatenation() -> void:
	var a: Array[String] = ["hello"]
	var b: Array[String] = ["world"]
	var result := a + b
	assert_eq(result, ["hello", "world"])
	assert_true(result is Array[String])


# -- Empty array edge cases --

func test_concatenation_with_empty_left() -> void:
	var a: Array[int] = []
	var b: Array[int] = [1, 2]
	var result := a + b
	assert_eq(result, [1, 2])
	assert_true(result is Array[int])


func test_concatenation_with_empty_right() -> void:
	var a: Array[int] = [1, 2]
	var b: Array[int] = []
	var result := a + b
	assert_eq(result, [1, 2])
	assert_true(result is Array[int])


func test_concatenation_both_empty() -> void:
	var a: Array[int] = []
	var b: Array[int] = []
	var result := a + b
	assert_eq(result.size(), 0)
	assert_true(result is Array[int])


# -- Originals are not mutated --

func test_concatenation_does_not_mutate_originals() -> void:
	var a: Array[int] = [1, 2]
	var b: Array[int] = [3, 4]
	var _result := a + b
	assert_eq(a, [1, 2])
	assert_eq(b, [3, 4])


# -- Project typed arrays: Array[GameData] --

func test_game_data_array_concatenation() -> void:
	var a: Array[GameData] = []
	var b: Array[GameData] = []
	var game_a := GameData.new({entry_path = "/path/a", game_path = "/game/a", installed_mods = []})
	var game_b := GameData.new({entry_path = "/path/b", game_path = "/game/b", installed_mods = []})
	a.append(game_a)
	b.append(game_b)

	var result := a + b
	assert_eq(result.size(), 2)
	assert_true(result is Array[GameData])
	assert_eq(result[0].entry_path, "/path/a")
	assert_eq(result[1].entry_path, "/path/b")


func test_game_data_concatenation_with_empty() -> void:
	var a: Array[GameData] = []
	var b: Array[GameData] = []
	var game := GameData.new({entry_path = "/path/a", game_path = "/game/a", installed_mods = []})
	a.append(game)

	var result := a + b
	assert_eq(result.size(), 1)
	assert_true(result is Array[GameData])
	assert_eq(result[0].entry_path, "/path/a")


# -- Project typed arrays: Array[ModData] --

func test_mod_data_array_concatenation() -> void:
	var a: Array[ModData] = []
	var b: Array[ModData] = []
	var mod_a := ModData.new({load_path = "/mods/a", active = true})
	var mod_b := ModData.new({load_path = "/mods/b", active = false})
	a.append(mod_a)
	b.append(mod_b)

	var result := a + b
	assert_eq(result.size(), 2)
	assert_true(result is Array[ModData])
	assert_eq(result[0].load_path, "/mods/a")
	assert_eq(result[1].load_path, "/mods/b")


func test_mod_data_concatenation_preserves_type() -> void:
	var a: Array[ModData] = []
	var b: Array[ModData] = []
	var result := a + b
	assert_eq(result.size(), 0)
	assert_true(result is Array[ModData])


# -- Multiple concatenations --

func test_chained_concatenation() -> void:
	var a: Array[int] = [1]
	var b: Array[int] = [2]
	var c: Array[int] = [3]
	var result := a + b + c
	assert_eq(result, [1, 2, 3])
	assert_true(result is Array[int])


func test_chained_game_data_concatenation() -> void:
	var a: Array[GameData] = []
	var b: Array[GameData] = []
	var c: Array[GameData] = []
	a.append(GameData.new({entry_path = "/a"}))
	b.append(GameData.new({entry_path = "/b"}))
	c.append(GameData.new({entry_path = "/c"}))

	var result := a + b + c
	assert_eq(result.size(), 3)
	assert_true(result is Array[GameData])
	assert_eq(result[0].entry_path, "/a")
	assert_eq(result[1].entry_path, "/b")
	assert_eq(result[2].entry_path, "/c")
