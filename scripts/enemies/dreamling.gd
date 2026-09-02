class_name Dreamling
extends EnemyBase
## Small humanoid creatures made from fragmented dreams.
## Basic melee enemy. Appears in most areas.
## Behavior: wanders aimlessly, charges at player when spotted.

func _on_ready() -> void:
	max_health = 20
	health = max_health
	contact_damage = 8
	move_speed = 80.0
	chase_speed = 160.0
	detection_range = 250.0
	attack_range = 50.0
	patrol_distance = 150.0
	is_innocent = true  # They are fragments of dreams, not truly evil
	dream_corruption_on_death = 0.01


func _perform_attack() -> void:
	# Simple lunge attack
	if player:
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * 300.0  # Lunge
	attack_timer = attack_cooldown
	await get_tree().create_timer(0.3).timeout
	if not is_dead:
		_change_state(EnemyState.CHASE)
