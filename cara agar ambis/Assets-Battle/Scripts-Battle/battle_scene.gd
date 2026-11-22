
extends Control


# ==================================
# MENGAMBIL NODE
# ==================================

@onready var player_hp_bar = $PlayerStatus/PlayerHP
@onready var enemy_hp = $EnemyStatus/EnemyHP
@onready var message = $BattleUI/Message

@onready var attack_button = $BattleUI/CenterContainer/ActionMenu/AttackButton
@onready var defend_button = $BattleUI/CenterContainer/ActionMenu/DefendButton
@onready var item_button = $BattleUI/CenterContainer/ActionMenu/ItemButton
@onready var run_button = $BattleUI/CenterContainer/ActionMenu/RunButton

@onready var inventory_panel = $InventoryPanel
@onready var close_button = $InventoryPanel/VBoxContainer/CloseButton

@onready var medkit_button = $InventoryPanel/VBoxContainer/ItemList/MedkitButton
@onready var senjata_button = $InventoryPanel/VBoxContainer/ItemList/SenjataButton

@onready var weapon_status = $PlayerStatus/WeaponStatus

@onready var battle_result = $BattleResult
@onready var result_title = $BattleResult/VBoxContainer/ResultTitle
@onready var result_message = $BattleResult/VBoxContainer/ResultMessage
@onready var back_button = $BattleResult/VBoxContainer/BackButton


# ==================================
# STATUS PERTARUNGAN
# ==================================

var enemy_max_hp = 100
var enemy_damage = 10

var attack_damage = 20

var enemy_defeated = false
var player_defeated = false
var player_escaped = false
var battle_won = false

var is_defending = false


# ==================================
# PERSIAPAN AWAL
# ==================================

func _ready():
	
	PlayerHUD.hide_hud()

	# Mengatur HP pemain dari GameManager
	player_hp_bar.max_value = GameManager.player_max_hp
	player_hp_bar.value = GameManager.player_hp

	# Mengatur HP musuh
	enemy_hp.max_value = enemy_max_hp
	enemy_hp.value = enemy_max_hp

	# Menyembunyikan panel awal
	inventory_panel.hide()
	battle_result.hide()

	# Menghubungkan tombol Battle
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	item_button.pressed.connect(_on_item_button_pressed)
	run_button.pressed.connect(_on_run_pressed)

	# Menghubungkan tombol Inventory
	close_button.pressed.connect(_on_close_button_pressed)
	medkit_button.pressed.connect(_on_medkit_pressed)
	senjata_button.pressed.connect(_on_senjata_pressed)

	# Menghubungkan tombol hasil pertarungan
	back_button.pressed.connect(_on_back_pressed)

	# Memperbarui tampilan
	_update_inventory()
	_update_weapon_status()
	GameManager.update_player_hud()

	message.text = "Pilih tindakanmu!"
	
	if GameManager.player_game_over and GameManager.game_over_reason == "oxygen":

		# Menyembunyikan seluruh tampilan Battle
		$Enemy.hide()
		$EnemyStatus.hide()
		$PlayerStatus.hide()
		$BattleUI.hide()
		$InventoryPanel.hide()

		# Menampilkan Game Over
		result_title.text = "GAME OVER"
		result_message.text = "Kamu kehabisan oksigen akibat asap!"

		battle_result.show()


# ==================================
# MENGATUR TOMBOL BATTLE
# ==================================

func _set_action_buttons_disabled(value):

	attack_button.disabled = value
	defend_button.disabled = value
	item_button.disabled = value
	run_button.disabled = value


# ==================================
# SISTEM ATTACK
# ==================================

func _on_attack_pressed():

	if enemy_defeated or player_defeated or player_escaped:
		return

	_set_action_buttons_disabled(true)

	is_defending = false

	var current_damage = attack_damage

	# Memeriksa efek Senjata
	if GameManager.senjata_turns_left > 0:

		current_damage = GameManager.senjata_damage
		GameManager.senjata_turns_left -= 1

		_update_weapon_status()

	# Mengurangi HP musuh
	enemy_hp.value -= current_damage

	# Memeriksa apakah musuh kalah
	if enemy_hp.value <= 0:

		enemy_hp.value = 0
		enemy_defeated = true
		battle_won = true

		message.text = "Monster Ungu berhasil dikalahkan!"

		_show_battle_result(
			"VICTORY!",
			"Kamu berhasil mengalahkan Monster Ungu!"
		)

		return

	else:

		message.text = "Kamu menyerang! Damage: " + str(current_damage)

	# Menampilkan sisa efek Senjata
	if GameManager.senjata_turns_left > 0:

		message.text += " | Efek Senjata: " + str(GameManager.senjata_turns_left)

	await get_tree().create_timer(1.0).timeout

	_enemy_turn()

	if not player_defeated:

		_set_action_buttons_disabled(false)


# ==================================
# SISTEM DEFEND
# ==================================

func _on_defend_pressed():

	if enemy_defeated or player_defeated or player_escaped:
		return

	_set_action_buttons_disabled(true)

	is_defending = true

	message.text = "Kamu bersiap untuk bertahan!"

	await get_tree().create_timer(1.0).timeout

	_enemy_turn()

	is_defending = false

	if not player_defeated:

		_set_action_buttons_disabled(false)


