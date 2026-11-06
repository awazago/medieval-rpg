extends CharacterBody2D
class_name EnemyBase

@export var max_hp: int = 40
@export var move_speed: float = 65.0
@export var damage: int = 10
@export var xp_reward: int = 25
@export var gold_reward: int = 2
@export var attack_cooldown: float = 1.0

var current_hp: int = 40
var knockback: Vector2 = Vector2.ZERO
var can_attack: bool = true
var is_dead: bool = false
var target_player: Node2D = null

const FLOATING_TEXT_SCENE = preload("res://src/scenes/floating_text.tscn")
const LOOT_SCENE = preload("res://src/scenes/loot_pickup.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	add_to_group("enemies")
	current_hp = max_hp
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
		hp_bar.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Decay knockback
	if knockback.length() > 5.0:
		knockback = knockback.move_toward(Vector2.ZERO, delta * 900.0)
		velocity = knockback
		move_and_slide()
		return
		
	# Find player target
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]
			
	custom_ai_process(delta)

func custom_ai_process(_delta: float) -> void:
	# Virtual method for child classes (Slime, Skeleton, Boss)
	pass

func take_damage(amount: int, p_knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
		
	current_hp -= amount
	knockback = p_knockback
	
	AudioManager.play_sfx("hit_enemy", 0.15)
	
	# Show damage number
	spawn_damage_text(amount, Color(1.0, 0.9, 0.3))
	
	# Hit flash
	if sprite:
		sprite.modulate = Color(2.5, 0.4, 0.4)
		var t = create_tween()
		t.tween_property(sprite, "modulate", Color.WHITE, 0.12)
		
	# Update mini HP bar
	if hp_bar:
		hp_bar.visible = true
		hp_bar.value = current_hp
		
	if current_hp <= 0:
		die()

func spawn_damage_text(amount: int, color: Color) -> void:
	var ft = FLOATING_TEXT_SCENE.instantiate()
	ft.global_position = global_position + Vector2(randf_range(-6, 6), -16)
	get_parent().add_child(ft)
	ft.setup(str(amount), color)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	# Disable collision
	var col = get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)
		
	call_deferred("drop_loot")
	
	# Death squash & fade
	var t = create_tween()
	t.tween_property(sprite, "scale", Vector2(1.4, 0.3), 0.1)
	t.tween_property(sprite, "modulate:a", 0.0, 0.12)
	t.tween_callback(queue_free)

func drop_loot() -> void:
	# Gold coins
	if gold_reward > 0:
		var loot = LOOT_SCENE.instantiate()
		loot.setup(LootPickup.LootType.COIN, gold_reward)
		loot.global_position = global_position
		get_parent().add_child(loot)
		
	# XP
	if xp_reward > 0:
		var xp = LOOT_SCENE.instantiate()
		xp.setup(LootPickup.LootType.XP_ORB, xp_reward)
		loot_offset(xp, Vector2(randf_range(-12, 12), randf_range(-12, 12)))
		
	# Chance of HP potion
	if randf() < 0.25:
		var pot = LOOT_SCENE.instantiate()
		pot.setup(LootPickup.LootType.POTION_HP, 30)
		loot_offset(pot, Vector2(randf_range(-12, 12), randf_range(-12, 12)))

func loot_offset(item: Node2D, offset: Vector2) -> void:
	item.global_position = global_position + offset
	get_parent().add_child(item)

func attack_target(target: Node2D) -> void:
	if not can_attack or is_dead:
		return
	can_attack = false
	if target.has_method("take_damage"):
		var push = (target.global_position - global_position).normalized() * 120.0
		target.take_damage(damage, push)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
