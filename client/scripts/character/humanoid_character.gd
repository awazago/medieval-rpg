# res://client/scripts/character/humanoid_character.gd
# Controlador de Malha Humanoide e Rig de Animação 3D Real (Lineage II High Fantasy Aesthetic)
class_name HumanoidCharacterRig
extends Node3D

signal animation_finished(anim_name: String)

var MODEL_PRESETS: Dictionary = {}

func _init() -> void:
	_init_model_presets()

func _init_model_presets() -> void:
	var paths = {
		"knight": "res://client/assets/models/realistic/characters/character_knight.glb",
		"mage": "res://client/assets/models/realistic/characters/character_knight.glb",
		"rogue": "res://client/assets/models/realistic/characters/character_knight.glb",
		"barbarian": "res://client/assets/models/realistic/characters/character_knight.glb",
		"skeleton": "res://client/assets/models/characters/Skeleton_Warrior.glb"
	}
	for k in paths:
		if ResourceLoader.exists(paths[k]):
			var res = load(paths[k])
			if res:
				MODEL_PRESETS[k] = res

const ANIMATION_MAP = {
	"idle": "Idle",
	"run": "Running_A",
	"attack": "1H_Melee_Attack_Slice_Horizontal",
	"attack_2h": "2H_Melee_Attack_Slice",
	"cast": "Spellcast_Shoot",
	"sit_shop": "Sit_Floor_Idle",
	"death": "Death_A"
}

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var torso_mesh: Node3D = null
var shoulder_pads: Node3D = null
var right_hand_socket: Node3D = null

var model_3d: Node3D = null
var model_anim_player: AnimationPlayer = null

var current_action_lock: String = ""
var is_sitting_mode: bool = false
var current_model_type: String = "knight"

var head_bone_idx: int = -1
var skel_node: Skeleton3D = null
var head_scale_factor: Vector3 = Vector3(0.68, 0.68, 0.68)

func _ready() -> void:
	torso_mesh = get_node_or_null("RootNode/Torso/ChestMesh")
	shoulder_pads = get_node_or_null("RootNode/Torso/ShoulderPads")
	right_hand_socket = get_node_or_null("RootNode/Torso/RightArm/RightForearm/RightHandSocket")

	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)
		
	# Inicializa modelo 3D se já existir na árvore
	_setup_model_reference()
	
	# Garante que haja sempre malha visível (modelo 3D ou fallback CSG estilizado)
	var csg_root = get_node_or_null("RootNode")
	if csg_root:
		csg_root.visible = (model_3d == null)
	if model_3d:
		model_3d.visible = true
		
	play_anim("idle")

func _process(_delta: float) -> void:
	# Mantém a proporção da cabeça elegante e realista (8 cabeças) em cada frame de animação
	if head_bone_idx != -1 and is_instance_valid(skel_node):
		skel_node.set_bone_pose_scale(head_bone_idx, head_scale_factor)

const REALISTIC_ANIMS = {
	"idle": "res://client/assets/models/realistic/characters/anim_idle.glb",
	"run": "res://client/assets/models/realistic/characters/anim_run.glb",
	"walk": "res://client/assets/models/realistic/characters/anim_walk.glb",
	"attack": "res://client/assets/models/realistic/characters/anim_attack.glb",
	"cast": "res://client/assets/models/realistic/characters/anim_cast.glb",
	"death": "res://client/assets/models/realistic/characters/anim_death.glb",
	"sit_shop": "res://client/assets/models/realistic/characters/anim_sit.glb"
}

func _load_realistic_animations() -> void:
	if not model_3d or not model_anim_player:
		return
	var skel: Skeleton3D = model_3d.find_child("Skeleton3D", true, false)
	if not skel or skel.find_bone("mixamorig_Hips") == -1:
		return
		
	var lib = model_anim_player.get_animation_library("")
	if not lib:
		lib = AnimationLibrary.new()
		model_anim_player.add_animation_library("", lib)
		
	for a_key in REALISTIC_ANIMS:
		if lib.has_animation(a_key):
			continue
		var a_path = REALISTIC_ANIMS[a_key]
		if ResourceLoader.exists(a_path):
			var a_scene = load(a_path)
			if a_scene:
				var inst = a_scene.instantiate()
				var p = inst.find_child("AnimationPlayer", true, false)
				if p and p.has_animation("Armature|mixamo_com|Layer0"):
					var anim = p.get_animation("Armature|mixamo_com|Layer0")
					var dup = anim.duplicate()
					if a_key in ["idle", "run", "walk", "sit_shop"]:
						dup.loop_mode = Animation.LOOP_LINEAR
					lib.add_animation(a_key, dup)
				inst.queue_free()

