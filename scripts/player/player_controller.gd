class_name PlayerController
extends CharacterBody2D
## World of Azathoth - Main Player Controller
## Handles movement, jumping, dashing, wall mechanics, and state management.

# --- Signals ---
signal health_changed(new_health: int, max_health: int)
signal died
signal ability_used(ability_name: String)
signal weapon_changed(weapon_name: String)
signal dream_corruption_increased(amount: float)

# --- Enums ---
enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	DASH,
	ATTACK,
	PARRY,
	HURT,
	DEATH,
	WALL_SLIDE,
	WALL_JUMP,
	DREAM_DASH,
	SHADOW_STEP,
	GRAVITY_BREAK,
	NIGHTMARE_FORM,
}

enum Facing { LEFT = -1, RIGHT = 1 }

# --- Export Variables ---
@export_group("Movement")
@export var move_speed: float = 280.0
@export var acceleration: float = 2000.0
@export var friction: float = 1800.0
@export var air_friction: float = 600.0

@export_group("Jump")
@export var jump_force: float = -520.0
@export var double_jump_force: float = -440.0
@export var jump_cut_multiplier: float = 0.4
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.15
@export var max_fall_speed: float = 800.0
@export var gravity_multiplier: float = 1.0

@export_group("Dash")
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.5

@export_group("Wall")
@export var wall_slide_speed: float = 100.0
@export var wall_jump_force: Vector2 = Vector2(400, -480)

@export_group("Combat")
@export var max_health: int = 100
@export var invincibility_time: float = 1.0
@export var parry_window: float = 0.2
@export var attack_combo_window: float = 0.4

# --- State ---
var current_state: State = State.IDLE
var previous_state: State = State.IDLE
var facing: Facing = Facing.RIGHT
var health: int = max_health

# Jump
var can_double_jump: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var has_jumped: bool = false

# Dash
var can_dash: bool = true
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

# Wall
var is_on_wall_slide: bool = false

# Combat
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var combo_counter: int = 0
var combo_timer: float = 0.0
var is_parrying: bool = false
var parry_timer: float = 0.0

# Abilities
var has_dream_dash: bool = false
var has_shadow_step: bool = false
var has_gravity_break: bool = false
var has_dream_hook: bool = false
var has_memory_dive: bool = false
var has_time_fracture: bool = false
var has_nightmare_form: bool = false
var gravity_inverted: bool = false

# --- Node References ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var parry_area: Area2D = $ParryArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var ground_raycast: RayCast2D = $GroundRaycast
@onready var wall_raycast_right: RayCast2D = $WallRaycastRight
@onready var wall_raycast_left: RayCast2D = $WallRaycastLeft
@onready var state_machine_timer: Timer = $StateMachineTimer
@onready var camera: Camera2D = $Camera2D

# --- Gravity ---
var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	health = max_health
	_sync_abilities_from_game_manager()
	health_changed.emit(health, max_health)


func _sync_abilities_from_game_manager() -> void:
	if GameManager:
		has_dream_dash = GameManager.is_ability_unlocked("dream_dash")
		has_shadow_step = GameManager.is_ability_unlocked("shadow_step")
		has_gravity_break = GameManager.is_ability_unlocked("gravity_break")
		has_dream_hook = GameManager.is_ability_unlocked("dream_hook")
		has_memory_dive = GameManager.is_ability_unlocked("memory_dive")
		has_time_fracture = GameManager.is_ability_unlocked("time_fracture")
		has_nightmare_form = GameManager.is_ability_unlocked("nightmare_form")


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_handle_state(delta)
	move_and_slide()
	_update_animations()


# === TIMER MANAGEMENT ===

func _update_timers(delta: float) -> void:
	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
		can_double_jump = true
		has_jumped = false
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	# Jump buffer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true

	# Dash timer
	if dash_timer > 0:
		dash_timer -= delta

	# Invincibility
	if invincibility_timer > 0:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			modulate.a = 1.0

	# Combo
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_counter = 0

	# Parry
	if parry_timer > 0:
		parry_timer -= delta
		if parry_timer <= 0:
			is_parrying = false


# === STATE MACHINE ===

