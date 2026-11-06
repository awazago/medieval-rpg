# res://client/scripts/player_character.gd
# Controlador de Personagem Jogável (Linha de herança Lineage II)
class_name PlayerCharacter
extends CharacterBody3D

signal stats_updated(hp: int, max_hp: int, mp: int, max_mp: int, cp: int, max_cp: int)
signal target_changed(new_target: Node3D)
signal soulshot_toggled(active: bool)
signal exp_updated(current_exp: int, required_exp: int, pct: float, sp: int)
signal leveled_up(new_level: int)

const LEVEL_UP_SCENE = preload("res://client/scenes/vfx/level_up_burst.tscn")
const PRIVATE_STORE_SIGN_SCENE = preload("res://client/scenes/ui/private_store_sign_3d.tscn")

const WEAPON_MODELS = {
	"sword_1h": preload("res://client/scenes/weapons/sword_1h.tscn"),
	"dagger_1h": preload("res://client/scenes/weapons/dagger_1h.tscn"),
	"staff_2h": preload("res://client/scenes/weapons/staff_2h.tscn"),
	"bow_2h": preload("res://client/scenes/weapons/bow_2h.tscn")
}

var is_sitting: bool = false
var active_store_sign: Node3D = null

@export_category("Identidade")
@export var character_name: String = "Guerreiro"
@export var race_id: String = "human"
@export var archetype: String = "warrior"
@export var level: int = 1

@export_category("Movimento")
@export var walk_speed: float = 5.0
@export var jump_velocity: float = 4.5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Estatísticas Lineage II")
@export var max_hp: int = 150
var current_hp: int = 150
@export var max_mp: int = 90
var current_mp: int = 90
@export var max_cp: int = 100 # Combat Points (Escudo de PVP/Combate clássico do L2)
var current_cp: int = 100

var base_hp: int = 150
var base_mp: int = 90

var base_walk_speed: float = 5.0
var base_p_atk: float = 24.0
var base_p_def: float = 20.0
var base_m_atk: float = 12.0
var base_m_def: float = 15.0

var p_atk: float = 24.0
var p_def: float = 20.0
var m_atk: float = 12.0
var m_def: float = 15.0

var current_exp: int = 0
var required_exp: int = 68
var current_sp: int = 0

var soulshots_enabled: bool = false
var selected_target: Node3D = null

@onready var visual_mesh: Node3D = $VisualMesh
@onready var body_mesh: Node = get_node_or_null("VisualMesh/BodyMesh")
@onready var shoulder_pads: Node = get_node_or_null("VisualMesh/ShoulderPads")
@onready var right_hand_socket: Node = get_node_or_null("VisualMesh/RightHandSocket")
@onready var rig: HumanoidCharacterRig = get_node_or_null("VisualMesh/HumanoidCharacterRig")
@onready var camera_pivot: SpringArm3D = $CameraPivot
@onready var inventory: InventoryManager = $InventoryManager

func _get_audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")

func _get_game_data() -> Node:
	return get_node_or_null("/root/GameData")

func _ready() -> void:
	current_hp = max_hp
	current_mp = max_mp
	current_cp = max_cp
	stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
	_emit_exp_update()
	
	if rig:
		var sock = rig.get_right_hand_socket()
		if sock:
			right_hand_socket = sock
		rig.play_anim("idle")
	
	if inventory:
		inventory.setup_weight_limit(43) # Constituição base humana
		inventory.item_equipped.connect(_on_item_equipped)
		inventory.item_used.connect(_on_item_used)
		inventory.weight_changed.connect(_on_weight_penalty_changed)

func add_exp_and_sp(exp_gain: int, sp_gain: int) -> void:
	current_exp += exp_gain
	current_sp += sp_gain
	
	# Verifica múltiplos level-ups se receber muito XP
	while current_exp >= required_exp:
		current_exp -= required_exp
		level += 1
		# Incremento de stats do Lineage II
		max_hp += 35
		max_mp += 20
		max_cp += 25
		base_p_atk += 4.0
		base_m_atk += 3.0
		base_p_def += 3.0
		base_m_def += 2.5
		
		# Restaura vida e mana totais
		current_hp = max_hp
		current_mp = max_mp
		current_cp = max_cp
		
		# Próximo patamar de XP
		required_exp = int(round(required_exp * 2.3))
		
		# Efeito visual de pilar dourado
		var burst = LEVEL_UP_SCENE.instantiate()
		add_child(burst)
		burst.global_position = global_position
		
		var am = _get_audio_manager()
		if am:
			am.play_sfx("level_up")
		
		leveled_up.emit(level)
		stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
		
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("[color=gold]★ [NÍVEL SUPERIOR!] Parabéns, você alcançou o Nível " + str(level) + "! Seus atributos aumentaram e seu HP foi restaurado.[/color]")
			
	_emit_exp_update()

