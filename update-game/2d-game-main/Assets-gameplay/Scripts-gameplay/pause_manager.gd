extends Node

const PAUSE_SCENE: PackedScene = preload("res://Assets-gameplay/Scenes-gameplay/game_settings.tscn")
const MAIN_MENU_SCENE := "res://Assets-menu/menu/main_menu.tscn"

var pause_ui: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_ui = PAUSE_SCENE.instantiate() as CanvasLayer
	pause_ui.name = "InGameSettings"
	get_tree().root.add_child.call_deferred(pause_ui)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("game_settings") or event.is_echo():
		return

	if not _is_gameplay_scene():
		return

	if pause_ui == null or not is_instance_valid(pause_ui):
		return

	if pause_ui.visible:
		close_pause()
	else:
		open_pause()

	get_viewport().set_input_as_handled()

func _is_gameplay_scene() -> bool:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return false
	return current_scene.scene_file_path.begins_with("res://Assets-gameplay/Scenes-gameplay/Areas/")

func open_pause() -> void:
	if pause_ui == null:
		return
	pause_ui.open_pause()
	get_tree().paused = true

func close_pause() -> void:
	get_tree().paused = false
	if pause_ui != null:
		pause_ui.close_pause()

func return_to_menu() -> void:
	get_tree().paused = false
	if pause_ui != null:
		pause_ui.close_pause()
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("Gagal kembali ke Main Menu. Error: %s" % error)
