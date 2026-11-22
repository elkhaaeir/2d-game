
extends CanvasLayer

@onready var hp_label = $MarginContainer/VBoxContainer/HPLabel
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar

@onready var oxygen_label = $MarginContainer/VBoxContainer/OxygenLabel
@onready var oxygen_bar = $MarginContainer/VBoxContainer/OxygenBar

@onready var inventory_label = $MarginContainer/VBoxContainer/InventoryLabel

func _ready():
	update_hud()

func update_hud():
	# UPDATE HP
	hp_bar.max_value = GameManager.player_max_hp
	hp_bar.value = GameManager.player_hp

	hp_label.text = "HP: " + str(GameManager.player_hp) + " / " + str(GameManager.player_max_hp)

	# UPDATE OXYGEN
	oxygen_bar.max_value = GameManager.oxygen_max
	oxygen_bar.value = GameManager.oxygen

	var minutes = int(GameManager.oxygen / 60)
	var seconds = GameManager.oxygen % 60

	oxygen_label.text = "Oxygen: %02d:%02d" % [minutes, seconds]

	# UPDATE INVENTORY
	inventory_label.text = "Medkit: " + str(GameManager.medkit_count) + " | Senjata: " + str(GameManager.senjata_count) + " | Oxygen: " + str(GameManager.oxygen_count)

func show_hud():
	show()

func hide_hud():
	hide()
