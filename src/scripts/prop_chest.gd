extends StaticBody2D
class_name PropChest

var is_open: bool = false
const LOOT_SCENE = preload("res://src/scenes/loot_pickup.tscn")

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("destructible")

func break_prop() -> void:
	open_chest()

func open_chest() -> void:
	if is_open:
		return
	is_open = true
	
	AudioManager.play_sfx("chest_open", 0.05, 1.0)
	# Switch to opened frame (x=16, y=0, w=16, h=16)
	sprite.region_rect = Rect2(16, 0, 16, 16)
	
	# Bounce punch animation
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.25, 0.8), 0.06)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	call_deferred("spawn_chest_loot")

func spawn_chest_loot() -> void:
	# Spew out 4-6 coins in a fan (type 0 = COIN)
	var coin_count = randi_range(4, 6)
	for i in range(coin_count):
		var loot = LOOT_SCENE.instantiate()
		loot.setup(0, randi_range(2, 5))
		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * randf_range(16.0, 36.0)
		loot.global_position = global_position + offset
		get_parent().add_child(loot)
		
	# Spew 1 guaranteed HP potion (type 1 = POTION_HP)
	var potion = LOOT_SCENE.instantiate()
	potion.setup(1, 40)
	potion.global_position = global_position + Vector2(0, 20)
	get_parent().add_child(potion)
	
	# Spew 1 XP orb (type 2 = XP_ORB)
	var xp = LOOT_SCENE.instantiate()
	xp.setup(2, 30)
	xp.global_position = global_position + Vector2(0, -20)
	get_parent().add_child(xp)
