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
			
	var lbl = get_node_or_null("LabelName")
	if not lbl:
		lbl = Label3D.new()
		lbl.name = "LabelName"
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lbl.font_size = 20
		lbl.position = Vector3(0, 1.9, 0)
		lbl.outline_render_priority = 1
		lbl.outline_size = 4
		lbl.outline_modulate = Color.BLACK
		add_child(lbl)
	var col = Color(1.0, 0.4, 0.2) if is_aggressive else Color(0.4, 1.0, 0.4)
	lbl.modulate = col
	lbl.text = "[Nv. %d] %s" % [level, monster_name]
	
	var anim = find_child("AnimationPlayer", true, false)
	if anim:
		if anim.has_animation("Idle"):
			anim.play("Idle")
		elif anim.has_animation("idle"):
			anim.play("idle")

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

const DROP_SCENE = preload("res://client/scenes/item_drop_3d.tscn")

func _die() -> void:
	current_state = State.DEAD
	monster_died.emit(self)
	print("[Monstro] ", monster_name, " foi derrotado!")
	_reward_player()
	_spawn_loot_drops()
	queue_free()

func _reward_player() -> void:
	if target_player and is_instance_valid(target_player) and target_player.has_method("add_exp_and_sp"):
		var mob_data = GameData.get_monster(monster_id) if GameData else {}
		var exp_reward = mob_data.get("exp_reward", 35)
		var sp_reward = mob_data.get("sp_reward", 5)
		target_player.add_exp_and_sp(exp_reward, sp_reward)
		
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_combat_log"):
			hud.add_combat_log("Você ganhou [color=yellow]" + str(exp_reward) + " XP[/color] e [color=aqua]" + str(sp_reward) + " SP[/color].")

func _spawn_loot_drops() -> void:
	if not GameData:
		return
	var mob_data = GameData.get_monster(monster_id)
	var drops: Array = mob_data.get("drops", [])
	
	for drop_entry in drops:
		var chance = drop_entry.get("chance_pct", 100)
		if randf() * 100.0 <= chance:
			var item_id = drop_entry.get("item_id", "soulshot_none")
			var min_c = drop_entry.get("min", 1)
			var max_c = drop_entry.get("max", 1)
			var count = randi_range(min_c, max_c)
			
			var drop_instance = DROP_SCENE.instantiate()
			drop_instance.init_drop(item_id, count)
			get_parent().add_child(drop_instance)
			
			# Espalha levemente o drop ao redor do corpo
			var offset = Vector3(randf_range(-0.8, 0.8), 0.3, randf_range(-0.8, 0.8))
			drop_instance.global_position = global_position + offset
