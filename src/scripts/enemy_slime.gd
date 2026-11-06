extends EnemyBase
class_name EnemySlime

var hop_timer: float = 0.0
var hop_cooldown: float = 1.1
var is_hopping: bool = false
var hop_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	max_hp = 30
	current_hp = 30
	move_speed = 110.0
	damage = 8
	xp_reward = 20
	gold_reward = 2
	super._ready()

func custom_ai_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	
	hop_timer += delta
	if not is_hopping:
		# Idle squash breathing
		sprite.scale = Vector2(1.0 + 0.1 * sin(hop_timer * 6.0), 1.0 - 0.1 * sin(hop_timer * 6.0))
		velocity = Vector2.ZERO
		
		# Only hop if within detection range (220px)
		if dist < 220.0 and hop_timer >= hop_cooldown:
			start_hop()
	else:
		# During hop
		velocity = hop_dir * move_speed
		move_and_slide()
		
		# Check contact damage
		if dist < 22.0:
			attack_target(target_player)
			
		if hop_timer >= 0.45:
			# Land
			is_hopping = false
			hop_timer = 0.0
			sprite.scale = Vector2(1.3, 0.7) # Land squash
			var t = create_tween()
			t.tween_property(sprite, "scale", Vector2.ONE, 0.15)

func start_hop() -> void:
	is_hopping = true
	hop_timer = 0.0
	hop_dir = (target_player.global_position - global_position).normalized()
	
	# Jump stretch
	sprite.scale = Vector2(0.7, 1.35)
