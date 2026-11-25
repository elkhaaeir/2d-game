extends Area2D

@export_enum("medkit", "oxygen") var item_type := "medkit"
@export var amount := 1
@onready var prompt: Label = $Prompt
var player_in_range := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("dialogue"):
		if GameManager.add_item(item_type, amount):
			GameManager.update_player_hud()
			if InventoryArea.visible:
				InventoryArea.update_inventory()
			queue_free()
		else:
			prompt.text = "Inventori penuh"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		prompt.visible = false
