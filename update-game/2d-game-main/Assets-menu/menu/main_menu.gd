extends Control

@onready var main_menu: VBoxContainer = $MainMenu
@onready var options: Panel = $Options
@onready var start_menu: Panel = $StartMenu

func _ready() -> void:
    _show_main_menu()

func _show_main_menu() -> void:
    main_menu.visible = true
    options.visible = false
    start_menu.visible = false

func _on_start_button_pressed() -> void:
    main_menu.visible = false
    start_menu.visible = true

func _on_option_button_pressed() -> void:
    main_menu.visible = false
    options.visible = true

func _on_exit_button_pressed() -> void:
    get_tree().quit()

func _on_return_button_pressed() -> void:
    _show_main_menu()

func _on_return_menu_pressed() -> void:
    _show_main_menu()

func _on_new_game_pressed() -> void:
    ProgressManager.reset_progress()
    get_tree().change_scene_to_file("res://Assets-gameplay/Scenes-gameplay/Areas/areas_1.tscn")
