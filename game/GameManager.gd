
extends Node

# STATUS PLAYER
var player_max_hp = 100
var player_hp = 100

var medkit_count = 3
var medkit_capacity = 5
var senjata_count = 2

var medkit_heal = 30

var senjata_damage = 40
var senjata_duration = 3
var senjata_turns_left = 0

# STATUS OXYGEN
var oxygen_max = 180
var oxygen = 180
var oxygen_count = 2
var oxygen_capacity = 3

# DATA PERMAINAN
var current_level_path = ""
var player_position = Vector2.ZERO
var respawn_position = Vector2.ZERO

var defeated_enemies = []
var current_enemy_id = ""
var current_enemy_type = "green_monster"

var battle_won = false
var returning_from_battle = false
var player_game_over = false

var game_over_reason = ""

func reset_run() -> void:
	player_max_hp = 100
	player_hp = 100
	medkit_count = 3
	senjata_count = 2
	senjata_turns_left = 0
	oxygen = oxygen_max
	oxygen_count = 2
	current_level_path = ""
	player_position = Vector2.ZERO
	respawn_position = Vector2.ZERO
	defeated_enemies.clear()
	current_enemy_id = ""
	current_enemy_type = "green_monster"
	battle_won = false
	returning_from_battle = false
	player_game_over = false
	game_over_reason = ""

func start_battle(player, enemy_id, enemy_type := "green_monster"):
	current_level_path = get_tree().current_scene.scene_file_path
	player_position = player.global_position
	current_enemy_id = enemy_id
	current_enemy_type = enemy_type
	battle_won = false

func finish_battle(victory):
	battle_won = victory
	if victory:
		if not defeated_enemies.has(current_enemy_id):
			defeated_enemies.append(current_enemy_id)

func set_respawn_point(position):
	respawn_position = position

func return_to_level():
	returning_from_battle = true
	get_tree().change_scene_to_file(current_level_path)

func update_player_hud():
	PlayerHUD.update_hud()

func add_item(item_type: String, amount := 1) -> bool:
	if item_type == "medkit":
		if medkit_count >= medkit_capacity:
			return false
		medkit_count = mini(medkit_count + amount, medkit_capacity)
		return true
	if item_type == "oxygen":
		if oxygen_count >= oxygen_capacity:
			return false
		oxygen_count = mini(oxygen_count + amount, oxygen_capacity)
		return true
	return false