func _setup_model_reference() -> void:
	if has_node("Model3D"):
		model_3d = $Model3D
		_clean_and_setup_model_accessories()
		_apply_lineage2_heroic_proportions()
		_apply_lineage2_pbr_materials()
		
		model_anim_player = model_3d.find_child("AnimationPlayer", true, false)
		if model_anim_player:
			_load_realistic_animations()
			if not model_anim_player.animation_finished.is_connected(_on_model_anim_finished):
				model_anim_player.animation_finished.connect(_on_model_anim_finished)

func set_character_model(model_key: String) -> void:
	current_model_type = model_key
	if MODEL_PRESETS.is_empty() or not MODEL_PRESETS.has(model_key):
		_init_model_presets()
	if not MODEL_PRESETS.has(model_key):
		print("[HumanoidRig] Preset não encontrado: ", model_key)
		return
		
	if model_3d:
		if is_instance_valid(model_3d) and model_3d.get_parent() == self:
			remove_child(model_3d)
		model_3d.queue_free()
		model_3d = null
		head_bone_idx = -1
		skel_node = null
		
	var scene = MODEL_PRESETS[model_key]
	model_3d = scene.instantiate()
	model_3d.name = "Model3D"
	add_child(model_3d)
	
	_clean_and_setup_model_accessories()
	_apply_lineage2_heroic_proportions()
	_apply_lineage2_pbr_materials()
	
	model_anim_player = model_3d.find_child("AnimationPlayer", true, false)
	if model_anim_player:
		_load_realistic_animations()
		model_anim_player.animation_finished.connect(_on_model_anim_finished)
		
	var csg_root = get_node_or_null("RootNode")
	if csg_root:
		csg_root.visible = false
		
	play_anim("idle")
	print("[HumanoidRig] Modelo 3D carregado com sucesso: ", model_key)

## Remove armas/escudos embutidos duplicados e ativa capa medieval
func _clean_and_setup_model_accessories() -> void:
	if not model_3d:
		return
		
	var built_in_weapons = [
		"1H_Sword", "2H_Sword", "1H_Sword_Offhand",
		"Badge_Shield", "Rectangle_Shield", "Round_Shield", "Spike_Shield",
		"Spellbook", "Spellbook_open", "1H_Wand", "2H_Staff",
		"Knife_Offhand", "1H_Crossbow", "2H_Crossbow", "Knife", "Throwable",
		"1H_Axe_Offhand", "Barbarian_Round_Shield", "1H_Axe", "2H_Axe", "Mug"
	]
	
	for w_name in built_in_weapons:
		var node = model_3d.find_child(w_name, true, false)
		if node and "visible" in node:
			node.visible = false
			
	# Mantém capa nobre ativada
	for cape_name in ["Knight_Cape", "Mage_Cape", "Rogue_Cape", "Barbarian_Cape"]:
		var cape = model_3d.find_child(cape_name, true, false)
		if cape and "visible" in cape:
			cape.visible = true

## Elimina a proporção chibi/cartoon e aplica anatomia heroica canônica Lineage II (8 cabeças)
func _apply_lineage2_heroic_proportions() -> void:
	if not model_3d:
		return
		
	# 1. Ajusta o capacete / elmo
	for helm_name in ["Knight_Helmet", "Mage_Hat", "Barbarian_Hat"]:
		var helm = model_3d.find_child(helm_name, true, false)
		if helm and "scale" in helm:
			helm.scale = head_scale_factor
			
	# 2. Localiza o osso da cabeça no Skeleton3D para aplicar a pose de cabeça reduzida
	skel_node = model_3d.find_child("Skeleton3D", true, false)
	if not skel_node:
		skel_node = model_3d.find_child("GeneralSkeleton", true, false)
	if skel_node and skel_node is Skeleton3D:
		head_bone_idx = skel_node.find_bone("head")
		if head_bone_idx != -1:
			skel_node.set_bone_pose_scale(head_bone_idx, head_scale_factor)

## Aplica materiais PBR realistas de metal forjado, ouro nobre e veludo medieval com segurança de nós
func _apply_lineage2_pbr_materials() -> void:
	if not model_3d:
		return
		
	# 1. Material da Capa Nobre (Veludo carmesim / azul imperial com reflexo de borda)
	var cape_mat = StandardMaterial3D.new()
	match current_model_type:
		"mage":
			cape_mat.albedo_color = Color(0.1, 0.22, 0.58, 1) # Azul Real dos Magos de marfim
		"rogue":
			cape_mat.albedo_color = Color(0.22, 0.1, 0.32, 1) # Roxo Sombrio dos Elfos Negros
		"barbarian":
			cape_mat.albedo_color = Color(0.48, 0.16, 0.08, 1) # Couro de Guerra Orc
		_:
			cape_mat.albedo_color = Color(0.68, 0.08, 0.12, 1) # Carmesim clássico de Aden
			
	cape_mat.roughness = 0.82
	cape_mat.rim_enabled = true
	cape_mat.rim = 0.75
	cape_mat.rim_tint = 0.4
	cape_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	for cape_name in ["Knight_Cape", "Mage_Cape", "Rogue_Cape", "Barbarian_Cape"]:
		var cape_node = model_3d.find_child(cape_name, true, false)
		if cape_node:
			_apply_material_to_node_or_children(cape_node, cape_mat)
			
	# 2. Material do Elmo de Aço Polido
	var helm_node = model_3d.find_child("Knight_Helmet", true, false)
	if helm_node:
		var helm_mat = StandardMaterial3D.new()
		helm_mat.albedo_color = Color(0.85, 0.88, 0.92, 1)
		helm_mat.metallic = 0.95
		helm_mat.roughness = 0.22
		helm_mat.clearcoat_enabled = true
		helm_mat.clearcoat = 0.3
		_apply_material_to_node_or_children(helm_node, helm_mat)

