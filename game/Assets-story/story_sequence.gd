extends Control

## Scene cerita dapat diedit langsung lewat properti Label dan Button di Godot.
@export_file("*.tscn") var next_scene := ""

func _ready() -> void:
	PlayerHUD.hide_hud()
	$ContinueButton.pressed.connect(_continue_story)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dialogue") or event.is_action_pressed("jump"):
		_continue_story()

func _continue_story() -> void:
	if next_scene.is_empty() or not ResourceLoader.exists(next_scene):
		push_error("Scene cerita berikutnya tidak ditemukan: %s" % next_scene)
		return
	get_tree().change_scene_to_file(next_scene)