func _emit_exp_update() -> void:
	var pct = (float(current_exp) / float(max_exp_target())) * 100.0
	exp_updated.emit(current_exp, required_exp, pct, current_sp)

func max_exp_target() -> int:
	return maxi(1, required_exp)

func _on_item_equipped(item_data: Dictionary, slot_type: String) -> void:
	if slot_type == "weapon":
		if not item_data.is_empty():
			p_atk = base_p_atk + item_data.get("p_atk", 0)
			m_atk = base_m_atk + item_data.get("m_atk", 0)
			print("[Personagem] Arma equipada: ", item_data.get("name"), " | P.Atk: ", p_atk)
		else:
			p_atk = base_p_atk
			m_atk = base_m_atk
			print("[Personagem] Arma desequipada. P.Atk restaurado: ", p_atk)
		_update_weapon_mesh(item_data)
	elif slot_type == "chest":
		if not item_data.is_empty():
			p_def = base_p_def + item_data.get("p_def", 0)
			print("[Personagem] Armadura equipada: ", item_data.get("name"), " | P.Def: ", p_def)
		else:
			p_def = base_p_def
			print("[Personagem] Armadura desequipada. P.Def restaurado: ", p_def)
		_update_armor_mesh(item_data)

## Paperdoll: Atualiza o modelo 3D da arma na mão direita
func _update_weapon_mesh(item_data: Dictionary) -> void:
	var socket: Node3D = null
	if rig and rig.has_method("get_right_hand_socket"):
		socket = rig.get_right_hand_socket()
	if not socket:
		socket = right_hand_socket
	if not socket:
		return
		
	# Remove arma anterior do socket esqueletal ativo e de fallbacks
	for child in socket.get_children():
		child.queue_free()
	if right_hand_socket and right_hand_socket != socket:
		for child in right_hand_socket.get_children():
			child.queue_free()
		
	if item_data.is_empty():
		return
		
	var weapon_type = item_data.get("weapon_type", "")
	if WEAPON_MODELS.has(weapon_type):
		var weapon_instance = WEAPON_MODELS[weapon_type].instantiate()
		socket.add_child(weapon_instance)
		print("[Paperdoll] Modelo 3D anexado à mão direita (Socket Esqueletal): ", weapon_type)

## Paperdoll: Atualiza as texturas e malha da armadura
func _update_armor_mesh(item_data: Dictionary) -> void:
	var mat = StandardMaterial3D.new()
	var item_id = item_data.get("id", "")
	var pads_sz = Vector3(1.0, 0.2, 0.45)
	
	match item_id:
		"leather_tunic":
			mat.albedo_color = Color(0.4, 0.28, 0.16)
			mat.roughness = 0.85
			mat.metallic = 0.0
			pads_sz = Vector3(0.9, 0.15, 0.4)
		"iron_breastplate":
			mat.albedo_color = Color(0.8, 0.84, 0.88)
			mat.metallic = 0.95
			mat.roughness = 0.2
			pads_sz = Vector3(1.2, 0.25, 0.55)
		"brigandine_tunic":
			mat.albedo_color = Color(0.28, 0.32, 0.38)
			mat.metallic = 0.75
			mat.roughness = 0.35
			pads_sz = Vector3(1.25, 0.28, 0.6)
		"mithril_tunic":
			mat.albedo_color = Color(0.65, 0.82, 0.95)
			mat.metallic = 0.4
			mat.roughness = 0.45
			pads_sz = Vector3(0.95, 0.18, 0.42)
		_:
			# Roupa inicial básica
			mat.albedo_color = Color(0.5, 0.52, 0.55)
			mat.roughness = 0.7
			
	if body_mesh and "material" in body_mesh:
		body_mesh.material = mat
	if shoulder_pads:
		if "size" in shoulder_pads:
			shoulder_pads.size = pads_sz
		if "material" in shoulder_pads:
			shoulder_pads.material = mat
	if rig:
		rig.update_armor(mat, pads_sz)

