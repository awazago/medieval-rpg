extends EnemyBase
class_name EnemySkeleton

var is_attacking: bool = false
var walk_cycle: float = 0.0

func _ready() -> void:
	max_hp = 55
	current_hp = 55
	move_speed = 58.0
	damage = 14
	xp_reward = 40
	gold_reward = 4
	attack_cooldown = 1.3
	super._ready()

func custom_ai_process(delta: float) -> void:
	if not is_instance_valid(target_player) or is_attacking:
		return
		
	var to_player = target_player.global_position - global_position
	var dist = to_player.length()
	
	# Only aggro if player is within 220px
	if dist > 220.0:
		velocity = Vector2.ZERO
		return
		
	# Facing direction
	if to_player.x != 0.0:
		sprite.flip_h = to_player.x < 0.0
		
	# Melee attack range
	if dist < 26.0 and can_attack:
		perform_attack()
		return
		
	# Walk towards player
	var dir = to_player.normalized()
	velocity = dir * move_speed
	move_and_slide()
	
	# Subtle walking wobble
	walk_cycle += delta * 10.0
	sprite.rotation = sin(walk_cycle) * 0.1

func perform_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	
	# Wind-up
	var dir = (target_player.global_position - global_position).normalized()
	var t = create_tween()
	t.tween_property(sprite, "position", -dir * 6.0, 0.18)
	
	# Strike forward
	await t.finished
	if is_dead:
		return
		
	AudioManager.play_sfx("slash", 0.15, -2.0)
	var t_strike = create_tween()
	t_strike.tween_property(sprite, "position", dir * 10.0, 0.08)
	t_strike.tween_property(sprite, "position", Vector2.ZERO, 0.12)
	
	# Check if hit player
	if is_instance_valid(target_player):
		var cur_dist = global_position.distance_to(target_player.global_position)
		if cur_dist < 34.0:
			attack_target(target_player)
			
	await t_strike.finished
	is_attacking = false
