
extends CharacterBody2D

@export var enemy_id: String = "enemy_1"

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var encounter_area = $EncounterArea

var player_detected = false
var player = null

var chase_speed = 50.0
var stop_distance = 24.0
var battle_started = false


func _ready():
	animated_sprite.play("idle")

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	encounter_area.body_entered.connect(_on_encounter_area_entered)

	# Menghilangkan musuh jika sudah dikalahkan
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()


func _physics_process(_delta):
	if battle_started:
		velocity.x = 0
		return

	if player_detected and is_instance_valid(player):
		var direction = sign(player.global_position.x - global_position.x)

		if abs(player.global_position.x - global_position.x) > stop_distance:
			velocity.x = direction * chase_speed
			animated_sprite.play("run")
			animated_sprite.flip_h = direction > 0
		else:
			velocity.x = 0
			animated_sprite.play("idle")
	else:
		velocity.x = 0
		animated_sprite.play("idle")

	move_and_slide()


func _on_body_entered(body):
	if body.name == "Player":
		player = body
		player_detected = true

		# Menghindari tabrakan fisik dengan Player
		add_collision_exception_with(body)

		animated_sprite.play("run")


func _on_body_exited(body):
	if body == player:
		player_detected = false
		player = null
		velocity.x = 0
		animated_sprite.play("idle")



func _on_encounter_area_entered(body):

	if body.name == "Player" and not battle_started:

		battle_started = true

		GameManager.start_battle(body, enemy_id)

		get_tree().call_deferred(
			"change_scene_to_file",
            "res://Assets-Battle/Scene-Battle/battle_scene.tscn"
		)
