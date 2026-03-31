extends GutTest
## Validates DirAccess.is_equivalent() for robust path comparison (GH-104597).

var _dir: DirAccess


func before_each() -> void:
	_dir = DirAccess.open(OS.get_temp_dir())


func test_identical_paths_are_equivalent() -> void:
	var tmp := DirAccess.create_temp("test_equiv_a")
	assert_true(_dir.is_equivalent(tmp, tmp))
	DirAccess.remove_absolute(tmp)


func test_trailing_slash_is_equivalent() -> void:
	var tmp := DirAccess.create_temp("test_equiv_b")
	assert_true(_dir.is_equivalent(tmp, tmp + "/"))
	DirAccess.remove_absolute(tmp)


func test_different_directories_are_not_equivalent() -> void:
	var tmp_a := DirAccess.create_temp("test_equiv_c")
	var tmp_b := DirAccess.create_temp("test_equiv_d")
	assert_false(_dir.is_equivalent(tmp_a, tmp_b))
	DirAccess.remove_absolute(tmp_a)
	DirAccess.remove_absolute(tmp_b)


func test_nonexistent_paths_are_not_equivalent() -> void:
	assert_false(_dir.is_equivalent("/nonexistent/path/aaa", "/nonexistent/path/bbb"))


func test_symlink_resolves_as_equivalent() -> void:
	var tmp := DirAccess.create_temp("test_equiv_e")
	var link := tmp + "_link"
	OS.execute("ln", ["-sfn", tmp, link])
	assert_true(_dir.is_equivalent(tmp, link))
	OS.execute("rm", [link])
	DirAccess.remove_absolute(tmp)
