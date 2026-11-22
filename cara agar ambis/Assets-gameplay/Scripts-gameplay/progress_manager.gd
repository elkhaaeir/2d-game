extends Node

const SAVE_PATH := "user://progress.cfg"
const SAVE_SECTION := "progress"
const SAVE_KEY := "highest_unlocked_chapter"

var highest_unlocked_chapter: int = 1

func _ready() -> void:
	load_progress()

func load_progress() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error == OK:
		highest_unlocked_chapter = int(config.get_value(SAVE_SECTION, SAVE_KEY, 1))
	else:
		highest_unlocked_chapter = 1

	highest_unlocked_chapter = clampi(highest_unlocked_chapter, 1, 4)

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value(SAVE_SECTION, SAVE_KEY, highest_unlocked_chapter)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Gagal menyimpan progres game. Error: %s" % error)

func unlock_chapter(chapter: int) -> void:
	if chapter < 1 or chapter > 4:
		push_warning("Nomor chapter tidak valid: %s" % chapter)
		return

	if chapter > highest_unlocked_chapter:
		highest_unlocked_chapter = chapter
		save_progress()

func is_chapter_unlocked(chapter: int) -> bool:
	return chapter >= 1 and chapter <= highest_unlocked_chapter

func has_progress() -> bool:
	return highest_unlocked_chapter > 1

func reset_progress() -> void:
	highest_unlocked_chapter = 1
	save_progress()
