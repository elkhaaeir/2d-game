extends Node2D

@onready var respawn_point = $RespawnPoint

func _ready():
	GameManager.set_respawn_point(respawn_point.global_position)
