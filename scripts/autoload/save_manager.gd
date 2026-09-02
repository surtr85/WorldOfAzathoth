extends Node
## Save/Load system using JSON.

const SAVE_PATH := "user://save_data.json"

func save_game() -> void:
	var data := {
		"current_area": GameManager.current_area,
		"dream_lords_defeated": GameManager.dream_lords_defeated,
		"abilities_unlocked": GameManager.abilities_unlocked,
		"player_deaths": GameManager.player_deaths,
		"player_name": GameManager.player_name,
		"player_gender": GameManager.player_gender,
		"collected_memories": GameManager.collected_memories,
		"current_weapon": GameManager.current_weapon,
		"game_time": GameManager.game_time
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) == OK:
		var data: Dictionary = json.data
		GameManager.current_area = data.get("current_area", "pride_palace")
		GameManager.dream_lords_defeated = data.get("dream_lords_defeated", [false,false,false,false,false,false,false])
		GameManager.abilities_unlocked = data.get("abilities_unlocked", {})
		GameManager.player_deaths = data.get("player_deaths", 0)
		GameManager.player_name = data.get("player_name", "Player")
		GameManager.player_gender = data.get("player_gender", "male")
		GameManager.collected_memories = data.get("collected_memories", [])
		GameManager.current_weapon = data.get("current_weapon", "mercenary_sword")
		GameManager.game_time = data.get("game_time", 0.0)
		return true
	return false

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
