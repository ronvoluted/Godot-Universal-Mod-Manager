extends GutTest


# -- get_meta() with default value (GH-58608) --
# Validates that get_meta() returns the default when the key is absent,
# eliminating the need for has_meta()/get_meta() guard patterns.


func test_get_meta_returns_default_when_key_absent() -> void:
	var node := Node.new()
	assert_eq(node.get_meta(&"nonexistent", "fallback"), "fallback")
	node.free()


func test_get_meta_returns_value_when_key_present() -> void:
	var node := Node.new()
	node.set_meta(&"my_key", "actual_value")
	assert_eq(node.get_meta(&"my_key", "fallback"), "actual_value")
	node.free()


func test_get_meta_default_works_with_various_types() -> void:
	var node := Node.new()
	assert_eq(node.get_meta(&"missing_int", 42), 42)
	assert_eq(node.get_meta(&"missing_array", []), [])
	assert_eq(node.get_meta(&"missing_bool", false), false)
	node.free()


func test_scene_tree_meta_returns_default_when_unset() -> void:
	var tree := get_tree()
	assert_eq(tree.get_meta(&"current_game", ""), "")


func test_scene_tree_meta_roundtrip() -> void:
	var tree := get_tree()
	tree.set_meta(&"test_meta_key", "/some/path")
	assert_eq(tree.get_meta(&"test_meta_key", ""), "/some/path")
	tree.remove_meta(&"test_meta_key")
