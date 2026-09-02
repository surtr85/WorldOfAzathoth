class_name Door
extends Area2D
## Door connecting rooms in World of Azathoth Metroidvania.

@export var target_scene: String = ""
@export var target_door_id: String = ""
@export var door_id: String = ""
@export var is_locked: bool = false
@export var required_key: String = ""
@export var requires_ability: String = ""

signal door_entered(target_scene: String, target_door_id: String)

var player_near: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		player_near = true
		if not is_locked or _can_unlock():
			_use_door()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		player_near = false

func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		if is_locked:
			if _can_unlock():
				is_locked = false
				_use_door()
			else:
				print("Door is locked! Need key: ", required_key)
		else:
			_use_door()

func _can_unlock() -> bool:
	if required_key != "" and GameManager:
		if GameManager.inventory.has(required_key):
			return true
	if requires_ability != "" and GameManager:
		if GameManager.is_ability_unlocked(requires_ability):
			return true
	return not is_locked

func _use_door() -> void:
	if target_scene != "":
		door_entered.emit(target_scene, target_door_id)
		if GameManager:
			GameManager.change_scene(target_scene, target_door_id)
