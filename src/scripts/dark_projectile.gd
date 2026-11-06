extends Area2D
class_name DarkProjectile

var speed: float = 140.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 15
var lifetime: float = 4.0
var timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func setup(p_dir: Vector2, p_damage: int = 15, p_speed: float = 140.0) -> void:
	direction = p_dir.normalized()
	damage = p_damage
	speed = p_speed
	rotation = direction.angle()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	timer += delta
	
	# Pulsing glow
	var pulse = 1.0 + 0.2 * sin(timer * 15.0)
	scale = Vector2.ONE * pulse
	
	if timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, direction * 100.0)
		queue_free()
	elif not body.is_in_group("enemies"):
		# Hit wall
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var p = area.get_parent()
		if p and p.has_method("take_damage"):
			p.take_damage(damage, direction * 100.0)
		queue_free()