# ==================================
# GILIRAN MUSUH
# ==================================

func _enemy_turn():

	var damage_received = enemy_damage
	var is_critical = false

	# Menentukan apakah serangan musuh menjadi critical
	if randi_range(1, 100) <= 35:

		damage_received *= 3
		is_critical = true

	# Mengurangi damage jika player sedang defend
	if is_defending:

		damage_received = int(damage_received / 2)

	# Mengurangi HP player
	GameManager.player_hp -= damage_received

	if GameManager.player_hp <= 0:

		GameManager.player_hp = 0
		player_defeated = true
		GameManager.player_game_over = true
		GameManager.game_over_reason = "battle"

		message.text = "Kamu dikalahkan oleh Monster Ungu!"

		_show_battle_result(
			"GAME OVER",
			"Kamu telah dikalahkan oleh Monster Ungu."
		)

	else:

		if is_critical:

			message.text = "CRITICAL ATTACK! Monster menyerang dengan damage: " + str(damage_received)

		else:

			message.text = "Monster menyerang! Damage: " + str(damage_received)

	# Memperbarui HP pada Battle dan HUD
	player_hp_bar.value = GameManager.player_hp
	GameManager.update_player_hud()


# ==================================
# MEMBUKA DAN MENUTUP INVENTORY
# ==================================

func _on_item_button_pressed():

	if enemy_defeated or player_defeated or player_escaped:
		return

	inventory_panel.show()


func _on_close_button_pressed():

	inventory_panel.hide()


# ==================================
# MEMPERBARUI INVENTORY
# ==================================

func _update_inventory():

	medkit_button.text = "Medkit x" + str(GameManager.medkit_count)
	senjata_button.text = "Senjata x" + str(GameManager.senjata_count)


# ==================================
# MENGGUNAKAN MEDKIT
# ==================================

func _on_medkit_pressed():

	if enemy_defeated or player_defeated or player_escaped:
		return

	# Memeriksa jumlah Medkit
	if GameManager.medkit_count <= 0:

		message.text = "Medkit sudah habis!"
		return

	# Memeriksa HP pemain
	if GameManager.player_hp >= GameManager.player_max_hp:

		message.text = "HP kamu masih penuh!"
		return

	_set_action_buttons_disabled(true)

	is_defending = false

	# Memulihkan HP pemain
	GameManager.player_hp += GameManager.medkit_heal

	# Membatasi HP maksimal
	if GameManager.player_hp > GameManager.player_max_hp:

		GameManager.player_hp = GameManager.player_max_hp

	# Mengurangi jumlah Medkit
	GameManager.medkit_count -= 1

	# Memperbarui tampilan
	player_hp_bar.value = GameManager.player_hp
	_update_inventory()
	GameManager.update_player_hud()

	message.text = "Medkit digunakan! HP kamu: " + str(GameManager.player_hp)

	inventory_panel.hide()

	await get_tree().create_timer(1.0).timeout

	_enemy_turn()

	if not player_defeated:

		_set_action_buttons_disabled(false)


# ==================================
# MENGGUNAKAN SENJATA
# ==================================

func _on_senjata_pressed():

	if enemy_defeated or player_defeated or player_escaped:
		return

	# Memeriksa jumlah Senjata
	if GameManager.senjata_count <= 0:

		message.text = "Senjata sudah habis!"
		return

	_set_action_buttons_disabled(true)

	is_defending = false

	# Mengaktifkan efek Senjata
	GameManager.senjata_turns_left = GameManager.senjata_duration

	_update_weapon_status()

	# Mengurangi jumlah Senjata
	GameManager.senjata_count -= 1

	_update_inventory()
	GameManager.update_player_hud()

	message.text = "Senjata digunakan! Damage Attack menjadi 40!"

	inventory_panel.hide()

	await get_tree().create_timer(1.0).timeout

	_enemy_turn()

	if not player_defeated:

		_set_action_buttons_disabled(false)


# ==================================
# STATUS SENJATA
# ==================================

func _update_weapon_status():

	if GameManager.senjata_turns_left > 0:

		weapon_status.text = "Senjata Aktif! Sisa: " + str(GameManager.senjata_turns_left) + " serangan"

		weapon_status.show()

	else:

		weapon_status.hide()


# ==================================
# SISTEM RUN
# ==================================

func _on_run_pressed():

	if enemy_defeated or player_defeated or player_escaped:
		return

	player_escaped = true

	message.text = "Kamu berhasil melarikan diri!"

	_show_battle_result(
		"ESCAPED!",
		"Kamu berhasil melarikan diri dari pertarungan."
	)


# ==================================
# SISTEM HASIL PERTARUNGAN
# ==================================

func _show_battle_result(title, description):

	_set_action_buttons_disabled(true)

	inventory_panel.hide()

	result_title.text = title
	result_message.text = description

	battle_result.show()


# ==================================
# TOMBOL KEMBALI
# ==================================

func _on_back_pressed():

	if GameManager.player_game_over:
		GameManager.finish_battle(false)
		GameManager.return_to_level()
		return

	GameManager.finish_battle(battle_won)

	GameManager.return_to_level()
