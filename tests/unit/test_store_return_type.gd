extends GutTest
## Verify FileAccess.store_*() return type changed from void to bool (GH-78289)
## and that Registry.save_game_entry_list() uses get_error() to propagate errors.


# -- FileAccess.store_string() returns bool --

func test_store_string_returns_bool() -> void:
	var path := "user://test_store_return.txt"
	var file := FileAccess.open(path, FileAccess.WRITE)
	var result := file.store_string("hello")
	assert_typeof(result, TYPE_BOOL, "store_string() should return bool (GH-78289)")
	file = null
	DirAccess.remove_absolute(path)


func test_store_string_returns_true_on_success() -> void:
	var path := "user://test_store_return_ok.txt"
	var file := FileAccess.open(path, FileAccess.WRITE)
	var ok := file.store_string("hello")
	assert_true(ok, "store_string() should return true on successful write")
	file = null
	DirAccess.remove_absolute(path)


func test_get_error_ok_after_successful_store() -> void:
	var path := "user://test_store_get_error.txt"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("hello")
	assert_eq(file.get_error(), OK, "get_error() should be OK after successful store_string()")
	file = null
	DirAccess.remove_absolute(path)


# -- Registry.save_game_entry_list() propagates Error via get_error() --

func test_save_game_entry_list_returns_error_type() -> void:
	Registry.games = []
	var err := Registry.save_game_entry_list()
	assert_typeof(err, TYPE_INT, "save_game_entry_list() should return Error")
	assert_eq(err, OK)

	# Cleanup
	DirAccess.remove_absolute(Registry.GAME_ENTRIES_FILE)


func test_save_game_entry_list_returns_ok_with_data() -> void:
	Registry.games = [Registry.GameData.new({entry_path = "/test", game_path = "/gp", installed_mods = []})]
	var err := Registry.save_game_entry_list()
	assert_eq(err, OK, "save_game_entry_list() should return OK on successful write")

	# Cleanup
	Registry.games = []
	DirAccess.remove_absolute(Registry.GAME_ENTRIES_FILE)
