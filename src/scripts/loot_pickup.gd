extends Area2D
class_name LootPickup

enum LootType { COIN, POTION_HP, XP_ORB }

@export var type: LootType = LootType.COIN
@export var value: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var player_ref: Node2D = null
var magnet_speed: float = 0.0
var bob_offset: float = 0.0
var original_y: float = 0.0

const MAGNET_RADIUS: float = 65.0
const PICKUP_RADIUS: float = 16.0

func _ready() -> void:
	add_to_group("loot")
	original_y = position.y
	bob_offset = randf() * TAU
	setup_visuals()

func setup(p_type: int, p_value: int) -> void:
	type = p_type as LootType
	value = p_value
	if is_node_ready():
		setup_visuals()

func setup_visuals() -> void:
	sprite.region_enabled = true
	match type:
		LootType.COIN:
			# Coin is at x=0, y=32, w=16, h=16 in props_spritesheet.png
			sprite.region_rect = Rect2(0, 32, 16, 16)
		LootType.POTION_HP:
			# Health potion is at x=16, y=32, w=16, h=16
			sprite.region_rect = Rect2(16, 32, 16, 16)
		LootType.XP_ORB:
			# Magic potion is at x=32, y=32, w=16, h=16
			sprite.region_rect = Rect2(32, 32, 16, 16)

func _physics_process(delta: float) -> void:
	bob_offset += delta * 4.0
	sprite.position.y = sin(bob_offset) * 2.5
	
	# Find player if not cached
	if not is_instance_valid(player_ref):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0]
			
	if is_instance_valid(player_ref):
		var dist = global_position.distance_to(player_ref.global_position)
		if dist < MAGNET_RADIUS:
			magnet_speed = move_toward(magnet_speed, 280.0, delta * 600.0)
			var dir = (player_ref.global_position - global_position).normalized()
			global_position += dir * magnet_speed * delta
			
			if dist < PICKUP_RADIUS:
				collect()

func collect() -> void:
	if not is_instance_valid(player_ref):
		return
		
	match type:
		LootType.COIN:
			AudioManager.play_sfx("coin", 0.15, -2.0)
			if player_ref.has_method("add_gold"):
				player_ref.add_gold(value)
		LootType.POTION_HP:
			AudioManager.play_sfx("potion", 0.1, -1.0)
			if player_ref.has_method("heal"):
				player_ref.heal(value)
		LootType.XP_ORB:
			AudioManager.play_sfx("potion", 0.2, -3.0)
			if player_ref.has_method("add_xp"):
				player_ref.add_xp(value)
				
	queue_free()