func _apply_material_to_node_or_children(target: Node, mat: Material) -> void:
	if not target or not mat:
		return
	if target is MeshInstance3D:
		target.material_override = mat
	for child in target.get_children():
		if child is MeshInstance3D:
			child.material_override = mat

func play_anim(anim_name: String, custom_speed: float = 1.0) -> void:
	# Não interrompe postura sentada a menos que explicitamente levantado
	if is_sitting_mode and anim_name != "sit_shop":
		return
		
	# Não interrompe animações prioritárias de ação (attack/cast) a menos que termine
	if current_action_lock != "" and anim_name in ["idle", "run", "sit_shop"]:
		return
		
	if anim_name in ["attack", "attack_2h", "cast"]:
		current_action_lock = anim_name
		if anim_player and anim_player.has_animation(anim_name):
			anim_player.play(anim_name, -1, custom_speed)
	else:
		if anim_player and anim_player.has_animation(anim_name) and anim_player.current_animation != anim_name:
			anim_player.play(anim_name, 0.15, custom_speed)
			
	# Reproduz no modelo 3D real
	if model_anim_player:
		var target_anim = anim_name
		if not model_anim_player.has_animation(target_anim):
			target_anim = ANIMATION_MAP.get(anim_name, anim_name)
		if model_anim_player.has_animation(target_anim):
			if anim_name in ["attack", "attack_2h", "cast"]:
				model_anim_player.play(target_anim, -1, custom_speed)
			elif model_anim_player.current_animation != target_anim:
				model_anim_player.play(target_anim, 0.2, custom_speed)

func play_sit_shop() -> void:
	is_sitting_mode = true
	current_action_lock = ""
	if anim_player and anim_player.has_animation("sit_shop"):
		anim_player.play("sit_shop", 0.25)
	if model_anim_player:
		if model_anim_player.has_animation("sit_shop"):
			model_anim_player.play("sit_shop", 0.3)
		elif model_anim_player.has_animation("Sit_Floor_Idle"):
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
		var existing_socket = model_3d.find_child("RightHandSocket", true, false)
		if existing_socket and existing_socket is Node3D:
			return existing_socket
			
		var skel: Skeleton3D = model_3d.find_child("Skeleton3D", true, false)
		if skel:
			var bone_idx = skel.find_bone("mixamorig_RightHand")
			if bone_idx != -1:
				var attachment = BoneAttachment3D.new()
				attachment.name = "RightHandSocket"
				attachment.bone_name = "mixamorig_RightHand"
				skel.add_child(attachment)
				return attachment
				
		var s = model_3d.find_child("handslot.r", true, false)
		if s and s is Node3D:
			return s
	return right_hand_socket

func update_armor(material: Material, pads_size: Vector3 = Vector3(1.1, 0.2, 0.5)) -> void:
	if torso_mesh and material:
		torso_mesh.material = material
	if shoulder_pads:
		shoulder_pads.size = pads_size
		if material:
			shoulder_pads.material = material

func equip_weapon(weapon_type: String) -> void:
	var socket = get_right_hand_socket()
	if not socket:
		return
	for child in socket.get_children():
		if child.name.begins_with("Equipped_"):
			child.queue_free()
			
	var weapon_scenes = {
		"sword": "res://client/scenes/weapons/sword_1h.tscn",
		"staff": "res://client/scenes/weapons/staff_2h.tscn",
		"dagger": "res://client/scenes/weapons/dagger_1h.tscn",
		"bow": "res://client/scenes/weapons/bow_2h.tscn",
		"axe": "res://client/scenes/weapons/sword_1h.tscn"
	}
	var path = weapon_scenes.get(weapon_type, weapon_scenes["sword"])
	if ResourceLoader.exists(path):
		var w_scene = load(path)
		if w_scene:
			var w_inst = w_scene.instantiate()
			w_inst.name = "Equipped_" + weapon_type
			socket.add_child(w_inst)
