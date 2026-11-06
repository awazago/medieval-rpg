extends Node2D
class_name DungeonTorch

var flicker_time: float = 0.0

@onready var light: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	flicker_time = randf() * TAU

func _process(delta: float) -> void:
	flicker_time += delta * 7.0
	var noise = sin(flicker_time) * 0.12 + sin(flicker_time * 2.3) * 0.08
	if light:
		light.energy = 0.85 + noise
		light.texture_scale = 1.6 + noise * 0.15
	if sprite:
		sprite.scale = Vector2(1.0 + noise * 0.2, 1.0 - noise * 0.1)
