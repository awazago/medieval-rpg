# res://server/boss_valthor.gd
# IA e Mecânicas de Combate do Raid Boss Valthor, o Cavaleiro Caído (Nv. 20)
class_name BossValthor
extends MonsterEntity

@export var is_raid_boss: bool = true
var stomp_timer: float = 0.0
const STOMP_COOLDOWN: float = 12.0
const STOMP_RADIUS: float = 8.0
const STOMP_DAMAGE: int = 90

@onready var aura_light: OmniLight3D = $VisualMesh/AuraLight
@onready var sword_mesh: CSGBox3D = $VisualMesh/Greatsword

func _ready() -> void:
	super._ready()
	monster_id = "fallen_knight_valthor"
	monster_name = "Valthor, o Cavaleiro Caído"
	level = 20
	max_hp = 4800
	current_hp = max_hp
	p_atk = 120.0
	p_def = 95.0
	is_aggressive = true
	aggro_radius = 18.0
	attack_range = 3.2
	move_speed = 4.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if current_state == State.ATTACK or current_state == State.CHASE:
		stomp_timer += delta
		if stomp_timer >= STOMP_COOLDOWN:
			stomp_timer = 0.0
			_execute_earthquake_stomp()

## Habilidade Especial: Pisão Terremoto em Área (AoE)
func _execute_earthquake_stomp() -> void:
	if current_state == State.DEAD:
		return
		
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("add_system_message"):
		hud.add_system_message("[color=red]⚔️ [ALERTA DE CHEFE] Valthor desfere PISÃO TERREMOTO! Onda de choque devastadora![/color]")
		
	# Pulso de luz carmesim na aura
	if aura_light:
		aura_light.light_energy = 8.0
		var tween = create_tween()
		tween.tween_property(aura_light, "light_energy", 3.0, 1.2)
		
	# Atinge todos os jogadores próximos
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p is Node3D and global_position.distance_to(p.global_position) <= STOMP_RADIUS:
			if p.has_method("take_damage"):
				p.take_damage(STOMP_DAMAGE, true)
				print("[Boss Valthor] Pisão Terremoto atingiu ", p.name, " causando ", STOMP_DAMAGE, " de dano!")
