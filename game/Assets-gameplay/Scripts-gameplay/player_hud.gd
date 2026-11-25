
extends CanvasLayer

@onready var hp_label = $MarginContainer/VBoxContainer/HPLabel
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar

@onready var oxygen_label = $MarginContainer/VBoxContainer/OxygenLabel
@onready var oxygen_bar = $MarginContainer/VBoxContainer/OxygenBar

@onready var inventory_label = $MarginContainer/VBoxContainer/InventoryLabel

var hotbar: HBoxContainer
var hotbar_slots: Array[Label] = []

func _ready():
	_build_hotbar()
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
	_update_hotbar()

func _build_hotbar() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.position = Vector2(-180, -104)
	panel.size = Vector2(360, 64)
	panel.modulate = Color(1, 1, 1, 0.93)
	add_child(panel)

	hotbar = HBoxContainer.new()
	hotbar.alignment = BoxContainer.ALIGNMENT_CENTER
	hotbar.add_theme_constant_override("separation", 6)
	panel.add_child(hotbar)

func _update_hotbar() -> void:
	if hotbar_slots.size() != 3:
		return
	hotbar_slots[0].text = "1  MEDKIT\nx%d" % GameManager.medkit_count
	hotbar_slots[1].text = "2  OXYGEN\nx%d" % GameManager.oxygen_count
	hotbar_slots[2].text = "3  SENJATA\nx%d" % GameManager.senjata_count

func show_hud():
	show()

func hide_hud():
	hide()
