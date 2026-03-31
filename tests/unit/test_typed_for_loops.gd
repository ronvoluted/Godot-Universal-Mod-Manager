extends GutTest
## Verify static typing in for loops works correctly.
## Coverage for GDScript typed for loop syntax (GH-80247).


# -- Typed iteration over typed arrays --

func test_typed_for_over_int_array() -> void:
	var numbers: Array[int] = [1, 2, 3]
	var sum := 0
	for n: int in numbers:
		sum += n
	assert_eq(sum, 6)


func test_typed_for_over_string_array() -> void:
	var words: Array[String] = ["hello", "world"]
	var result := ""
	for word: String in words:
		result += word
	assert_eq(result, "helloworld")


# -- Typed iteration over range --

func test_typed_for_over_int_range() -> void:
	var sum := 0
	for i: int in 5:
		sum += i
	assert_eq(sum, 10)


# -- Typed iteration over untyped array --

func test_typed_for_over_untyped_array() -> void:
	var items: Array = [{"a": 1}, {"b": 2}]
	var count := 0
	for item: Variant in items:
		count += 1
	assert_eq(count, 2)


func test_dictionary_for_type_hint() -> void:
	var data: Array = [{entry_path = "/a"}, {entry_path = "/b"}]
	var paths: Array[String] = []
	for entry: Dictionary in data:
		paths.append(entry.entry_path)
	assert_eq(paths, ["/a", "/b"])


# -- Typed iteration over project types --

func test_typed_for_over_game_data_array() -> void:
	var games: Array[GameData] = []
	games.append(GameData.new({entry_path = "/path/a", game_path = "/game/a", installed_mods = []}))
	games.append(GameData.new({entry_path = "/path/b", game_path = "/game/b", installed_mods = []}))

	var paths: Array[String] = []
	for game: GameData in games:
		paths.append(game.entry_path)
	assert_eq(paths, ["/path/a", "/path/b"])


func test_typed_for_over_mod_data_array() -> void:
	var mods: Array[ModData] = []
	mods.append(ModData.new({load_path = "/mods/a", active = true}))
	mods.append(ModData.new({load_path = "/mods/b", active = false}))

	var paths: Array[String] = []
	for mod: ModData in mods:
		paths.append(mod.load_path)
	assert_eq(paths, ["/mods/a", "/mods/b"])


# -- Typed iteration over Node children (Array[Node]) --

func test_typed_for_over_node_children() -> void:
	var parent := Node.new()
	parent.add_child(Node.new())
	parent.add_child(Node.new())

	var count := 0
	for child: Node in parent.get_children():
		count += 1
	assert_eq(count, 2)

	parent.free()


# -- Typed iteration over PackedStringArray --

func test_typed_for_over_packed_string_array() -> void:
	var arr: PackedStringArray = ["a.txt", "b.txt", "c.txt"]
	var result: Array[String] = []
	for file: String in arr:
		result.append(file)
	assert_eq(result, ["a.txt", "b.txt", "c.txt"])
