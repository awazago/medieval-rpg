# res://client/scripts/vfx/level_up_burst.gd
# Pilar de Luz e Partículas Douradas ao Subir de Nível (Estilo Lineage II)
class_name LevelUpBurst
extends Node3D

@onready var light: OmniLight3D = $OmniLight3D
@onready var pillar: MeshInstance3D = $PillarMesh

var duration: float = 2.2
var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	# O pilar sobe e expande
	if pillar:
		pillar.scale.y += delta * 4.0
		pillar.rotate_y(delta * 5.0)
		
	var alpha = clampf((duration - time_elapsed) / (duration * 0.5), 0.0, 1.0)
	if pillar and pillar.get_surface_override_material(0):
		var mat = pillar.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.albedo_color.a = alpha
			
	if time_elapsed >= duration:
		queue_free()
