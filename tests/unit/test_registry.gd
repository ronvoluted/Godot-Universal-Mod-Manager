extends GutTest


func test_game_data_static_mod_loader_scene():
	assert_eq(Registry.GameData.mod_loader_scene, "GUMM_mod_loader.tscn")
