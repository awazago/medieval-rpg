# res://client/scripts/vfx/soulshot_burst.gd
# Explosão de Partículas Douradas ao Desferir Golpe com Soulshot
class_name SoulshotBurst
extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	if particles:
		particles.emitting = true
	# Timer rápido para autoliberar após o efeito terminar
	get_tree().create_timer(0.9).timeout.connect(queue_free)
