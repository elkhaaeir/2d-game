extends Area2D

const NEXT_SCENE: String = "res://Assets-gameplay/Scenes-gameplay/Areas/area_3.tscn"
var transition_started := false

func _on_body_entered(body: Node2D) -> void:
	if transition_started or body.name != "Player":
		return

	if not ResourceLoader.exists(NEXT_SCENE):
		push_error("Scene tujuan tidak ditemukan: " + NEXT_SCENE)
		return

	transition_started = true
	ProgressManager.unlock_chapter(3)
	get_tree().call_deferred("change_scene_to_file", NEXT_SCENE)
