extends CharacterBody2D
class_name PlayerController

@export var speed = 10.0
@export var jump_power = 10.0
@onready var interaction_area: Area2D = $Direction/InteractionArea
@onready var footsteps: AudioStreamPlayer = $Footsteps

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var oxygen_timer = 0.0
var footstep_timer := 0.0

const DIALOGUE_RESOURCE: DialogueResource = preload("res://Assets-gameplay/Scripts-gameplay/dialogueCharacter/dialogue1.dialogue")
var dialogue_balloon: CanvasLayer = null
var nearby_npc: Node = null
var interaction_hint: Label


func _ready():
	if not GameManager.returning_from_battle and get_parent().get_node_or_null("RespawnPoint") == null:
		GameManager.set_respawn_point(global_position)

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
	_create_horror_atmosphere()
	_create_interaction_hint()
	_create_controls_hint()


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
	_update_interaction_hint()
	_update_footsteps(delta)

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

func _create_interaction_hint() -> void:
	interaction_hint = Label.new()
	interaction_hint.text = "[ENTER] Interaksi / Bicara"
	interaction_hint.position = Vector2(24, 105)
	interaction_hint.add_theme_font_size_override("font_size", 22)
	interaction_hint.add_theme_color_override("font_color", Color(1, 0.9, 0.45))
	interaction_hint.visible = false
	var ui := CanvasLayer.new()
	ui.layer = 20
	ui.add_child(interaction_hint)
	add_child(ui)

func _create_controls_hint() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 19
	var hint := Label.new()
	hint.text = "A/D or Left/Right: Move   |   Space/W/Up: Jump   |   S/Down: Drop   |   Enter: Talk   |   Esc: Pause"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -32
	hint.offset_bottom = -4
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color.WHITE)
	hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	hint.add_theme_constant_override("shadow_offset_x", 2)
	hint.add_theme_constant_override("shadow_offset_y", 2)
	ui.add_child(hint)
	add_child(ui)

func _create_horror_atmosphere() -> void:
	var scene_path := get_tree().current_scene.scene_file_path
	var danger_level := 0
	if "area_4" in scene_path:
		danger_level = 1
	elif "area_6" in scene_path or "area_8" in scene_path:
		danger_level = 2
	if danger_level == 0:
		return
	var ui := CanvasLayer.new()
	ui.layer = 5
	var fog := ColorRect.new()
	fog.color = Color(0.03, 0.08, 0.07, 0.16 + danger_level * 0.06)
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(fog)
	var warning := Label.new()
	warning.text = "SENSOR: %s" % ("GANGGUAN TERDETEKSI" if danger_level == 1 else "BAHAYA TINGGI - JAGA OXYGEN")
	warning.position = Vector2(24, 124)
	warning.add_theme_font_size_override("font_size", 16)
	warning.add_theme_color_override("font_color", Color(1, 0.55, 0.35))
	ui.add_child(warning)
	add_child(ui)

func _update_interaction_hint() -> void:
	if is_instance_valid(interaction_hint):
		interaction_hint.visible = interaction_area.has_overlapping_areas()

func _update_footsteps(delta: float) -> void:
	if is_on_floor() and absf(velocity.x) > 5.0:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			footsteps.play()
			footstep_timer = 0.33
	else:
		footstep_timer = 0.0