func _handle_state(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.RUN:
			_state_run(delta)
		State.JUMP:
			_state_jump(delta)
		State.FALL:
			_state_fall(delta)
		State.DASH:
			_state_dash(delta)
		State.ATTACK:
			_state_attack(delta)
		State.PARRY:
			_state_parry(delta)
		State.HURT:
			_state_hurt(delta)
		State.DEATH:
			_state_death(delta)
		State.WALL_SLIDE:
			_state_wall_slide(delta)
		State.WALL_JUMP:
			_state_wall_jump(delta)


func _change_state(new_state: State) -> void:
	previous_state = current_state
	current_state = new_state


# === INDIVIDUAL STATES ===

func _state_idle(delta: float) -> void:
	_apply_gravity(delta)
	_apply_friction(delta)
	_check_jump()
	_check_dash()
	_check_attack()
	_check_parry()

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		_change_state(State.RUN)
	if not is_on_floor():
		_change_state(State.FALL)


func _state_run(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement(delta)
	_check_jump()
	_check_dash()
	_check_attack()
	_check_parry()

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		_change_state(State.IDLE)
	if not is_on_floor():
		_change_state(State.FALL)


func _state_jump(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement(delta)
	_check_dash()
	_check_attack()
	_check_wall_slide()

	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# Double jump
	if Input.is_action_just_pressed("jump") and can_double_jump and has_jumped:
		velocity.y = double_jump_force
		can_double_jump = false

	if velocity.y > 0:
		_change_state(State.FALL)
	if is_on_floor():
		_change_state(State.IDLE)


func _state_fall(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement(delta)
	_check_jump()  # Buffer + coyote
	_check_dash()
	_check_attack()
	_check_wall_slide()

	if is_on_floor():
		if jump_buffer_timer > 0:
			_perform_jump()
		else:
			_change_state(State.IDLE)


func _state_dash(delta: float) -> void:
	if dash_timer <= 0:
		_change_state(State.FALL if not is_on_floor() else State.IDLE)
		return

	velocity = dash_direction * dash_speed
	# Dream dash: pass through enemies and thin walls
	if has_dream_dash:
		# Handled by collision layer toggling
		pass


func _state_attack(delta: float) -> void:
	_apply_gravity(delta)
	# Attack state is managed by animation; on animation finish, return to idle/fall


func _state_parry(delta: float) -> void:
	_apply_gravity(delta)
	_apply_friction(delta)
	if parry_timer <= 0:
		_change_state(State.IDLE if is_on_floor() else State.FALL)


func _state_hurt(delta: float) -> void:
	_apply_gravity(delta)
	# Knockback handled on entry; wait for timer


func _state_death(_delta: float) -> void:
	velocity = Vector2.ZERO
	# Death animation plays; game manager handles respawn


func _state_wall_slide(delta: float) -> void:
	velocity.y = min(velocity.y + base_gravity * delta * 0.5, wall_slide_speed)

	_check_jump()  # Wall jump
	_check_dash()

	var input_dir := Input.get_axis("move_left", "move_right")
	var on_wall := _is_touching_wall()

	if is_on_floor() or not on_wall:
		_change_state(State.IDLE if is_on_floor() else State.FALL)

	# Wall jump
	if Input.is_action_just_pressed("jump"):
		var wall_dir := -1 if wall_raycast_right.is_colliding() else 1
		velocity = Vector2(wall_jump_force.x * wall_dir, wall_jump_force.y)
		facing = Facing.LEFT if wall_dir < 0 else Facing.RIGHT
		_change_state(State.WALL_JUMP)


func _state_wall_jump(delta: float) -> void:
	_apply_gravity(delta)
	# Brief lock on horizontal input after wall jump
	_apply_movement(delta)

	if velocity.y > 0:
		_change_state(State.FALL)
	if is_on_floor():
		_change_state(State.IDLE)


# === MOVEMENT HELPERS ===

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var grav_dir := -1.0 if gravity_inverted else 1.0
		velocity.y += base_gravity * gravity_multiplier * grav_dir * delta
		velocity.y = clamp(velocity.y,
			-max_fall_speed if gravity_inverted else -999999,
			max_fall_speed if not gravity_inverted else 999999)


func _apply_movement(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * move_speed, acceleration * delta)
		facing = Facing.LEFT if input_dir < 0 else Facing.RIGHT
	else:
		var fric := friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0, fric * delta)


func _apply_friction(delta: float) -> void:
	var fric := friction if is_on_floor() else air_friction
	velocity.x = move_toward(velocity.x, 0, fric * delta)


# === ACTION CHECKS ===

func _check_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

		if is_on_floor() or coyote_timer > 0:
			_perform_jump()
		elif can_double_jump and has_jumped:
			velocity.y = double_jump_force
			can_double_jump = false
			_change_state(State.JUMP)


func _perform_jump() -> void:
	velocity.y = jump_force
	coyote_timer = 0
	jump_buffer_timer = 0
	has_jumped = true
	_change_state(State.JUMP)


func _check_dash() -> void:
	if Input.is_action_just_pressed("dash") and can_dash:
		_perform_dash()


func _perform_dash() -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		dash_direction = Vector2(facing, 0)
	else:
		dash_direction = Vector2(input_dir, 0).normalized()

	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	_change_state(State.DASH)
	ability_used.emit("dash")

	# Dream Dash: temporarily disable enemy collision
	if has_dream_dash:
		set_collision_mask_value(2, false)  # Enemy layer
		await get_tree().create_timer(dash_duration).timeout
		set_collision_mask_value(2, true)


func _check_attack() -> void:
	if Input.is_action_just_pressed("attack"):
		_perform_attack()


func _perform_attack() -> void:
	combo_counter = (combo_counter + 1) % 3
	combo_timer = attack_combo_window
	_change_state(State.ATTACK)
	# Attack hitbox activation handled by animation


func _check_parry() -> void:
	if Input.is_action_just_pressed("parry"):
		is_parrying = true
		parry_timer = parry_window
		_change_state(State.PARRY)


func _check_wall_slide() -> void:
	if _is_touching_wall() and not is_on_floor() and velocity.y > 0:
		var input_dir := Input.get_axis("move_left", "move_right")
		var wall_on_right := wall_raycast_right.is_colliding()
		var wall_on_left := wall_raycast_left.is_colliding()

		if (wall_on_right and input_dir > 0) or (wall_on_left and input_dir < 0):
			_change_state(State.WALL_SLIDE)


func _is_touching_wall() -> bool:
	return wall_raycast_right.is_colliding() or wall_raycast_left.is_colliding()


# === COMBAT ===

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invincible or current_state == State.DEATH:
		return

	if is_parrying:
		_on_successful_parry()
		return

	health -= amount
	health_changed.emit(health, max_health)

	if health <= 0:
		_die()
	else:
		_change_state(State.HURT)
		is_invincible = true
		invincibility_timer = invincibility_time
		velocity = knockback_dir * 300
		# Flash effect
		_flash_hurt()


func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)


func _on_successful_parry() -> void:
	# Slow motion effect on parry
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.1 * Engine.time_scale).timeout
	Engine.time_scale = 1.0
	# TODO: Parry riposte window


func _die() -> void:
	_change_state(State.DEATH)
	died.emit()
	if GameManager:
		GameManager.player_deaths += 1
	if DreamState:
		DreamState.destabilize(0.05)
	dream_corruption_increased.emit(0.05)


func _flash_hurt() -> void:
	var tween := create_tween()
	for i in range(5):
		tween.tween_property(self, "modulate:a", 0.3, 0.1)
		tween.tween_property(self, "modulate:a", 1.0, 0.1)


# === ANIMATION ===

func _update_animations() -> void:
	if sprite == null:
		return

	sprite.flip_h = (facing == Facing.LEFT)

	match current_state:
		State.IDLE:
			sprite.play("idle")
		State.RUN:
			sprite.play("run")
		State.JUMP:
			sprite.play("jump")
		State.FALL:
			sprite.play("fall")
		State.DASH:
			sprite.play("dash")
		State.ATTACK:
			sprite.play("attack_%d" % combo_counter)
		State.PARRY:
			sprite.play("parry")
		State.HURT:
			sprite.play("hurt")
		State.DEATH:
			sprite.play("death")
		State.WALL_SLIDE:
			sprite.play("wall_slide")
		State.WALL_JUMP:
			sprite.play("jump")


# === ABILITY: GRAVITY BREAK ===

func toggle_gravity() -> void:
	if not has_gravity_break:
		return
	gravity_inverted = not gravity_inverted
	scale.y *= -1
	ability_used.emit("gravity_break")


# === ABILITY: SHADOW STEP ===

func shadow_step() -> void:
	if not has_shadow_step:
		return
	# Teleport to nearest shadow in facing direction
	# Implementation depends on shadow detection system
	ability_used.emit("shadow_step")


# === ATTACK AREA CALLBACKS ===

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var damage := _get_current_weapon_damage()
		var kb_dir := Vector2(facing, -0.5).normalized()
		body.take_damage(damage, kb_dir)


func _get_current_weapon_damage() -> int:
	# Base damage per weapon type
	match GameManager.current_weapon if GameManager else "mercenary_sword":
		"mercenary_sword": return 15
		"twin_daggers": return 8  # Faster but less damage
		"greatsword": return 30  # Slower but more damage
		"dream_pistol": return 12
		"scythe": return 20
		"chain_weapon": return 18
		"magical_firearm": return 14
		"nightmare_blade": return 25
		_: return 15


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		var damage: int = area.get_meta("damage", 10)
		var kb_dir: Vector2 = (global_position - area.global_position).normalized()
		take_damage(damage, kb_dir)
