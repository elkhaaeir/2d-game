
extends Node

# STATUS PLAYER
var player_max_hp = 100
var player_hp = 100

var medkit_count = 3
var senjata_count = 2

var medkit_heal = 30

var senjata_damage = 40
var senjata_duration = 3
var senjata_turns_left = 0

# STATUS OXYGEN
var oxygen_max = 180
var oxygen = 180
var oxygen_count = 2

# DATA PERMAINAN
var current_level_path = ""
var player_position = Vector2.ZERO
var respawn_position = Vector2.ZERO

var defeated_enemies = []
var current_enemy_id = ""

var battle_won = false
var returning_from_battle = false
var player_game_over = false

var game_over_reason = ""

func start_battle(player, enemy_id):
	current_level_path = get_tree().current_scene.scene_file_path
	player_position = player.global_position
	current_enemy_id = enemy_id
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
