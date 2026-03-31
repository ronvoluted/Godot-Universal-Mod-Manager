extends GutTest


# -- Descriptor.load_config --

func test_load_config_returns_null_for_missing_file() -> void:
	var cfg := Descriptor.load_config("user://nonexistent_path", "test.cfg")
	assert_null(cfg)


func test_load_config_returns_null_for_empty_file() -> void:
	var tmp_dir := DirAccess.create_temp("test_load_config_empty")
	var file := FileAccess.open(tmp_dir.path_join("test.cfg"), FileAccess.WRITE)
	file.close()

	var cfg := Descriptor.load_config(tmp_dir, "test.cfg")
	assert_null(cfg)

	DirAccess.remove_absolute(tmp_dir.path_join("test.cfg"))
	DirAccess.remove_absolute(tmp_dir)


func test_load_config_returns_config_file_for_valid_file() -> void:
	var tmp_dir := DirAccess.create_temp("test_load_config_valid")
	var cfg := ConfigFile.new()
	cfg.set_value("test", "key", "value")
	cfg.save(tmp_dir.path_join("test.cfg"))

	var loaded := Descriptor.load_config(tmp_dir, "test.cfg")
	assert_not_null(loaded)
	assert_eq(loaded.get_value("test", "key"), "value")

	DirAccess.remove_absolute(tmp_dir.path_join("test.cfg"))
	DirAccess.remove_absolute(tmp_dir)


# -- Descriptor.save_config --

func test_save_config_writes_file_successfully() -> void:
	var tmp_dir := DirAccess.create_temp("test_save_config")
	var cfg := ConfigFile.new()
	cfg.set_value("section", "key", 42)

	var err := Descriptor.save_config(cfg, tmp_dir, "out.cfg")
	assert_eq(err, OK)
	assert_true(FileAccess.file_exists(tmp_dir.path_join("out.cfg")))

	var loaded := ConfigFile.new()
	loaded.load(tmp_dir.path_join("out.cfg"))
	assert_eq(loaded.get_value("section", "key"), 42)

	DirAccess.remove_absolute(tmp_dir.path_join("out.cfg"))
	DirAccess.remove_absolute(tmp_dir)


func test_save_config_returns_error_for_invalid_path() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("section", "key", "value")
	var err := Descriptor.save_config(cfg, "://invalid", "out.cfg")
	assert_ne(err, OK)
	assert_push_error_count(1)


# -- Base load_data/save_data delegates to subclass fields --

func test_base_load_data_populates_game_fields() -> void:
	var tmp_dir := DirAccess.create_temp("test_base_load_game")
	var cfg := ConfigFile.new()
	cfg.set_value("Godot Game", "title", "My Game")
	cfg.set_value("Godot Game", "godot_version", "4.x")
	cfg.set_value("Godot Game", "main_scene", "res://Main.tscn")
	cfg.save(tmp_dir.path_join("game.cfg"))

	var desc := GameDescriptor.new()
	assert_true(desc.load_data(tmp_dir))
	assert_eq(desc.title, "My Game")
	assert_eq(desc.godot_version, "4.x")
	assert_eq(desc.main_scene, "res://Main.tscn")

	DirAccess.remove_absolute(tmp_dir.path_join("game.cfg"))
	DirAccess.remove_absolute(tmp_dir)


func test_base_save_data_writes_mod_fields() -> void:
	var tmp_dir := DirAccess.create_temp("test_base_save_mod")
	var desc := ModDescriptor.new()
	desc.game = "Test"
	desc.name = "Mod"
	desc.description = "Desc"
	desc.version = "2.0"
	desc.save_data(tmp_dir)

	var cfg := ConfigFile.new()
	cfg.load(tmp_dir.path_join("mod.cfg"))
	assert_eq(cfg.get_value("Godot Mod", "game"), "Test")
	assert_eq(cfg.get_value("Godot Mod", "name"), "Mod")
	assert_eq(cfg.get_value("Godot Mod", "description"), "Desc")
	assert_eq(cfg.get_value("Godot Mod", "version"), "2.0")

	DirAccess.remove_absolute(tmp_dir.path_join("mod.cfg"))
	DirAccess.remove_absolute(tmp_dir)
