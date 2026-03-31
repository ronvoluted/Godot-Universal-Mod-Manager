extends GutTest
## Verify multi-threaded resource loading pattern (GH-74405).
## Tests the thread-safe ResourceLoader.load_threaded_request/get_status/get
## polling loop that replaced direct load() calls for concurrent safety.


# -- ResourceLoader threaded API availability --

func test_load_threaded_request_exists():
	assert_true(ResourceLoader.has_method("load_threaded_request"))


func test_load_threaded_get_status_exists():
	assert_true(ResourceLoader.has_method("load_threaded_get_status"))


func test_load_threaded_get_exists():
	assert_true(ResourceLoader.has_method("load_threaded_get"))


# -- Thread load status enum values --

func test_thread_load_status_enum_values():
	# Verify enum constants exist and are distinct
	assert_ne(ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_LOADED)
	assert_ne(ResourceLoader.THREAD_LOAD_LOADED, ResourceLoader.THREAD_LOAD_FAILED)
	assert_ne(ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_FAILED)


# -- Threaded loading of a known resource --

func test_load_threaded_request_for_existing_resource():
	var path := "res://Nodes/GameEntry.tscn"
	var err := ResourceLoader.load_threaded_request(path)
	assert_eq(err, OK, "load_threaded_request should return OK for a valid path")


func test_load_threaded_get_status_returns_valid_status():
	var path := "res://Nodes/ModEntry.tscn"
	ResourceLoader.load_threaded_request(path)

	# Status should be either IN_PROGRESS or LOADED (small resource loads fast)
	var status := ResourceLoader.load_threaded_get_status(path)
	assert_true(
		status == ResourceLoader.THREAD_LOAD_IN_PROGRESS or
		status == ResourceLoader.THREAD_LOAD_LOADED,
		"Status should be IN_PROGRESS or LOADED, got: %d" % status
	)


func test_load_threaded_get_returns_resource():
	var path := "res://Nodes/GameEntry.tscn"
	ResourceLoader.load_threaded_request(path)

	# Poll until loaded (mirrors the pattern used in GUMM_mod_loader)
	var resource: Resource = null
	for i: int in 1000:
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			resource = ResourceLoader.load_threaded_get(path)
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			break
		# In tests we can't await process_frame, so tight-loop is acceptable
		OS.delay_msec(1)

	assert_not_null(resource, "Threaded load should return the resource")
	assert_true(resource is PackedScene, "Loaded resource should be a PackedScene")


# -- GUMM_mod.gd load_resource_threaded method --

func test_gumm_mod_has_load_resource_threaded():
	var mod_script: GDScript = load("res://System/4.x/GUMM_mod.gd")
	var mod := mod_script.new() as RefCounted
	assert_true(mod.has_method("load_resource_threaded"),
		"GUMM_mod should expose load_resource_threaded()")


func test_gumm_mod_load_resource_still_has_sync_method():
	var mod_script: GDScript = load("res://System/4.x/GUMM_mod.gd")
	var mod := mod_script.new() as RefCounted
	assert_true(mod.has_method("load_resource"),
		"GUMM_mod should still expose synchronous load_resource()")


# -- Mod loader scene structure --

func test_mod_loader_scene_loads():
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	assert_not_null(scene, "Mod loader scene should load successfully")


func test_mod_loader_script_has_threaded_methods():
	var scene := load("res://System/4.x/GUMM_mod_loader.tscn") as PackedScene
	var node := scene.instantiate()
	# Verify the mod loader node has the threaded loading helper and load_mod
	var script_source: String = node.get_script().source_code
	assert_true(script_source.contains("_poll_threaded_load"),
		"Mod loader script should contain _poll_threaded_load")
	assert_true(script_source.contains("load_threaded_request"),
		"Mod loader script should use load_threaded_request")
	assert_true(script_source.contains("load_threaded_get_status"),
		"Mod loader script should poll with load_threaded_get_status")
	assert_true(script_source.contains("load_threaded_get"),
		"Mod loader script should retrieve with load_threaded_get")
	node.free()


# -- Threaded load produces same result as sync load --

func test_threaded_load_matches_sync_load():
	var path := "res://Nodes/GameEntry.tscn"

	# Sync load
	var sync_resource := load(path)

	# Threaded load
	ResourceLoader.load_threaded_request(path)
	var threaded_resource: Resource = null
	for i: int in 1000:
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			threaded_resource = ResourceLoader.load_threaded_get(path)
			break
		OS.delay_msec(1)

	assert_not_null(threaded_resource)
	assert_eq(sync_resource.resource_path, threaded_resource.resource_path,
		"Threaded and sync load should return the same resource")
