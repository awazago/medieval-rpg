# res://client/scripts/vfx/floating_damage_number.gd
# Número de Dano Flutuante 3D (Floating Combat Text - Estilo Lineage II)
class_name FloatingDamageNumber
extends Node3D

@onready var label: Label3D = $Label3D

var float_speed: float = 2.0
var horizontal_velocity: Vector3 = Vector3.ZERO
var lifetime: float = 1.1
var time_elapsed: float = 0.0

func _ready() -> void:
	horizontal_velocity = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))

func setup(amount: int, is_critical: bool = false, is_miss: bool = false) -> void:
	if not label:
		await ready
		
	if is_miss:
		label.text = "ERROU"
		label.modulate = Color(0.7, 0.7, 0.8)
		label.font_size = 28
	elif is_critical:
		label.text = "★ " + str(amount) + "!"
		label.modulate = Color(1.0, 0.25, 0.1) # Vermelho rubi / crítico intenso
		label.font_size = 44
		label.outline_size = 10
	else:
		label.text = str(amount)
		label.modulate = Color(1.0, 0.95, 0.4) # Amarelo clássico Lineage
		label.font_size = 32
		label.outline_size = 6

func _process(delta: float) -> void:
	time_elapsed += delta
	position.y += float_speed * delta
	position += horizontal_velocity * delta
	
	# Desaceleração suave da subida
	float_speed = maxf(0.4, float_speed - (delta * 1.5))
	
	# Fade out nos últimos 40% do tempo de vida
	var alpha = clampf((lifetime - time_elapsed) / (lifetime * 0.4), 0.0, 1.0)
	if label:
		label.modulate.a = alpha
		
	if time_elapsed >= lifetime:
		queue_free()
