extends Control

const CHAPTER_SCENES := {
	1: "res://Assets-gameplay/Scenes-gameplay/Areas/areas_2.tscn", 2: "res://Assets-gameplay/Scenes-gameplay/Areas/area_4.tscn",
	3: "res://Assets-gameplay/Scenes-gameplay/Areas/area_6.tscn", 4: "res://Assets-gameplay/Scenes-gameplay/Areas/area_8.tscn",
}

@onready var main_menu: VBoxContainer = $MainMenu
@onready var options: Panel = $Options
@onready var start_menu: Panel = $StartMenu
@onready var arc_select: Panel = $ArcSelect
@onready var arc_1_chapter: Panel = $Arc1Chapter
@onready var arc_2_chapter: Panel = $Arc2Chapter
@onready var arc_3_chapter: Panel = $Arc3Chapter
@onready var continue_button: Button = $StartMenu/VBoxContainer2/VBoxContainer/Continue
@onready var arc_1_button: Button = get_node("ArcSelect/VBoxContainer/VBoxContainer2/Arc 1") as Button
@onready var arc_2_button: Button = get_node("ArcSelect/VBoxContainer/VBoxContainer2/Arc 2") as Button
@onready var arc_3_button: Button = get_node("ArcSelect/VBoxContainer/VBoxContainer2/Arc 3") as Button

func _ready() -> void:
	_show_main_menu()
	_refresh_unlocks()
	PlayerHUD.hide_hud()

func _hide_all_panels() -> void:
	for panel in [main_menu, options, start_menu, arc_select, arc_1_chapter, arc_2_chapter, arc_3_chapter]:
		panel.visible = false

func _show_main_menu() -> void:
	_hide_all_panels()
	main_menu.visible = true

func _refresh_unlocks() -> void:
	continue_button.disabled = false
	arc_1_button.disabled = false
	arc_1_button.tooltip_text = ""
	arc_2_button.disabled = true
	arc_2_button.tooltip_text = "Selesaikan Chapter 4 untuk membuka Arc 2." if arc_2_button.disabled else ""
	arc_3_button.disabled = true
	arc_3_button.tooltip_text = "Arc 3 belum memiliki level gameplay yang siap dimainkan."
	_refresh_arc_chapters(arc_1_chapter, 1, 4)
	_refresh_unavailable_arc(arc_2_chapter, 5, 8)
	_refresh_unavailable_arc(arc_3_chapter, 9, 12)

func _refresh_arc_chapters(panel: Panel, first_chapter: int, last_chapter: int) -> void:
	for chapter in range(first_chapter, last_chapter + 1):
		var button := panel.get_node("VBoxContainer/VBoxContainer2/Chapter%d" % chapter) as Button
		var unlocked := ProgressManager.is_chapter_unlocked(chapter)
		button.disabled = not unlocked
		button.tooltip_text = "" if unlocked else "Selesaikan Chapter %d terlebih dahulu." % (chapter - 1)

func _refresh_unavailable_arc(panel: Panel, first_chapter: int, last_chapter: int) -> void:
	for chapter in range(first_chapter, last_chapter + 1):
		var button := panel.get_node("VBoxContainer/VBoxContainer2/Chapter%d" % chapter) as Button
		button.disabled = true
		button.tooltip_text = "Chapter ini belum memiliki level gameplay yang siap dimainkan."

func _show_arc_chapters(arc: int) -> void:
	_hide_all_panels()
	match arc:
		1: arc_1_chapter.visible = true
		2: arc_2_chapter.visible = true
		3: arc_3_chapter.visible = true

func _start_chapter(chapter: int) -> void:
	if not ProgressManager.is_chapter_unlocked(chapter): return
	var scene_path: String = CHAPTER_SCENES.get(chapter, "")
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("Scene chapter tidak ditemukan: %s" % scene_path)
		return
	get_tree().change_scene_to_file(scene_path)

func _on_start_button_pressed() -> void:
	_hide_all_panels(); start_menu.visible = true
func _on_option_button_pressed() -> void:
	_hide_all_panels(); options.visible = true
func _on_exit_button_pressed() -> void:
	var confirmation := ConfirmationDialog.new()
	confirmation.title = "Exit"
	confirmation.dialog_text = "Are you sure you want to exit?"
	confirmation.ok_button_text = "Yes"
	confirmation.cancel_button_text = "No"
	add_child(confirmation)
	confirmation.confirmed.connect(get_tree().quit)
	confirmation.canceled.connect(confirmation.queue_free)
	confirmation.popup_centered()
func _on_return_button_pressed() -> void: _show_main_menu()
func _on_return_menu_pressed() -> void: _show_main_menu()
func _on_new_game_pressed() -> void:
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://Assets-story/arc_1_intro.tscn")
func _on_continue_pressed() -> void:
	_refresh_unlocks(); _hide_all_panels(); arc_select.visible = true
func _on_arc_1_pressed() -> void: _refresh_unlocks(); _show_arc_chapters(1)
func _on_arc_2_pressed() -> void:
	if ProgressManager.is_chapter_unlocked(5): _refresh_unlocks(); _show_arc_chapters(2)
func _on_arc_3_pressed() -> void: _refresh_unlocks(); _show_arc_chapters(3)
func _on_chapter_1_pressed() -> void: _start_chapter(1)
func _on_chapter_2_pressed() -> void: _start_chapter(2)
func _on_chapter_3_pressed() -> void: _start_chapter(3)
func _on_chapter_4_pressed() -> void: _start_chapter(4)
func _on_chapter_5_pressed() -> void: _start_chapter(5)
func _on_chapter_6_pressed() -> void: _start_chapter(6)
func _on_chapter_7_pressed() -> void: _start_chapter(7)
func _on_chapter_8_pressed() -> void: _start_chapter(8)
func _on_chapter_back_pressed() -> void:
	_hide_all_panels(); arc_select.visible = true
