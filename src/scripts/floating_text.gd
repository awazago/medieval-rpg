extends Node2D
class_name FloatingText

@onready var label: Label = $Label

var velocity: Vector2 = Vector2(0, -50)
var duration: float = 0.75
var timer: float = 0.0

func setup(text: String, color: Color = Color.WHITE, scale_factor: float = 1.0) -> void:
	if not is_node_ready():
		await ready
	label.text = text
	label.modulate = color
	scale = Vector2.ONE * scale_factor
	velocity.x = randf_range(-20.0, 20.0)

func _process(delta: float) -> void:
	timer += delta
	position += velocity * delta
	velocity.y *= 0.95
	
	var progress = timer / duration
	if progress >= 1.0:
		queue_free()
	else:
		# Fade out towards the end
		if progress > 0.4:
			var alpha = 1.0 - (progress - 0.4) / 0.6
			modulate.a = alpha
