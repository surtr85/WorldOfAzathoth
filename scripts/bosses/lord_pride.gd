class_name LordPride
extends DreamLordBase
## Dream Lord I — PRIDE: The Golden King
## Copies player abilities. Fights back using player's playstyle.

func _ready() -> void:
	lord_name = "The Golden King"
	sin_type = "pride"
	max_health = 600

func _physics_process(delta: float) -> void:
	if not is_active or not player:
		return
	# Adaptive mirroring logic
	var p_vel: Vector2 = player.get("velocity") if "velocity" in player else Vector2.ZERO
	velocity.x = move_toward(velocity.x, p_vel.x * 0.9, 1500 * delta)
	move_and_slide()
