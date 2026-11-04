# res://server/monster_entity.gd
# Entidade de Monstro (Servidor Autoritativo / IA de Combate)
class_name MonsterEntity
extends CharacterBody3D

signal monster_died(monster: MonsterEntity)
signal health_changed(current: int, maximum: int)

@export var monster_id: String = "young_fox"
@export var monster_name: String = "Raposa Jovem"
@export var level: int = 1
@export var max_hp: int = 45
var current_hp: int = 45
@export var p_atk: float = 8.0
@export var p_def: float = 12.0
@export var is_aggressive: bool = false
@export var attack_range: float = 2.2
@export var aggro_radius: float = 12.0

enum State { IDLE, CHASE, ATTACK, RETURNING, DEAD }
var current_state: State = State.IDLE
var target_player: Node3D = null
var spawn_position: Vector3
var move_speed: float = 3.5

func _ready() -> void:
	add_to_group("monsters")
	spawn_position = global_position
	current_hp = max_hp
	
	# Carrega dados do JSON se disponível
	if GameData:
		var mob_data = GameData.get_monster(monster_id)
		if not mob_data.is_empty():
			monster_name = mob_data.get("name", monster_name)
			level = mob_data.get("level", level)
			max_hp = mob_data.get("hp", max_hp)
			current_hp = max_hp
			p_atk = mob_data.get("p_atk", p_atk)
			p_def = mob_data.get("p_def", p_def)
			is_aggressive = mob_data.get("aggro", is_aggressive)

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
		
	match current_state:
		State.IDLE:
			if is_aggressive and target_player == null:
				_check_for_players_in_range()
		State.CHASE:
			if is_instance_valid(target_player):
				var distance = global_position.distance_to(target_player.global_position)
				if distance <= attack_range:
					current_state = State.ATTACK
				else:
					var direction = (target_player.global_position - global_position).normalized()
					velocity.x = direction.x * move_speed
					velocity.z = direction.z * move_speed
					look_at(Vector3(target_player.global_position.x, global_position.y, target_player.global_position.z))
					move_and_slide()
			else:
				current_state = State.RETURNING
		State.ATTACK:
			# Loop de ataque ritmado
			if is_instance_valid(target_player):
				var distance = global_position.distance_to(target_player.global_position)
				if distance > attack_range:
					current_state = State.CHASE
			else:
				current_state = State.RETURNING

func _check_for_players_in_range() -> void:
	# Busca jogadores próximos no grupo
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player is Node3D and global_position.distance_to(player.global_position) <= aggro_radius:
			target_player = player
			current_state = State.CHASE
			break

func take_damage(damage_amount: int, attacker: Node3D = null) -> void:
	if current_state == State.DEAD:
		return
		
	current_hp = maxi(0, current_hp - damage_amount)
	health_changed.emit(current_hp, max_hp)
	
	# Revida ao atacante
	if attacker and is_instance_valid(attacker):
		target_player = attacker
		current_state = State.CHASE
		
	if current_hp <= 0:
		_die()

func _die() -> void:
	current_state = State.DEAD
	monster_died.emit(self)
	print("[Monstro] ", monster_name, " foi derrotado!")
	queue_free()
