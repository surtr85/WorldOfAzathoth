class_name DreamLordBase
extends CharacterBody2D
## Base class for the 7 Dream Lords in World of Azathoth.

signal phase_changed(new_phase: int)
signal lord_defeated(lord_name: String)

@export var lord_name: String = "Unknown Dream Lord"
@export var sin_type: String = "Pride"
@export var max_health: int = 500
@export var phases: int = 2

var current_health: int
var current_phase: int = 1
var is_active: bool = false
var player: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

func _ready() -> void:
	current_health = max_health

func activate(p_player: Node2D) -> void:
	player = p_player
	is_active = true

func take_damage(amount: int, _knockback: Vector2 = Vector2.ZERO) -> void:
	if not is_active:
		return
	current_health -= amount
	if current_health <= max_health / 2 and current_phase == 1 and phases > 1:
		_transition_phase(2)
	elif current_health <= 0:
		_on_death()

func _transition_phase(new_phase: int) -> void:
	current_phase = new_phase
	phase_changed.emit(new_phase)

func _on_death() -> void:
	is_active = false
	lord_defeated.emit(lord_name)
	if GameManager:
		var idx := _get_sin_index()
		GameManager.defeat_dream_lord(idx)

func _get_sin_index() -> int:
	match sin_type.to_lower():
		"pride": return 0
		"greed": return 1
		"lust": return 2
		"envy": return 3
		"gluttony": return 4
		"wrath": return 5
		"sloth": return 6
		_: return 0
