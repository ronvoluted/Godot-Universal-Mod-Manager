extends GutTest
## Verify Array.find_custom() with Callable predicate for searching lists (GH-95449).
## Returns the index of the first element matching the predicate, or -1 if none.


# -- find_custom returns index of first match --

func test_find_custom_returns_index_of_first_match() -> void:
	var numbers := [1, 2, 3, 4, 5]
	var index := numbers.find_custom(func(n: int) -> bool: return n > 3)
	assert_eq(index, 3)
	assert_eq(numbers[index], 4)


func test_find_custom_returns_negative_one_when_no_match() -> void:
	var numbers := [1, 2, 3]
	var index := numbers.find_custom(func(n: int) -> bool: return n > 10)
	assert_eq(index, -1)


func test_find_custom_returns_negative_one_for_empty_array() -> void:
	var empty: Array[int] = []
	var index := empty.find_custom(func(n: int) -> bool: return n == 1)
	assert_eq(index, -1)


# -- Existence checks with != -1 --

func test_find_custom_existence_check_when_found() -> void:
	var names := ["Alice", "Bob", "Charlie"]
	assert_true(names.find_custom(func(n: String) -> bool: return n == "Bob") != -1)


func test_find_custom_existence_check_when_not_found() -> void:
	var names := ["Alice", "Bob"]
	assert_true(names.find_custom(func(n: String) -> bool: return n == "Zoe") == -1)


# -- Game/mod list search patterns --

func test_find_custom_game_metadata_by_path() -> void:
	var games: Array[Dictionary] = [
		{entry_path = "/games/a", title = "Alpha"},
		{entry_path = "/games/b", title = "Beta"},
		{entry_path = "/games/c", title = "Charlie"},
	]
	var index := games.find_custom(func(g: Dictionary) -> bool: return g.entry_path == "/games/b")
	assert_ne(index, -1)
	assert_eq(games[index].title, "Beta")


func test_find_custom_game_metadata_missing() -> void:
	var games: Array[Dictionary] = [
		{entry_path = "/games/a", title = "Alpha"},
	]
	var index := games.find_custom(func(g: Dictionary) -> bool: return g.entry_path == "/games/z")
	assert_eq(index, -1)


func test_find_custom_mod_by_name() -> void:
	var mods: Array[Dictionary] = [
		{name = "ModA", version = "1.0"},
		{name = "ModB", version = "2.0"},
		{name = "ModC", version = "3.0"},
	]
	var index := mods.find_custom(func(m: Dictionary) -> bool: return m.name == "ModB")
	assert_ne(index, -1)
	assert_eq(mods[index].version, "2.0")


func test_find_custom_mod_by_name_not_found() -> void:
	var mods: Array[Dictionary] = [
		{name = "ModA", version = "1.0"},
	]
	var index := mods.find_custom(func(m: Dictionary) -> bool: return m.name == "Missing")
	assert_eq(index, -1)


# -- find_custom stops at first match --

func test_find_custom_returns_first_not_last_match() -> void:
	var items := [
		{id = 1, label = "first"},
		{id = 2, label = "match"},
		{id = 3, label = "match"},
	]
	var index := items.find_custom(func(item: Dictionary) -> bool: return item.label == "match")
	assert_eq(index, 1)
	assert_eq(items[index].id, 2)


# -- from parameter skips earlier elements --

func test_find_custom_with_from_offset() -> void:
	var numbers := [10, 20, 30, 40, 50]
	var index := numbers.find_custom(func(n: int) -> bool: return n >= 20, 2)
	assert_eq(index, 2)
	assert_eq(numbers[index], 30)


# -- Typed arrays work with find_custom --

func test_find_custom_on_typed_string_array() -> void:
	var tags: Array[String] = ["alpha", "beta", "gamma"]
	var index := tags.find_custom(func(t: String) -> bool: return t.begins_with("bet"))
	assert_eq(index, 1)
	assert_eq(tags[index], "beta")


func test_find_custom_on_typed_int_array() -> void:
	var values: Array[int] = [10, 20, 30, 40]
	var index := values.find_custom(func(v: int) -> bool: return v >= 25)
	assert_eq(index, 2)
	assert_eq(values[index], 30)
