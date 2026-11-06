extends Area2D
class_name SlashEffect

var damage: int = 25
var knockback_force: float = 180.0
var knockback_dir: Vector2 = Vector2.RIGHT
var lifetime: float = 0.14
var timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func setup(p_direction: Vector2, p_damage: int) -> void:
	damage = p_damage
	knockback_dir = p_direction.normalized()
	rotation = p_direction.angle()

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	timer += delta
	var progress = timer / lifetime
	# Expand slightly and fade out
	scale = Vector2.ONE * (0.8 + progress * 0.4)
	sprite.modulate.a = 1.0 - progress
	
	if timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage, knockback_dir * knockback_force)
	elif body.is_in_group("destructible"):
		if body.has_method("break_prop"):
			body.break_prop()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage, knockback_dir * knockback_force)
	elif area.is_in_group("destructible"):
		if area.has_method("break_prop"):
			area.break_prop()
