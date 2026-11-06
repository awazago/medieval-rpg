extends CharacterBody2D
class_name Player

signal stats_changed(hp: int, max_hp: int, stamina: float, max_stamina: float, gold: int, level: int, xp: int, xp_needed: int)
signal player_died

# Movement Stats
@export var move_speed: float = 125.0
@export var acceleration: float = 900.0
@export var friction: float = 1000.0

# Dash Stats
@export var dash_speed: float = 300.0
@export var dash_duration: float = 0.22
@export var dash_cost: float = 25.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_dir: Vector2 = Vector2.DOWN
var is_invulnerable: bool = false

# Combat Stats
@export var max_hp: int = 100
var hp: int = 100
@export var max_stamina: float = 100.0
var stamina: float = 100.0
@export var stamina_regen: float = 32.0
@export var attack_damage: int = 25
@export var attack_cooldown: float = 0.26
var attack_timer: float = 0.0
var is_attacking: bool = false

# Progression
var gold: int = 0
var level: int = 1
var xp: int = 0
var xp_needed: int = 100

# Facing & Aim
var facing_dir: Vector2 = Vector2.DOWN

# Screen Shake
var shake_trauma: float = 0.0
var shake_max_offset: float = 8.0

# Preloads
const SLASH_SCENE = preload("res://src/scenes/slash_effect.tscn")
const FLOATING_TEXT_SCENE = preload("res://src/scenes/floating_text.tscn")
const HERO_SPRITE = preload("res://assets/sprites/hero.png")
const HERO_ATTACK_SPRITE = preload("res://assets/sprites/hero_attack.png")

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	stamina = max_stamina
	emit_stats()

func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
		
	handle_stamina(delta)
	handle_screen_shake(delta)
	
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			sprite.texture = HERO_SPRITE
			
	if is_dashing:
		process_dash(delta)
	else:
		process_movement(delta)
		handle_combat_input()

func process_movement(delta: float) -> void:
	var input_vec = Vector2.ZERO
	
	# WASD / Arrow keys direct input check
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_vec.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_vec.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_vec.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_vec.y += 1.0
		
	# Normalized vector
	if input_vec.length() > 0.0:
		input_vec = input_vec.normalized()
		facing_dir = input_vec
		velocity = velocity.move_toward(input_vec * move_speed, acceleration * delta)
		
		# Sprite tilt walking animation
		sprite.rotation = sin(Time.get_ticks_msec() * 0.012) * 0.08
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		sprite.rotation = 0.0
		
	# Facing flip
	if input_vec.x != 0.0:
		sprite.flip_h = input_vec.x < 0.0
		
	move_and_slide()
	
	# Dash trigger (Spacebar or Shift)
	if (Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_SHIFT)) and stamina >= dash_cost and input_vec.length() > 0.1:
		start_dash(input_vec)

func start_dash(dir: Vector2) -> void:
	is_dashing = true
	dash_timer = 0.0
	dash_dir = dir.normalized()
	is_invulnerable = true
	stamina -= dash_cost
	emit_stats()
	
	AudioManager.play_sfx("dash", 0.15)
	
	# Dash trail stretch
	sprite.modulate.a = 0.55
	sprite.scale = Vector2(1.2, 0.8)

func process_dash(delta: float) -> void:
	dash_timer += delta
	velocity = dash_dir * dash_speed
	move_and_slide()
	
	if dash_timer >= dash_duration:
		is_dashing = false
		is_invulnerable = false
		sprite.modulate.a = 1.0
		sprite.scale = Vector2.ONE

func handle_combat_input() -> void:
	# Attack on Left Mouse Button or J or K
	var wants_attack = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_physical_key_pressed(KEY_J) or Input.is_physical_key_pressed(KEY_K)
	if wants_attack and attack_timer <= 0.0:
		perform_attack()

