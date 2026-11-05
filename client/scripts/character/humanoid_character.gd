# res://client/scripts/character/humanoid_character.gd
# Controlador de Malha Humanoide e Rig de Animação (Godot 4 Forward+)
class_name HumanoidCharacterRig
extends Node3D

signal animation_finished(anim_name: String)

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var torso_mesh: CSGBox3D = $RootNode/Torso/ChestMesh
@onready var shoulder_pads: CSGBox3D = $RootNode/Torso/ShoulderPads
@onready var right_hand_socket: Node3D = $RootNode/Torso/RightArm/RightForearm/RightHandSocket

var current_action_lock: String = ""
var is_sitting_mode: bool = false

func _ready() -> void:
	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)
		play_anim("idle")

func play_anim(anim_name: String, custom_speed: float = 1.0) -> void:
	if not anim_player or not anim_player.has_animation(anim_name):
		return
		
	# Não interrompe postura sentada a menos que explicitamente levantado
	if is_sitting_mode and anim_name != "sit_shop":
		return
		
	# Não interrompe animações prioritárias de ação (attack/cast) a menos que termine
	if current_action_lock != "" and anim_name in ["idle", "run", "sit_shop"]:
		return
		
	if anim_name in ["attack", "cast"]:
		current_action_lock = anim_name
		anim_player.play(anim_name, -1, custom_speed)
	else:
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name, 0.15, custom_speed)

func play_sit_shop() -> void:
	is_sitting_mode = true
	current_action_lock = ""
	if anim_player and anim_player.has_animation("sit_shop"):
		anim_player.play("sit_shop", 0.25)

func stop_sit() -> void:
	is_sitting_mode = false
	play_anim("idle")

func is_sitting() -> bool:
	return is_sitting_mode

func is_action_locked() -> bool:
	return current_action_lock != ""

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == current_action_lock:
		current_action_lock = ""
		if is_sitting_mode:
			play_anim("sit_shop")
		else:
			play_anim("idle")
	animation_finished.emit(anim_name)

func get_right_hand_socket() -> Node3D:
	return right_hand_socket

func update_armor(material: Material, pads_size: Vector3 = Vector3(1.1, 0.2, 0.5)) -> void:
	if torso_mesh and material:
		torso_mesh.material = material
	if shoulder_pads:
		shoulder_pads.size = pads_size
		if material:
			shoulder_pads.material = material
