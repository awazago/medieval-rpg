# res://client/scripts/player_character.gd
# Controlador de Personagem Jogável (Linha de herança Lineage II)
class_name PlayerCharacter
extends CharacterBody3D

signal stats_updated(hp: int, max_hp: int, mp: int, max_mp: int, cp: int, max_cp: int)
signal target_changed(new_target: Node3D)
signal soulshot_toggled(active: bool)

@export_category("Identidade")
@export var character_name: String = "Guerreiro"
@export var race_id: String = "human"
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

var base_walk_speed: float = 5.0
var base_p_atk: float = 24.0
var base_p_def: float = 20.0
var base_m_atk: float = 12.0
var base_m_def: float = 15.0

var p_atk: float = 24.0
var p_def: float = 20.0
var m_atk: float = 12.0
var m_def: float = 15.0

var soulshots_enabled: bool = false
var selected_target: Node3D = null

@onready var visual_mesh: Node3D = $VisualMesh
@onready var camera_pivot: SpringArm3D = $CameraPivot
@onready var inventory: InventoryManager = $InventoryManager

func _ready() -> void:
	current_hp = max_hp
	current_mp = max_mp
	current_cp = max_cp
	stats_updated.emit(current_hp, max_hp, current_mp, max_mp, current_cp, max_cp)
	
	if inventory:
		inventory.setup_weight_limit(43) # Constituição base humana
		inventory.item_equipped.connect(_on_item_equipped)
		inventory.item_used.connect(_on_item_used)
		inventory.weight_changed.connect(_on_weight_penalty_changed)

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
	elif slot_type == "chest":
		if not item_data.is_empty():
			p_def = base_p_def + item_data.get("p_def", 0)
			print("[Personagem] Armadura equipada: ", item_data.get("name"), " | P.Def: ", p_def)
		else:
			p_def = base_p_def
			print("[Personagem] Armadura desequipada. P.Def restaurado: ", p_def)

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

func _unhandled_input(event: InputEvent) -> void:
	# Ativação rápida de Soulshots (Auto-Shot)
	if event is InputEventKey and event.is_action_pressed("ui_focus_next"):
		_cycle_target()
		
	# Tecla de Atalho para ligar/desligar Soulshots
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		toggle_soulshots()

func toggle_soulshots() -> void:
	soulshots_enabled = not soulshots_enabled
	soulshot_toggled.emit(soulshots_enabled)
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
