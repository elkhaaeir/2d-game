extends CharacterBody2D
class_name PlayerController

@export var speed = 10.0
@export var jump_power = 10.0
@onready var interaction_area: Area2D = $Direction/InteractionArea

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const DIALOGUE_RESOURCE: DialogueResource = preload("res://Assets-gameplay/Scripts-gameplay/dialogueCharacter/dialogue1.dialogue")
var dialogue_balloon: CanvasLayer = null
var nearby_npc: Node = null

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dialogue"):
		var interactions = interaction_area.get_overlapping_areas()
		if interactions.size() > 0:
			interactions[0].action()
			return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# Disable the one-way platform collision only while the down key is held.
	if event.is_action_pressed("move_down"):
		set_collision_mask_value(10, false)
	elif event.is_action_released("move_down"):
		set_collision_mask_value(10, true)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * speed_multiplier)

	move_and_slide()
