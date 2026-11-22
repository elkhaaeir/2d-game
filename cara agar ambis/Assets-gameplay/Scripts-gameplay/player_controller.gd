extends CharacterBody2D
class_name PlayerController

@export var speed = 10.0
@export var jump_power = 10.0
@onready var interaction_area: Area2D = $Direction/InteractionArea

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var oxygen_timer = 0.0

const DIALOGUE_RESOURCE: DialogueResource = preload("res://Assets-gameplay/Scripts-gameplay/dialogueCharacter/dialogue1.dialogue")
var dialogue_balloon: CanvasLayer = null
var nearby_npc: Node = null


func _ready():

	if GameManager.returning_from_battle:

		# Menunggu Area selesai mengatur Respawn Point
		await get_tree().process_frame

		if GameManager.player_game_over:

			# Kembali ke Respawn Point
			global_position = GameManager.respawn_position

			# Memulihkan HP dan Oxygen
			GameManager.player_hp = GameManager.player_max_hp
			GameManager.oxygen = GameManager.oxygen_max

			# Mengatur ulang status Game Over
			GameManager.player_game_over = false
			GameManager.game_over_reason = ""

		else:

			# Kembali ke posisi sebelum Battle
			global_position = GameManager.player_position

		GameManager.returning_from_battle = false

	# Mengatur ulang timer Oxygen
	oxygen_timer = 0.0

	PlayerHUD.show_hud()
	PlayerHUD.update_hud()


func _unhandled_input(_event: InputEvent):

	if Input.is_action_just_pressed("inventory"):

		if InventoryArea.visible:
			InventoryArea.close_inventory()
		else:
			InventoryArea.open_inventory()

		return

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

func _process(delta):
	oxygen_timer += delta

	while oxygen_timer >= 1.0:
		oxygen_timer -= 1.0

		if GameManager.oxygen > 0:
			GameManager.oxygen -= 1
			PlayerHUD.update_hud()
			
			if InventoryArea.visible:
				InventoryArea.update_inventory()

		if GameManager.oxygen <= 0:
			GameManager.oxygen = 0
			GameManager.player_game_over = true
			GameManager.game_over_reason = "oxygen"

			# Menyimpan scene Area saat ini
			GameManager.current_level_path = get_tree().current_scene.scene_file_path

			# Berpindah ke tampilan Game Over
			get_tree().change_scene_to_file("res://Assets-Battle/Scene-Battle/battle_scene.tscn")
			return
