extends EnemyBase
class_name BossNecromancer

signal boss_engaged(boss_name: String, max_hp: int)
signal boss_hp_changed(current_hp: int)
signal boss_defeated

const PROJECTILE_SCENE = preload("res://src/scenes/dark_projectile.tscn")

var is_engaged: bool = false
var shoot_timer: float = 0.0
var teleport_cooldown: float = 0.0
var hover_angle: float = 0.0
var is_phase2: bool = false

func _ready() -> void:
	max_hp = 320
	current_hp = 320
	move_speed = 45.0
	damage = 18
	xp_reward = 250
	gold_reward = 50
	attack_cooldown = 1.8
	super._ready()

func custom_ai_process(delta: float) -> void:
	if not is_instance_valid(target_player) or is_dead:
		return
		
	var to_player = target_player.global_position - global_position
	var dist = to_player.length()
	
	# Trigger boss engagement when player enters chamber (< 280px)
	if not is_engaged and dist < 280.0:
		engage_boss()
		
	if not is_engaged:
		return
		
	# Facing direction
	if to_player.x != 0.0:
		sprite.flip_h = to_player.x < 0.0
		
	# Phase 2 check (< 50% HP)
	if not is_phase2 and current_hp <= (max_hp / 2):
		enter_phase_2()
		
	# Hover float motion
	hover_angle += delta * 3.0
	sprite.position.y = sin(hover_angle) * 3.5
	
	# Teleport if player gets too close
	teleport_cooldown -= delta
	if dist < 55.0 and teleport_cooldown <= 0.0:
		teleport_away()
		return
		
	# Keep distance: drift around player
	var desired_dist = 140.0
	var move_dir = Vector2.ZERO
	if dist < desired_dist - 20.0:
		move_dir = -to_player.normalized()
	elif dist > desired_dist + 40.0:
		move_dir = to_player.normalized()
	else:
		# Circle player
		move_dir = Vector2(-to_player.y, to_player.x).normalized()
		
	velocity = move_dir * move_speed
	move_and_slide()
	
	# Attack cycle
	shoot_timer += delta
	var current_shoot_rate = 1.4 if is_phase2 else 2.1
	if shoot_timer >= current_shoot_rate:
		shoot_timer = 0.0
		cast_dark_magic(to_player.normalized())

func engage_boss() -> void:
	is_engaged = true
	AudioManager.play_sfx("boss_roar", 0.0, 3.0)
	boss_engaged.emit("Malakor, the Necromancer", max_hp)
	
	# Notify HUD directly if connected or in group
	get_tree().call_group("hud", "show_boss_bar", "MALAKOR THE UNDYING", max_hp, current_hp)

func enter_phase_2() -> void:
	is_phase2 = true
	move_speed = 70.0
	AudioManager.play_sfx("boss_roar", 0.1, 2.0)
	spawn_damage_text(0, Color(1.0, 0.2, 0.2)) # Enrage alert
	
	# Red tint
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(1.4, 0.6, 0.6), 0.3)

func cast_dark_magic(dir: Vector2) -> void:
	AudioManager.play_sfx("spell_cast", 0.15)
	
	if is_phase2:
		# Triple spread
		for angle_offset in [-0.26, 0.0, 0.26]:
			var rotated_dir = dir.rotated(angle_offset)
			spawn_projectile(rotated_dir, 160.0)
	else:
		# Single targeted orb
		spawn_projectile(dir, 140.0)

func spawn_projectile(dir: Vector2, speed: float) -> void:
	var proj = PROJECTILE_SCENE.instantiate()
	proj.setup(dir, damage, speed)
	proj.global_position = global_position
	get_parent().add_child(proj)

func teleport_away() -> void:
	teleport_cooldown = 4.5
	AudioManager.play_sfx("spell_cast", 0.2)
	
	# Smoke burst effect via tween
	var t = create_tween()
	t.tween_property(sprite, "scale", Vector2(0.1, 1.8), 0.08)
	t.tween_property(sprite, "modulate:a", 0.0, 0.05)
	
	await t.finished
	if is_dead or not is_instance_valid(target_player):
		return
		
	# New position away from player
	var angle = randf() * TAU
	var new_pos = target_player.global_position + Vector2(cos(angle), sin(angle)) * 140.0
	global_position = new_pos
	
	var t_in = create_tween()
	t_in.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	t_in.tween_property(sprite, "modulate:a", 1.0, 0.05)

func take_damage(amount: int, p_knockback: Vector2 = Vector2.ZERO) -> void:
	# Less knockback on boss
	super.take_damage(amount, p_knockback * 0.25)
	boss_hp_changed.emit(current_hp)
	get_tree().call_group("hud", "update_boss_hp", current_hp)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	AudioManager.play_sfx("boss_roar", 0.0, 4.0)
	boss_defeated.emit()
	get_tree().call_group("hud", "on_boss_defeated")
	
	# Massive loot explosion
	for i in range(15):
		var coin = LOOT_SCENE.instantiate()
		coin.setup(0, randi_range(3, 8))
		loot_offset(coin, Vector2(randf_range(-40, 40), randf_range(-40, 40)))
		
	for i in range(3):
		var pot = LOOT_SCENE.instantiate()
		pot.setup(1, 50)
		loot_offset(pot, Vector2(randf_range(-30, 30), randf_range(-30, 30)))
		
	for i in range(3):
		var xp = LOOT_SCENE.instantiate()
		xp.setup(2, 80)
		loot_offset(xp, Vector2(randf_range(-30, 30), randf_range(-30, 30)))
		
	# Epic fade & shake
	var t = create_tween()
	t.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.3)
	t.tween_property(sprite, "modulate", Color(3.0, 3.0, 3.0, 0.0), 0.4)
	t.tween_callback(queue_free)
