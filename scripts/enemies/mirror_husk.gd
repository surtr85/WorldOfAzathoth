class_name MirrorHusk
extends EnemyBase
## Copies the player's appearance and attacks with delayed movements.
## Records player inputs and replays them after a delay.

var recorded_inputs: Array[Dictionary] = []
var playback_index: int = 0
var record_timer: float = 0.0
var playback_delay: float = 1.5  # Seconds behind player
var max_recorded: int = 120  # ~2 seconds at 60fps


func _on_ready() -> void:
	max_health = 40
	health = max_health
	contact_damage = 12
	move_speed = 0.0  # Moves based on recorded inputs
	chase_speed = 0.0
	detection_range = 350.0
	attack_range = 80.0
	is_innocent = false
	dream_corruption_on_death = 0.03


func _state_chase(delta: float) -> void:
	if not player:
		_change_state(EnemyState.PATROL)
		return

	# Record player's movement
	record_timer += delta
	if record_timer >= 1.0 / 60.0:
		record_timer = 0.0
		recorded_inputs.append({
			"velocity": player.velocity,
			"position": player.global_position,
			"facing": player.facing if "facing" in player else 1,
		})
		if recorded_inputs.size() > max_recorded:
			recorded_inputs.pop_front()

	# Playback delayed inputs
	var delay_frames := int(playback_delay * 60)
	if recorded_inputs.size() > delay_frames:
		var replay: Dictionary = recorded_inputs[recorded_inputs.size() - delay_frames]
		var replay_vel: Vector2 = replay.get("velocity", Vector2.ZERO)
		velocity.x = replay_vel.x * 0.8  # Slightly slower
		facing = int(replay.get("facing", 1))

	if _distance_to_player() < attack_range and attack_timer <= 0:
		_change_state(EnemyState.ATTACK)


func _perform_attack() -> void:
	# Mirror the player's last attack direction
	if player:
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * 200.0
	attack_timer = 1.2
	await get_tree().create_timer(0.4).timeout
	if not is_dead:
		_change_state(EnemyState.CHASE)