## Aplica os dados, atributos e silhueta 3D da Raça escolhida
func apply_race_data(race_key: String) -> void:
	race_id = race_key
	var gd = _get_game_data()
	var race_data = gd.get_race(race_key) if gd else {}
	if race_data.is_empty():
		return
		
	var stats = race_data.get("base_stats", {})
	base_hp = race_data.get("base_hp", 120)
	base_mp = race_data.get("base_mp", 80)
	var spd = race_data.get("base_speed", 125)
	
	# Converte a velocidade de Lineage para metros por segundo do Godot
	walk_speed = (spd / 125.0) * 5.0
	base_walk_speed = walk_speed
	
	max_hp = base_hp
	max_mp = base_mp
	current_hp = max_hp
	current_mp = max_mp
	
	# Ajusta capacidade de carga baseada na CON da raça
	var con_stat = stats.get("con", 40)
	if inventory:
		inventory.setup_weight_limit(con_stat)
		
	# Ajuste de Proporção e Modelo Visual 3D Real por Raça (Lineage II Authentic)
	if rig and rig.has_method("set_character_model"):
		match race_key:
			"orc":
				rig.set_character_model("barbarian")
				visual_mesh.scale = Vector3(1.22, 1.42, 1.22)
			"light_elf":
				rig.set_character_model("mage")
				visual_mesh.scale = Vector3(0.80, 1.38, 0.80)
			"dark_elf":
				rig.set_character_model("rogue")
				visual_mesh.scale = Vector3(0.82, 1.35, 0.82)
			"dwarf":
				rig.set_character_model("knight")
				visual_mesh.scale = Vector3(1.15, 0.98, 1.15)
			_: # Humano
				rig.set_character_model("knight")
				visual_mesh.scale = Vector3(0.86, 1.32, 0.86)
	else:
		match race_key:
			"orc":
				visual_mesh.scale = Vector3(1.22, 1.42, 1.22)
			"light_elf":
				visual_mesh.scale = Vector3(0.80, 1.38, 0.80)
			"dark_elf":
				visual_mesh.scale = Vector3(0.82, 1.35, 0.82)
			"dwarf":
				visual_mesh.scale = Vector3(1.15, 0.98, 1.15)
			_: # Humano
				visual_mesh.scale = Vector3(0.86, 1.32, 0.86)
			
	stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
	print("[Raça] Raça aplicada ao personagem: ", race_data.get("name"), " | HP: ", max_hp, " | Velocidade: ", walk_speed)

## Aplica os dados da Classe / Arquétipo (Guerreiro vs Místico)
func apply_archetype(arch_key: String) -> void:
	archetype = arch_key
	var is_mystic = (arch_key == "mystic" or arch_key == "mage")
	if is_mystic:
		max_mp = int(base_mp * 1.6)
		current_mp = max_mp
		max_hp = int(base_hp * 0.85)
		current_hp = max_hp
		m_atk = 28.0
		p_atk = 14.0
		if rig and rig.has_method("set_character_model"):
			rig.set_character_model("mage")
			if rig.has_method("equip_weapon"):
				rig.equip_weapon("staff")
	else:
		max_hp = int(base_hp * 1.25)
		current_hp = max_hp
		max_mp = int(base_mp * 0.8)
		current_mp = max_mp
		p_atk = 28.0
		m_atk = 12.0
		if rig and rig.has_method("set_character_model"):
			match race_id:
				"orc":
					rig.set_character_model("barbarian")
					if rig.has_method("equip_weapon"):
						rig.equip_weapon("axe")
				"dark_elf":
					rig.set_character_model("rogue")
					if rig.has_method("equip_weapon"):
						rig.equip_weapon("dagger")
				_:
					rig.set_character_model("knight")
					if rig.has_method("equip_weapon"):
						rig.equip_weapon("sword")
						
	stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
	print("[Classe] Classe aplicada ao personagem: ", arch_key, " | HP: ", max_hp, " | MP: ", max_mp)

func _on_item_used(item_data: Dictionary) -> void:
	if item_data.get("effect") == "heal_over_time":
		var heal = item_data.get("heal_amount", 50)
		current_hp = mini(max_hp, current_hp + heal)
		stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
		print("[Personagem] Poção usada! Recuperou ", heal, " HP.")
	elif item_data.get("id") == "soulshot_none":
		toggle_soulshots()

