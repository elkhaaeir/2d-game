
extends CanvasLayer

@onready var hp_label = $MarginContainer/VBoxContainer/HPLabel
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar
@onready var inventory_label = $MarginContainer/VBoxContainer/InventoryLabel

func _ready():
	update_hud()

func update_hud():
	hp_bar.max_value = GameManager.player_max_hp
	hp_bar.value = GameManager.player_hp

	hp_label.text = "HP: " + str(GameManager.player_hp) + " / " + str(GameManager.player_max_hp)

	inventory_label.text = "Medkit: " + str(GameManager.medkit_count) + " | Senjata: " + str(GameManager.senjata_count)
