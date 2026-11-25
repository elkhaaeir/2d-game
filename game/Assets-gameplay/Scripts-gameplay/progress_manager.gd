extends Node

## Hanya chapter yang memiliki level gameplay lengkap yang dapat dibuka.
const SAVE_PATH := "user://progress.cfg"
const SAVE_SECTION := "progress"
const SAVE_KEY := "highest_unlocked_chapter"
const FIRST_CHAPTER := 1
const LAST_PLAYABLE_CHAPTER := 4

var highest_unlocked_chapter: int = FIRST_CHAPTER

func _ready() -> void:
	load_progress()

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		if config.has_section_key(SAVE_SECTION, "even_areas_highest"):
			highest_unlocked_chapter = int(config.get_value(SAVE_SECTION, "even_areas_highest", FIRST_CHAPTER))
		else:
			var previous := int(config.get_value(SAVE_SECTION, SAVE_KEY, FIRST_CHAPTER))
			highest_unlocked_chapter = maxi(1, previous / 2)
	else:
		highest_unlocked_chapter = FIRST_CHAPTER

	highest_unlocked_chapter = clampi(highest_unlocked_chapter, FIRST_CHAPTER, LAST_PLAYABLE_CHAPTER)

func save_progress() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	config.set_value(SAVE_SECTION, "even_areas_highest", highest_unlocked_chapter)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Gagal menyimpan progres game. Error: %s" % error)

func unlock_chapter(chapter: int) -> void:
	if chapter < FIRST_CHAPTER or chapter > LAST_PLAYABLE_CHAPTER:
		push_warning("Chapter tidak tersedia: %s" % chapter)
		return

	if chapter > highest_unlocked_chapter:
		highest_unlocked_chapter = chapter
		save_progress()

func is_chapter_unlocked(chapter: int) -> bool:
	return chapter >= FIRST_CHAPTER and chapter <= highest_unlocked_chapter and chapter <= LAST_PLAYABLE_CHAPTER

func has_progress() -> bool:
	return highest_unlocked_chapter > FIRST_CHAPTER

func reset_progress() -> void:
	highest_unlocked_chapter = FIRST_CHAPTER
	save_progress()
