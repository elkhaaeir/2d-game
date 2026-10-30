extends Area2D


func _on_body_entered(body: PhysicsBody2D) -> void:
	pass # Replace with function body.
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Assets/Scenes/Areas/areas_2.tscn")


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
	

	
		
