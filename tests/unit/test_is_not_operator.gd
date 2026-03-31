extends GutTest
## Verify the `is not` operator works as a readable negated type check (GH-87939).
## Replaces the older `not x is Type` pattern with `x is not Type`.


# -- Built-in types --

func test_is_not_with_mismatched_builtin_type() -> void:
	var value: Variant = "hello"
	assert_true(value is not int, "String should not be int")


func test_is_not_returns_false_for_matching_builtin_type() -> void:
	var value: Variant = 42
	assert_false(value is not int, "int should be int")


func test_is_not_with_float() -> void:
	var value: Variant = 3.14
	assert_true(value is not int, "float should not be int")
	assert_false(value is not float, "float should be float")


func test_is_not_with_string() -> void:
	var value: Variant = "hello"
	assert_true(value is not float, "String should not be float")
	assert_false(value is not String, "String should be String")


func test_is_not_with_bool() -> void:
	var value: Variant = true
	assert_false(value is not bool, "bool should be bool")
	assert_true(value is not String, "bool should not be String")


# -- null handling --

func test_is_not_with_null() -> void:
	var value: Variant = null
	assert_true(value is not int, "null should not be int")
	assert_true(value is not String, "null should not be String")
	assert_true(value is not Object, "null should not be Object")


# -- Engine class types --

func test_is_not_with_node() -> void:
	var node := Node.new()
	assert_false(node is not Node, "Node should be Node")
	assert_false(node is not Object, "Node should be Object (parent class)")
	assert_true(node is not RefCounted, "Node should not be RefCounted")
	node.free()


func test_is_not_with_refcounted() -> void:
	var ref := RefCounted.new()
	assert_false(ref is not RefCounted, "RefCounted should be RefCounted")
	assert_false(ref is not Object, "RefCounted should be Object (parent class)")
	assert_true(ref is not Node, "RefCounted should not be Node")


# -- Inheritance --

func test_is_not_respects_inheritance() -> void:
	var node := Node2D.new()
	assert_false(node is not Node2D, "Node2D should be Node2D")
	assert_false(node is not CanvasItem, "Node2D should be CanvasItem (parent)")
	assert_false(node is not Node, "Node2D should be Node (grandparent)")
	assert_true(node is not Node3D, "Node2D should not be Node3D")
	node.free()


# -- Project types --

func test_is_not_with_project_class() -> void:
	var game := GameData.new({entry_path = "/test", game_path = "/game", installed_mods = []})
	assert_false(game is not GameData, "GameData should be GameData")


func test_is_not_with_nested_project_class() -> void:
	var mod := ModData.new({load_path = "/mod", active = true})
	assert_false(mod is not ModData, "ModData should be ModData")


# -- Equivalence with not (x is Type) --

func test_is_not_equivalent_to_not_is() -> void:
	var value: Variant = "hello"
	assert_eq(
		value is not int,
		not (value is int),
		"`is not` should produce the same result as `not (x is Type)`"
	)


func test_is_not_equivalent_to_not_is_when_matching() -> void:
	var value: Variant = 42
	assert_eq(
		value is not int,
		not (value is int),
		"`is not` should produce the same result as `not (x is Type)` for matching types"
	)


# -- Use in conditional expressions --

func test_is_not_in_if_condition() -> void:
	var value: Variant = "hello"
	var result := false
	if value is not int:
		result = true
	assert_true(result, "`is not` should work in if conditions")


func test_is_not_with_and_operator() -> void:
	var a: Variant = "hello"
	var b: Variant = 42
	assert_true(a is not int and b is not String,
		"`is not` should compose with `and`")
