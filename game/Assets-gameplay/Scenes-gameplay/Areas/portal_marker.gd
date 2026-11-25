extends Area2D

func _draw() -> void:
	var shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape == null:
		return
	var center := shape.position
	draw_circle(center, 37.0, Color(0.15, 0.7, 1.0, 0.18))
	draw_arc(center, 34.0, 0.0, TAU, 48, Color(0.5, 0.95, 1.0, 0.95), 5.0, true)
	draw_arc(center, 26.0, 0.0, TAU, 48, Color(0.3, 0.65, 1.0, 0.7), 2.0, true)
