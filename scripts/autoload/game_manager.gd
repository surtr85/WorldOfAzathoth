class_name GameManager
extends Node
## Global game state manager for World of Azathoth.

signal dream_lord_defeated_signal(lord_index: int)
signal ability_unlocked_signal(ability_name: String)
signal memory_collected_signal(memory_id: String)
signal game_reset

var current_area: String = "pride_palace"
var dream_lords_defeated: Array[bool] = [false, false, false, false, false, false, false]
var abilities_unlocked: Dictionary = {
	"dream_dash": false,
	"shadow_step": false,
	"gravity_break": false,
	"dream_hook": false,
	"memory_dive": false,
	"time_fracture": false,
	"nightmare_form": false
}
var player_deaths: int = 0
var player_name: String = "Player"
var player_gender: String = "male"
var collected_memories: Array[String] = []
var current_weapon: String = "mercenary_sword"
var game_time: float = 0.0

func _process(delta: float) -> void:
	game_time += delta

func defeat_dream_lord(index: int) -> void:
	if index >= 0 and index < dream_lords_defeated.size():
		dream_lords_defeated[index] = true
		dream_lord_defeated_signal.emit(index)

func unlock_ability(ability_name: String) -> void:
	if abilities_unlocked.has(ability_name):
		abilities_unlocked[ability_name] = true
		ability_unlocked_signal.emit(ability_name)

func is_ability_unlocked(ability_name: String) -> bool:
	return abilities_unlocked.get(ability_name, false)

func add_memory(memory_id: String) -> void:
	if not collected_memories.has(memory_id):
		collected_memories.append(memory_id)
		memory_collected_signal.emit(memory_id)

func get_dream_corruption() -> float:
	return clamp(float(player_deaths) / 100.0, 0.0, 1.0)

func reset_game() -> void:
	dream_lords_defeated = [false, false, false, false, false, false, false]
	for k in abilities_unlocked:
		abilities_unlocked[k] = false
	player_deaths = 0
	collected_memories.clear()
	game_time = 0.0
	game_reset.emit()
