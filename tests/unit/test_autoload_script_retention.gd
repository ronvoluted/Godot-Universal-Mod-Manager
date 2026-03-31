extends GutTest
## Verify Registry autoload retains its script after upgrading to 4.4.
##
## Godot 4.4 fixed a bug where autoloaded scenes could lose their built-in
## script on project upgrade (GH-103439). Registry is registered as a direct
## script autoload ("*res://Data/Registry.gd"), which is immune to this issue.
## These tests verify the autoload is configured correctly and the script is
## intact at runtime.


# -- project.godot configuration --

func test_registry_autoload_points_to_script_not_scene() -> void:
	var config := ConfigFile.new()
	var err := config.load("res://project.godot")
	assert_eq(err, OK)

	var value: String = config.get_value("autoload", "Registry", "")
	assert_string_contains(value, ".gd", "Autoload should reference a .gd script, not a .tscn scene")


func test_registry_autoload_script_exists() -> void:
	var config := ConfigFile.new()
	config.load("res://project.godot")

	var value: String = config.get_value("autoload", "Registry", "")
	var path := value.trim_prefix("*")
	assert_true(ResourceLoader.exists(path), "Autoload script '%s' should exist on disk" % path)


# -- Runtime singleton verification --

func test_registry_singleton_is_available() -> void:
	var registry := Engine.get_singleton_list()
	# Autoloads aren't Engine singletons — they're scene tree autoloads.
	# Verify via the tree instead.
	var node := get_tree().root.get_node_or_null("/root/Registry")
	assert_not_null(node, "Registry autoload should be present in the scene tree")


func test_registry_node_has_script_attached() -> void:
	var node := get_tree().root.get_node_or_null("/root/Registry")
	if not node:
		fail_test("Registry node not found in scene tree")
		return
	assert_not_null(node.get_script(), "Registry node should have a script attached (GH-103439)")


func test_registry_script_is_registry_gd() -> void:
	var node := get_tree().root.get_node_or_null("/root/Registry")
	if not node:
		fail_test("Registry node not found in scene tree")
		return
	var script: Script = node.get_script()
	assert_not_null(script)
	assert_string_contains(script.resource_path, "Data/Registry.gd",
			"Registry node script should be Data/Registry.gd")
