
extends CanvasLayer

@onready var inventory_panel = $CenterContainer
@onready var medkit_button = $CenterContainer/PanelContainer/VBoxContainer/MedkitButton
@onready var oxygen_button = $CenterContainer/PanelContainer/VBoxContainer/OxygenButton
@onready var close_button = $CenterContainer/PanelContainer/VBoxContainer/CloseButton


func _ready():

	hide()

	medkit_button.pressed.connect(_on_medkit_pressed)
	oxygen_button.pressed.connect(_on_oxygen_pressed)
	close_button.pressed.connect(_on_close_pressed)

	update_inventory()


# MEMBUKA INVENTORY
func open_inventory():

	update_inventory()
	show()


# MENUTUP INVENTORY
func close_inventory():

	hide()


# MEMPERBARUI JUMLAH ITEM
func update_inventory():

	# Memperbarui jumlah item
	medkit_button.text = "Medkit x%d/%d" % [GameManager.medkit_count, GameManager.medkit_capacity]
	oxygen_button.text = "Oxygen x%d/%d" % [GameManager.oxygen_count, GameManager.oxygen_capacity]

	# Memperbarui deskripsi
	$CenterContainer/PanelContainer/VBoxContainer/MedkitDescription.text = "Memulihkan 30 HP."
	$CenterContainer/PanelContainer/VBoxContainer/OxygenDescription.text = "Mengisi Oxygen hingga 03:00."

	# Mengatur tombol Medkit
	medkit_button.disabled = (
		GameManager.medkit_count <= 0
		or GameManager.player_hp >= GameManager.player_max_hp
	)

	# Mengatur tombol Oxygen
	oxygen_button.disabled = (
		GameManager.oxygen_count <= 0
		or GameManager.oxygen >= GameManager.oxygen_max
	)


# MENGGUNAKAN MEDKIT
func _on_medkit_pressed():

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


# MENGGUNAKAN OXYGEN
func _on_oxygen_pressed():

	if GameManager.oxygen_count <= 0:
		return

	if GameManager.oxygen >= GameManager.oxygen_max:
		return

	GameManager.oxygen = GameManager.oxygen_max
	GameManager.oxygen_count -= 1

	update_inventory()
	PlayerHUD.update_hud()


# TOMBOL CLOSE
func _on_close_pressed():

	close_inventory()