func _on_weight_penalty_changed(_current: int, _max_w: int, _pct: float, penalty_tier: int) -> void:
	match penalty_tier:
		0, 1:
			walk_speed = base_walk_speed
		2:
			walk_speed = base_walk_speed * 0.8 # -20% Move Speed
			print("[Inventário] Penalidade de Peso: -20% Velocidade.")
		3:
			walk_speed = base_walk_speed * 0.3 # Sobrecarregado severo
			print("[Inventário] Penalidade Severa: Sobrecarregado!")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Se estiver sentado montando loja, permanece imóvel
	if is_sitting:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Direção de Movimento orientada pela rotação do jogador/câmera
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()
	
	# Animações de Locomoção via Rig Humanoide
	if rig and not is_sitting:
		if direction != Vector3.ZERO:
			rig.play_anim("run", walk_speed / 5.0)
		else:
			rig.play_anim("idle")

func play_attack_animation() -> void:
	if rig and not is_sitting:
		rig.play_anim("attack", 1.2)

func play_cast_animation() -> void:
	if rig and not is_sitting:
		rig.play_anim("cast", 1.0)

## Inicia a postura de Loja Pessoal (senta no chão e afixa plaquinha flutuante 3D)
func start_sitting_shop(store_type: int, store_title: String) -> void:
	is_sitting = true
	velocity = Vector3.ZERO
	if rig:
		rig.play_sit_shop()
		
	if active_store_sign:
		active_store_sign.queue_free()
		
	active_store_sign = PRIVATE_STORE_SIGN_SCENE.instantiate()
	add_child(active_store_sign)
	active_store_sign.position = Vector3(0, 1.45, 0)
	if active_store_sign.has_method("setup"):
		active_store_sign.setup(store_type, store_title)
	print("[Private Store] Jogador sentou e abriu loja: ", store_title)

## Encerra a postura de Loja Pessoal (levanta e remove plaquinha 3D)
func stop_sitting_shop() -> void:
	is_sitting = false
	if rig:
		rig.stop_sit()
	if active_store_sign:
		active_store_sign.queue_free()
		active_store_sign = null
	print("[Private Store] Jogador encerrou a loja e levantou.")

func toggle_private_store_window() -> void:
	var store_win = get_tree().get_first_node_in_group("private_store_window")
	var store_mgr = get_tree().get_first_node_in_group("private_store_manager")
	if store_win:
		if store_win.visible:
			store_win.close_window()
		else:
			store_win.open_for_player(self, store_mgr)

func _unhandled_input(event: InputEvent) -> void:
	# Ativação rápida de Soulshots (Auto-Shot)
	if event is InputEventKey and event.is_action_pressed("ui_focus_next"):
		_cycle_target()
		
	# Tecla de Atalho para ligar/desligar Soulshots
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		toggle_soulshots()

	# Tecla P: Abre a janela de Loja Pessoal (Private Store)
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		toggle_private_store_window()

func toggle_soulshots() -> void:
	soulshots_enabled = not soulshots_enabled
	soulshot_toggled.emit(soulshots_enabled)
	var am = _get_audio_manager()
	if soulshots_enabled and am:
		am.play_sfx("soulshot_activate")
	print("[Combate] Soulshots ativados: ", soulshots_enabled)

func _cycle_target() -> void:
	var potential_targets = get_tree().get_nodes_in_group("monsters")
	if potential_targets.is_empty():
		return
		
	# Seleciona o monstro mais próximo
	var closest_target: Node3D = null
	var min_distance: float = 9999.0
	for mob in potential_targets:
		if mob is Node3D and mob != self:
			var dist = global_position.distance_to(mob.global_position)
			if dist < min_distance and dist <= 30.0:
				min_distance = dist
				closest_target = mob
				
	set_target(closest_target)

func set_target(target: Node3D) -> void:
	selected_target = target
	target_changed.emit(selected_target)
	if selected_target:
		print("[Target] Alvo selecionado: ", selected_target.name)

func take_damage(damage: int, is_critical: bool) -> void:
	# O CP (Combat Points) absorve o dano primeiro se existir
	var remaining_damage = damage
	if current_cp > 0:
		if current_cp >= remaining_damage:
			current_cp -= remaining_damage
			remaining_damage = 0
		else:
			remaining_damage -= current_cp
			current_cp = 0
			
	current_hp = maxi(0, current_hp - remaining_damage)
	stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
	
	if current_hp <= 0:
		_on_death()

func _on_death() -> void:
	print("[Personagem] ", character_name, " foi derrotado! Penalidade de XP aplicada.")
