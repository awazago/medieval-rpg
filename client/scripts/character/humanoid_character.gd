# res://client/scripts/character/humanoid_character.gd
# Controlador de Malha Humanoide e Rig de Animação 3D Real (Godot 4 Forward+)
class_name HumanoidCharacterRig
extends Node3D

signal animation_finished(anim_name: String)

const MODEL_PRESETS = {
	"knight": preload("res://client/assets/models/characters/Knight.glb"),
	"mage": preload("res://client/assets/models/characters/Mage.glb"),
	"rogue": preload("res://client/assets/models/characters/Rogue.glb"),
	"barbarian": preload("res://client/assets/models/characters/Barbarian.glb"),
	"skeleton": preload("res://client/assets/models/characters/Skeleton_Warrior.glb")
}

const ANIMATION_MAP = {
	"idle": "Idle",
	"run": "Running_A",
	"attack": "1H_Melee_Attack_Slice_Horizontal",
	"cast": "Spellcast_Shoot",
	"sit_shop": "Sit_Floor_Idle",
	"death": "Death_A"
}

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var torso_mesh: CSGBox3D = $RootNode/Torso/ChestMesh if has_node("RootNode/Torso/ChestMesh") else null
@onready var shoulder_pads: CSGBox3D = $RootNode/Torso/ShoulderPads if has_node("RootNode/Torso/ShoulderPads") else null
@onready var right_hand_socket: Node3D = $RootNode/Torso/RightArm/RightForearm/RightHandSocket if has_node("RootNode/Torso/RightArm/RightForearm/RightHandSocket") else null

var model_3d: Node3D = null
var model_anim_player: AnimationPlayer = null

var current_action_lock: String = ""
var is_sitting_mode: bool = false
var current_model_type: String = "knight"

func _ready() -> void:
	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)
		
	# Inicializa modelo 3D
	_setup_model_reference()
	
	# Oculta blocos CSG caso haja modelo 3D ativo
	var csg_root = get_node_or_null("RootNode")
	if csg_root and model_3d:
		csg_root.visible = false
		
	play_anim("idle")

func _setup_model_reference() -> void:
	if has_node("Model3D"):
		model_3d = $Model3D
		model_anim_player = model_3d.find_child("AnimationPlayer", true, false)
		if model_anim_player and not model_anim_player.animation_finished.is_connected(_on_model_anim_finished):
			model_anim_player.animation_finished.connect(_on_model_anim_finished)

func set_character_model(model_key: String) -> void:
	current_model_type = model_key
	if not MODEL_PRESETS.has(model_key):
		return
		
	if model_3d:
		model_3d.queue_free()
		
	var scene = MODEL_PRESETS[model_key]
	model_3d = scene.instantiate()
	model_3d.name = "Model3D"
	add_child(model_3d)
	model_anim_player = model_3d.find_child("AnimationPlayer", true, false)
	if model_anim_player:
		model_anim_player.animation_finished.connect(_on_model_anim_finished)
		
	var csg_root = get_node_or_null("RootNode")
	if csg_root:
		csg_root.visible = false
		
	play_anim("idle")

func play_anim(anim_name: String, custom_speed: float = 1.0) -> void:
	# Não interrompe postura sentada a menos que explicitamente levantado
	if is_sitting_mode and anim_name != "sit_shop":
		return
		
	# Não interrompe animações prioritárias de ação (attack/cast) a menos que termine
	if current_action_lock != "" and anim_name in ["idle", "run", "sit_shop"]:
		return
		
	if anim_name in ["attack", "cast"]:
		current_action_lock = anim_name
		if anim_player and anim_player.has_animation(anim_name):
			anim_player.play(anim_name, -1, custom_speed)
	else:
		if anim_player and anim_player.has_animation(anim_name) and anim_player.current_animation != anim_name:
			anim_player.play(anim_name, 0.15, custom_speed)
			
	# Reproduz no modelo 3D real
	if model_anim_player:
		var target_anim = ANIMATION_MAP.get(anim_name, anim_name)
		if model_anim_player.has_animation(target_anim):
			if anim_name in ["attack", "cast"]:
				model_anim_player.play(target_anim, -1, custom_speed)
			elif model_anim_player.current_animation != target_anim:
				model_anim_player.play(target_anim, 0.2, custom_speed)

func play_sit_shop() -> void:
	is_sitting_mode = true
	current_action_lock = ""
	if anim_player and anim_player.has_animation("sit_shop"):
		anim_player.play("sit_shop", 0.25)
	if model_anim_player and model_anim_player.has_animation("Sit_Floor_Idle"):
		model_anim_player.play("Sit_Floor_Idle", 0.3)

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

func _on_model_anim_finished(anim_name: String) -> void:
	if current_action_lock != "":
		current_action_lock = ""
		if is_sitting_mode:
			play_sit_shop()
		else:
			play_anim("idle")

func get_right_hand_socket() -> Node3D:
	if model_3d:
		var s = model_3d.find_child("handslot.r", true, false)
		if s:
			return s
	return right_hand_socket

func update_armor(material: Material, pads_size: Vector3 = Vector3(1.1, 0.2, 0.5)) -> void:
	if torso_mesh and material:
		torso_mesh.material = material
	if shoulder_pads:
		shoulder_pads.size = pads_size
		if material:
			shoulder_pads.material = material
