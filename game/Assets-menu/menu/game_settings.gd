extends CanvasLayer

@onready var pause_menu: Panel = $Settings
@onready var audio_menu: Panel = $AudioSettings
@onready var music_slider: HSlider = $AudioSettings/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $AudioSettings/VBoxContainer/SFXSlider
@onready var controls_menu: Panel = $ControlsSettings
var awaiting_action := ""
const REMAPPABLE_ACTIONS := ["move_left", "move_right", "jump", "dialogue", "inventory", "game_settings"]
const ACTION_LABELS := {"move_left":"Gerak kiri", "move_right":"Gerak kanan", "jump":"Lompat", "dialogue":"Interaksi / lanjut dialog", "inventory":"Inventori", "game_settings":"Menu jeda"}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	visible = false
	_sync_audio_sliders()
	_refresh_controls_labels()

func open_pause() -> void:
	visible = true
	_show_pause_menu()

func close_pause() -> void:
	visible = false

func _show_pause_menu() -> void:
	pause_menu.visible = true
	audio_menu.visible = false
	if is_instance_valid(controls_menu): controls_menu.visible = false

func _sync_audio_sliders() -> void:
	_set_slider_from_bus(music_slider, "Music")
	_set_slider_from_bus(sfx_slider, "SFX")

func _set_slider_from_bus(slider: HSlider, bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus tidak ditemukan: %s" % bus_name)
		return
	var volume_db := AudioServer.get_bus_volume_db(bus_index)
	var linear_volume := db_to_linear(volume_db)
	slider.set_value_no_signal(clampf(linear_volume, 0.0, 1.0))

func _set_bus_volume(value: float, bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus tidak ditemukan: %s" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(bus_index, is_zero_approx(value))

func _on_settings_pressed() -> void:
	pause_menu.visible = false
	audio_menu.visible = true
	_sync_audio_sliders()

func _control_text(action: String) -> String:
	var events := InputMap.action_get_events(action)
	var key := "-"
	if not events.is_empty(): key = events[0].as_text_physical_keycode()
	return "%s: %s" % [ACTION_LABELS[action], key]

func _begin_remap(action: String, button: Button) -> void:
	awaiting_action = action
	button.text = "Tekan tombol baru… (Esc batal)"

func _input(event: InputEvent) -> void:
	if awaiting_action.is_empty() or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		awaiting_action = ""
	else:
		InputMap.action_erase_events(awaiting_action)
		InputMap.action_add_event(awaiting_action, event)
		awaiting_action = ""
	_refresh_controls_labels()
	get_viewport().set_input_as_handled()

func _on_controls_pressed() -> void:
	pause_menu.visible = false
	audio_menu.visible = false
	controls_menu.visible = true

func _refresh_controls_labels() -> void:
	for action in REMAPPABLE_ACTIONS:
		var button := controls_menu.get_node_or_null("VBoxContainer/" + action) as Button
		if button:
			button.text = _control_text(action)

func _on_remap_button_pressed(action: String) -> void:
	var button := controls_menu.get_node_or_null("VBoxContainer/" + action) as Button
	if button:
		_begin_remap(action, button)

func _on_continue_pressed() -> void:
	if is_instance_valid(PauseManager):
		PauseManager.close_pause()
	else:
		get_tree().paused = false
		close_pause()

func _on_back_to_menu_pressed() -> void:
	if is_instance_valid(PauseManager):
		PauseManager.return_to_menu()
	else:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Assets-menu/menu/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_audio_back_pressed() -> void:
	_show_pause_menu()

func _on_music_value_changed(value: float) -> void:
	_set_bus_volume(value, "Music")

func _on_sfx_value_changed(value: float) -> void:
	_set_bus_volume(value, "SFX")
