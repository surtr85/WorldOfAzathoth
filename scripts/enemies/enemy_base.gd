class_name EnemyBase
extends CharacterBody2D
## Base class for all enemies in World of Azathoth.
## Provides health, damage, knockback, death, and dream corruption hooks.

# --- Signals ---
signal health_changed(current: int, maximum: int)
signal died
signal stunned

# --- Enums ---
enum EnemyState {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	HURT,
	STUNNED,
	DEATH,
}

# --- Exports ---
@export_group("Stats")
@export var max_health: int = 30
@export var contact_damage: int = 10
@export var move_speed: float = 120.0
@export var chase_speed: float = 180.0
@export var gravity_multiplier: float = 1.0

@export_group("Detection")
@export var detection_range: float = 300.0
@export var attack_range: float = 60.0
@export var lose_sight_range: float = 400.0

@export_group("Combat")
@export var knockback_force: float = 250.0
@export var stun_duration: float = 0.3
@export var attack_cooldown: float = 1.0

@export_group("Patrol")
@export var patrol_distance: float = 200.0
@export var patrol_wait_time: float = 2.0

@export_group("Dream")
@export var is_dream_creature: bool = true
@export var is_innocent: bool = false  # For secret ending tracking
@export var dream_corruption_on_death: float = 0.02

# --- State ---
var current_state: EnemyState = EnemyState.IDLE
var health: int
var facing: int = 1  # 1 = right, -1 = left
var player: CharacterBody2D = null
var patrol_origin: Vector2
var patrol_target: Vector2
var patrol_timer: float = 0.0
var attack_timer: float = 0.0
var stun_timer: float = 0.0
var is_dead: bool = false

# --- Gravity ---
var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Node References ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	health = max_health
	patrol_origin = global_position
	patrol_target = patrol_origin + Vector2(patrol_distance, 0)
	_setup_detection_area()
	_on_ready()


## Override in subclasses for custom initialization
func _on_ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_apply_gravity(delta)
	_update_timers(delta)
	_handle_state(delta)
	move_and_slide()
	_update_animations()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += base_gravity * gravity_multiplier * delta


func _update_timers(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta
	if stun_timer > 0:
		stun_timer -= delta
		if stun_timer <= 0 and current_state == EnemyState.STUNNED:
			_change_state(EnemyState.IDLE)
	if patrol_timer > 0:
		patrol_timer -= delta


# === STATE MACHINE ===

func _handle_state(delta: float) -> void:
	match current_state:
		EnemyState.IDLE:
			_state_idle(delta)
		EnemyState.PATROL:
			_state_patrol(delta)
		EnemyState.CHASE:
			_state_chase(delta)
		EnemyState.ATTACK:
			_state_attack(delta)
		EnemyState.HURT:
			_state_hurt(delta)
		EnemyState.STUNNED:
			_state_stunned(delta)
		EnemyState.DEATH:
			pass


func _change_state(new_state: EnemyState) -> void:
	current_state = new_state


func _state_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	if patrol_timer <= 0:
		_change_state(EnemyState.PATROL)
	if player and _distance_to_player() < detection_range:
		_change_state(EnemyState.CHASE)


func _state_patrol(delta: float) -> void:
	var dir_to_target := sign(patrol_target.x - global_position.x)
	facing = dir_to_target
	velocity.x = dir_to_target * move_speed

	if abs(global_position.x - patrol_target.x) < 10:
		# Swap patrol targets
		var temp := patrol_target
		patrol_target = patrol_origin
		patrol_origin = temp
		patrol_timer = patrol_wait_time
		_change_state(EnemyState.IDLE)

	if player and _distance_to_player() < detection_range:
		_change_state(EnemyState.CHASE)


func _state_chase(delta: float) -> void:
	if not player:
		_change_state(EnemyState.PATROL)
		return

	var dir := sign(player.global_position.x - global_position.x)
	facing = dir
	velocity.x = dir * chase_speed

	if _distance_to_player() < attack_range and attack_timer <= 0:
		_change_state(EnemyState.ATTACK)
	elif _distance_to_player() > lose_sight_range:
		_change_state(EnemyState.PATROL)


func _state_attack(_delta: float) -> void:
	velocity.x = 0
	# Override in subclass for specific attack behavior
	_perform_attack()


func _state_hurt(_delta: float) -> void:
	# Brief knockback state
	velocity.x = move_toward(velocity.x, 0, 800 * _delta)


func _state_stunned(_delta: float) -> void:
	velocity.x = 0


# === COMBAT ===

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return

	health -= amount
	health_changed.emit(health, max_health)

	if health <= 0:
		die()
	else:
		_change_state(EnemyState.HURT)
		velocity = knockback_dir * knockback_force
		_flash_hurt()
		# Brief stun
		stun_timer = stun_duration
		await get_tree().create_timer(0.2).timeout
		if not is_dead:
			_change_state(EnemyState.STUNNED)


func die() -> void:
	is_dead = true
	_change_state(EnemyState.DEATH)
	died.emit()

	# Track innocent kills for secret ending
	if is_innocent and GameManager:
		GameManager.add_memory("killed_innocent_%s" % name)

	# Dream corruption
	if DreamState:
		DreamState.destabilize(dream_corruption_on_death)

	# Death effect
	_play_death_effect()

	# Disable collision
	collision_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.set_deferred("monitoring", false)

	# Fade out and free
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


## Override for custom attack behavior
func _perform_attack() -> void:
	attack_timer = attack_cooldown
	_change_state(EnemyState.IDLE)


## Override for custom death effects (particles, drops, etc.)
func _play_death_effect() -> void:
	pass


func _flash_hurt() -> void:
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE


# === DETECTION ===

func _setup_detection_area() -> void:
	if detection_area:
		# Connect signals if not already connected
		if not detection_area.body_entered.is_connected(_on_detection_body_entered):
			detection_area.body_entered.connect(_on_detection_body_entered)
		if not detection_area.body_exited.is_connected(_on_detection_body_exited):
			detection_area.body_exited.connect(_on_detection_body_exited)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player = body


func _on_detection_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player = null


func _distance_to_player() -> float:
	if not player:
		return INF
	return global_position.distance_to(player.global_position)


# === ANIMATION ===

func _update_animations() -> void:
	if sprite == null:
		return

	sprite.flip_h = (facing == -1)

	match current_state:
		EnemyState.IDLE:
			sprite.play("idle")
		EnemyState.PATROL:
			sprite.play("walk")
		EnemyState.CHASE:
			sprite.play("run")
		EnemyState.ATTACK:
			sprite.play("attack")
		EnemyState.HURT:
			sprite.play("hurt")
		EnemyState.DEATH:
			sprite.play("death")


# === HITBOX ===

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		var kb_dir := (body.global_position - global_position).normalized()
		body.take_damage(contact_damage, kb_dir)
