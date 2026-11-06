extends StaticBody2D
class_name PropPot

var is_broken: bool = false
const LOOT_SCENE = preload("res://src/scenes/loot_pickup.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("destructible")

func break_prop() -> void:
	if is_broken:
		return
	is_broken = true
	
	AudioManager.play_sfx("pot_break", 0.15)
	col_shape.set_deferred("disabled", true)
	
	# Spawn loot
	call_deferred("spawn_loot")
	
	# Fade and pop
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)

func spawn_loot() -> void:
	var roll = randf()
	if roll < 0.65:
		# Spawn 1 to 2 coins (type 0 = COIN)
		var count = randi_range(1, 2)
		for i in range(count):
			var loot = LOOT_SCENE.instantiate()
			loot.setup(0, randi_range(1, 3))
			loot.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
			get_parent().add_child(loot)
	elif roll < 0.85:
		# Spawn small health potion (type 1 = POTION_HP)
		var loot = LOOT_SCENE.instantiate()
		loot.setup(1, 25)
		loot.global_position = global_position
		get_parent().add_child(loot)
