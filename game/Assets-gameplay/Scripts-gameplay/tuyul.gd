
extends CharacterBody2D

@export var enemy_id: String = "tuyul_1"
@export var patrol_speed = 130.0

# ==================================
# PENGATURAN DAMAGE OXYGEN
# ==================================

var can_damage = true
var oxygen_damage = 15
var damage_cooldown = 1.5

# ==================================
# STATUS INTERAKSI DAN BATTLE
# ==================================

var player_nearby = false
var nearby_player = null
var battle_started = false

# ==================================
# MENGAMBIL NODE
# ==================================

@onready var animated_sprite = $AnimatedSprite2D

@onready var damage_area = $DamageArea
@onready var interaction_area = $InteractionArea
@onready var interaction_prompt = $InteractionPrompt

@onready var patrol_left = $PatrolLeft
@onready var patrol_right = $PatrolRight

# ==================================
# PENGATURAN PATROLI
# ==================================

var direction = 1

var left_limit = 0.0
var right_limit = 0.0


func _ready():
	# Menghilangkan Tuyul jika sudah dikalahkan
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()
		return

	# Mengambil posisi batas patroli
	left_limit = patrol_left.global_position.x
	right_limit = patrol_right.global_position.x

	# Menyembunyikan tulisan interaksi
	interaction_prompt.visible = false

	# Menghubungkan Signal DamageArea
	damage_area.body_entered.connect(_on_damage_area_body_entered)

	# Menghubungkan Signal InteractionArea
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)


# ==================================
# GERAKAN TUYUL
# ==================================

func _physics_process(delta):
	if battle_started:
		velocity.x = 0
		return

	# Berbalik ketika mencapai batas patroli
	if global_position.x <= left_limit:
		direction = 1
	elif global_position.x >= right_limit:
		direction = -1

	# Mengatur kecepatan horizontal
	velocity.x = direction * patrol_speed

	# Mengatur gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Membalik sprite sesuai arah gerakan
	animated_sprite.flip_h = direction > 0

	# Menjalankan animasi
	animated_sprite.play("run")

	move_and_slide()


# ==================================
# INPUT TOMBOL ENTER
# ==================================

func _process(_delta):
	if battle_started:
		return

	if player_nearby and Input.is_action_just_pressed("dialogue"):
		print("Tombol ENTER terdeteksi!")
		start_tuyul_battle()


# ==================================
# DAMAGE OXYGEN
# ==================================

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if battle_started:
		return

	if not can_damage:
		return

	can_damage = false

	# Mengurangi Oxygen sebanyak 15 detik
	GameManager.oxygen -= oxygen_damage

	if GameManager.oxygen < 0:
		GameManager.oxygen = 0

	# Memperbarui HUD
	PlayerHUD.update_hud()

	# Memperbarui Inventory jika sedang terbuka
	if InventoryArea.visible:
		InventoryArea.update_inventory()

	print("Oxygen berkurang 15 detik!")
	print("Sisa Oxygen: ", GameManager.oxygen)

	# Menunggu cooldown
	await get_tree().create_timer(damage_cooldown).timeout

	can_damage = true


# ==================================
# INTERAKSI PLAYER
# ==================================

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if battle_started:
		return

	player_nearby = true
	nearby_player = body

	interaction_prompt.visible = true

	# Menghindari tabrakan fisik dengan Player
	add_collision_exception_with(body)

	print("Player terdeteksi di dekat Tuyul!")


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return

	player_nearby = false
	nearby_player = null

	interaction_prompt.visible = false

	# Menghapus pengecualian tabrakan saat Player menjauh
	remove_collision_exception_with(body)

	print("Player menjauh dari Tuyul!")


# ==================================
# MEMULAI BATTLE
# ==================================

func start_tuyul_battle():
	if battle_started:
		return

	if not is_instance_valid(nearby_player):
		print("Player tidak ditemukan!")
		return

	battle_started = true
	player_nearby = false

	interaction_prompt.visible = false

	print("Memulai battle Tuyul!")

	# Menyimpan data sebelum masuk Battle Scene
	GameManager.start_battle(
		nearby_player,
		enemy_id,
		"tuyul"
	)

	# Berpindah ke Battle Scene Tuyul
	get_tree().call_deferred(
		"change_scene_to_file",
		"res://Assets-Battle/Scene-Battle/tuyul_battle.tscn"
	)
