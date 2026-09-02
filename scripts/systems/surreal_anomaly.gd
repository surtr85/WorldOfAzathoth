class_name SurrealAnomaly
extends Node2D
## Handles surreal dream-logic behaviors in environments.

enum AnomalyType {
	DISAPPEARING_DOOR,
	NON_EUCLIDEAN_ROOM,
	WEEPING_STATUE,
	EYED_MOON,
	TALKING_CORPSE,
	UPWARD_GRAVITY_ZONE,
	REPEATING_CORRIDOR,
	PAINTING_PORTAL
}

@export var anomaly_type: AnomalyType = AnomalyType.DISAPPEARING_DOOR
@export var trigger_area: Area2D
@export var target_node: Node2D
@export var dialogue_lines: Array[String] = []

var player_inside: bool = false
var has_triggered: bool = false
var original_transform: Transform2D

func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)
		trigger_area.body_exited.connect(_on_body_exited)
	if target_node:
		original_transform = target_node.global_transform

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_inside = true
		_activate_anomaly(body)

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_inside = false

func _activate_anomaly(player: PlayerController) -> void:
	match anomaly_type:
		AnomalyType.DISAPPEARING_DOOR:
			if target_node and not has_triggered:
				has_triggered = true
				var tween := create_tween()
				tween.tween_property(target_node, "modulate:a", 0.0, 1.0)
				tween.tween_callback(target_node.queue_free)
				
		AnomalyType.UPWARD_GRAVITY_ZONE:
			player.toggle_gravity()
			
		AnomalyType.WEEPING_STATUE:
			if target_node and sprite_out_of_view(player):
				target_node.global_position = target_node.global_position.move_toward(player.global_position, 50.0)
				
		AnomalyType.TALKING_CORPSE:
			if dialogue_lines.size() > 0 and HUD:
				var random_line := dialogue_lines[randi() % dialogue_lines.size()]
				# Call HUD dialogue system
				get_tree().call_group("hud", "show_dialogue", "Corpse of Forgotten Knight", random_line)

func sprite_out_of_view(player: PlayerController) -> bool:
	var dir_to_statue := (target_node.global_position.x - player.global_position.x)
	var player_facing := float(player.facing)
	# Returns true if player is looking AWAY from statue
	return (dir_to_statue * player_facing) < 0
