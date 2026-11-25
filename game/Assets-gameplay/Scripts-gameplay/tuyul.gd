extends CharacterBody2D

@export var enemy_id: String = "tuyul_1"

# Pengaturan damage Oxygen
var can_damage = true
var oxygen_damage = 15
var damage_cooldown = 1.5

# Kecepatan gerakan Tuyul
@export var patrol_speed = 130.0

# Mengambil node
@onready var animated_sprite = $AnimatedSprite2D
@onready var patrol_left = $PatrolLeft
@onready var patrol_right = $PatrolRight

# Arah gerakan
var direction = 1

# Batas patroli
var left_limit = 0.0
var right_limit = 0.0
var battle_started := false


func _ready():
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()
		return

	# Mengambil posisi kedua batas patroli
	left_limit = patrol_left.global_position.x
	right_limit = patrol_right.global_position.x


func _physics_process(delta):
	if battle_started:
		velocity.x = 0
		return

	# Jika mencapai batas kiri, berbalik ke kanan
	if global_position.x <= left_limit:
		direction = 1

	# Jika mencapai batas kanan, berbalik ke kiri
	elif global_position.x >= right_limit:
		direction = -1

	# Mengatur kecepatan horizontal
	velocity.x = direction * patrol_speed

	# Mengatur gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Membalik sprite sesuai arah gerakan
	animated_sprite.flip_h = direction > 0
	
	# animasi lari
	animated_sprite.play("run")

	# Menjalankan gerakan
	move_and_slide()


func _on_damage_area_body_entered(body: Node2D) -> void:

	# Memastikan yang terkena adalah Player
	if body.name != "Player":
		return
	if battle_started:
		return

	# Enemy kecil memakai alur battle yang sama seperti monster hijau.
	battle_started = true
	GameManager.start_battle(body, enemy_id, "tuyul")
	get_tree().call_deferred("change_scene_to_file", "res://Assets-Battle/Scene-Battle/tuyul_battle.tscn")
	return

	# Memeriksa cooldown damage
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

	# Menunggu sebelum damage berikutnya
	await get_tree().create_timer(damage_cooldown).timeout

	can_damage = true
