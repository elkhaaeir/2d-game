
extends CanvasLayer

@onready var medkit_count = $PanelContainer/HBoxContainer/MedkitSlot/MedkitCount
@onready var oxygen_count = $PanelContainer/HBoxContainer/OxygenSlot/OxygenCount
@onready var weapon_count = $PanelContainer/HBoxContainer/WeaponSlot/WeaponCount


func _ready():
	show()
	update_inventory()


# ==================================
# MEMPERBARUI INVENTORY
# ==================================

func update_inventory():
	medkit_count.text = "x%d" % GameManager.medkit_count
	oxygen_count.text = "x%d" % GameManager.oxygen_count
	weapon_count.text = "x%d" % GameManager.senjata_count


# ==================================
# MENGGUNAKAN ITEM
# ==================================

func _process(_delta):
	if Input.is_action_just_pressed("use_medkit"):
		use_medkit()

	if Input.is_action_just_pressed("use_oxygen"):
		use_oxygen()

	if Input.is_action_just_pressed("use_weapon"):
		use_weapon()


# ==================================
# MENGGUNAKAN MEDKIT
# ==================================

func use_medkit():
	if GameManager.medkit_count <= 0:
		return

	if GameManager.player_hp >= GameManager.player_max_hp:
		return

	GameManager.player_hp += GameManager.medkit_heal

	if GameManager.player_hp > GameManager.player_max_hp:
		GameManager.player_hp = GameManager.player_max_hp

	GameManager.medkit_count -= 1

	update_inventory()
	PlayerHUD.update_hud()

	print("Medkit digunakan!")


# ==================================
# MENGGUNAKAN OXYGEN
# ==================================

func use_oxygen():
	if GameManager.oxygen_count <= 0:
		return

	if GameManager.oxygen >= GameManager.oxygen_max:
		return

	GameManager.oxygen = GameManager.oxygen_max
	GameManager.oxygen_count -= 1

	update_inventory()
	PlayerHUD.update_hud()

	print("Oxygen digunakan!")


# ==================================
# MENGGUNAKAN SENJATA
# ==================================

func use_weapon():
	if GameManager.senjata_count <= 0:
		return

	if GameManager.senjata_turns_left > 0:
		return

	GameManager.senjata_count -= 1
	GameManager.senjata_turns_left = GameManager.senjata_duration

	update_inventory()
	PlayerHUD.update_hud()

	print("Senjata diaktifkan!")