func perform_attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	
	# Aim towards mouse or facing direction
	var mouse_pos = get_global_mouse_position()
	var attack_dir = (mouse_pos - global_position).normalized()
	if mouse_pos.distance_to(global_position) < 8.0:
		attack_dir = facing_dir
		
	# Facing flip
	sprite.flip_h = attack_dir.x < 0.0
	sprite.texture = HERO_ATTACK_SPRITE
	
	# Spawn Slash Arc
	var slash = SLASH_SCENE.instantiate()
	slash.setup(attack_dir, attack_damage)
	slash.global_position = global_position + attack_dir * 14.0
	get_parent().add_child(slash)
	
	# Slight forward lunge
	velocity += attack_dir * 80.0
	AudioManager.play_sfx("slash", 0.15)
	add_screen_shake(0.2)

func handle_stamina(delta: float) -> void:
	if not is_dashing and stamina < max_stamina:
		stamina = min(max_stamina, stamina + stamina_regen * delta)
		emit_stats()

func take_damage(amount: int, knockback_force: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or hp <= 0:
		return
		
	hp = max(0, hp - amount)
	emit_stats()
	
	AudioManager.play_sfx("hit_player", 0.1)
	add_screen_shake(0.65)
	
	# Floating damage number in red
	spawn_damage_text(amount, Color(1.0, 0.25, 0.25))
	
	# Flash red & brief invulnerability
	is_invulnerable = true
	sprite.modulate = Color(3.0, 0.3, 0.3)
	velocity += knockback_force
	
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	await t.finished
	is_invulnerable = false
	
	if hp <= 0:
		die()

func heal(amount: int) -> void:
	var old_hp = hp
	hp = min(max_hp, hp + amount)
	var gained = hp - old_hp
	if gained > 0:
		spawn_damage_text(gained, Color(0.2, 1.0, 0.4), "+")
	emit_stats()

func add_gold(amount: int) -> void:
	gold += amount
	spawn_damage_text(amount, Color(1.0, 0.85, 0.2), "+")
	emit_stats()

func add_xp(amount: int) -> void:
	xp += amount
	if xp >= xp_needed:
		level_up()
	emit_stats()

func level_up() -> void:
	level += 1
	xp -= xp_needed
	xp_needed = int(xp_needed * 1.5)
	max_hp += 20
	hp = max_hp
	attack_damage += 6
	
	AudioManager.play_sfx("level_up", 0.0, 2.0)
	add_screen_shake(0.5)
	
	# Floating Level Up notification
	var ft = FLOATING_TEXT_SCENE.instantiate()
	ft.global_position = global_position + Vector2(0, -28)
	get_parent().add_child(ft)
	ft.setup("LEVEL UP!", Color(1.0, 0.9, 0.2), 1.3)
	
	emit_stats()

func spawn_damage_text(val: int, col: Color, prefix: String = "") -> void:
	var ft = FLOATING_TEXT_SCENE.instantiate()
	ft.global_position = global_position + Vector2(randf_range(-8, 8), -20)
	get_parent().add_child(ft)
	ft.setup(prefix + str(val), col)

func die() -> void:
	AudioManager.play_sfx("hit_player", 0.0, 3.0)
	player_died.emit()
	get_tree().call_group("hud", "show_game_over")
	
	# Death collapse
	var t = create_tween()
	t.tween_property(sprite, "rotation", 1.57, 0.25)
	t.tween_property(sprite, "modulate", Color(0.5, 0.1, 0.1, 0.7), 0.3)

func add_screen_shake(amount: float) -> void:
	shake_trauma = clamp(shake_trauma + amount, 0.0, 1.0)

func handle_screen_shake(delta: float) -> void:
	if shake_trauma > 0.0:
		shake_trauma = max(0.0, shake_trauma - delta * 1.8)
		var shake = shake_trauma * shake_trauma
		camera.offset = Vector2(
			randf_range(-1.0, 1.0) * shake_max_offset * shake,
			randf_range(-1.0, 1.0) * shake_max_offset * shake
		)
	else:
		camera.offset = Vector2.ZERO

func emit_stats() -> void:
	stats_changed.emit(hp, max_hp, stamina, max_stamina, gold, level, xp, xp_needed)
	get_tree().call_group("hud", "update_stats", hp, max_hp, stamina, max_stamina, gold, level, xp, xp_needed)
