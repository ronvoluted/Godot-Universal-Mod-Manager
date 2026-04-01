extends GutTest

## Tests that GameEntry and ModEntry emit signals instead of calling owner methods.


func test_game_entry_has_recovered_signal() -> void:
	var entry := preload("res://Nodes/GameEntry.tscn").instantiate()
	assert_has_signal(entry, "recovered")
	entry.free()


func test_mod_entry_has_active_toggled_signal() -> void:
	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	assert_has_signal(entry, "active_toggled")
	entry.free()


func test_mod_entry_has_recovered_signal() -> void:
	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	assert_has_signal(entry, "recovered")
	entry.free()


func test_mod_entry_toggle_active_emits_signal() -> void:
	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({})
	mod.active = false
	entry.data = mod

	watch_signals(entry)
	entry.toggle_active(true)

	assert_signal_emitted(entry, "active_toggled")
	assert_true(mod.active)


func test_mod_entry_toggle_active_sets_metadata() -> void:
	var entry := preload("res://Nodes/ModEntry.tscn").instantiate()
	add_child_autofree(entry)

	var mod := ModData.new({})
	mod.active = true
	entry.data = mod

	entry.toggle_active(false)

	assert_false(mod.active)
