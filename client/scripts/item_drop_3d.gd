# res://client/scripts/item_drop_3d.gd
# Entidade de Item Caído no Chão com Efeito de Brilho e Coleta (Estilo Lineage II)
class_name ItemDrop3D
extends Area3D

@export var item_id: String = "soulshot_none"
@export var count: int = 10
@export var item_name: String = "Item"

var rotation_speed: float = 2.5
var bob_speed: float = 3.0
var bob_height: float = 0.15
var initial_y: float = 0.0

@onready var label_prompt: Label3D = $Label3D
@onready var visual_mesh: Node3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("loot_drops")
	initial_y = position.y
	_update_label()
	
	# Conecta entrada de corpo
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label_prompt:
		label_prompt.visible = false

func _get_game_data() -> Node:
	return get_node_or_null("/root/GameData")

func init_drop(id: String, amount: int, custom_name: String = "") -> void:
	item_id = id
	count = amount
	if custom_name != "":
		item_name = custom_name
	else:
		var gd = _get_game_data()
		var item_data = gd.get_item(id) if gd else {}
		item_name = item_data.get("name", id)

func _update_label() -> void:
	if label_prompt:
		label_prompt.text = "[E] Pegar: " + item_name
		if count > 1:
			label_prompt.text += " (" + str(count) + ")"

func _process(delta: float) -> void:
	# Rotação contínua e flutuação suave do loot
	if visual_mesh:
		visual_mesh.rotate_y(rotation_speed * delta)
		visual_mesh.position.y = sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_height

func _unhandled_input(event: InputEvent) -> void:
	# Coleta via tecla 'E'
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		var overlapping_bodies = get_overlapping_bodies()
		for body in overlapping_bodies:
			if body is PlayerCharacter:
				_collect(body)
				break

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter and label_prompt:
		label_prompt.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is PlayerCharacter and label_prompt:
		label_prompt.visible = false

func _collect(player: PlayerCharacter) -> void:
	if player and player.inventory:
		var added = player.inventory.add_item(item_id, count)
		if added:
			var am = get_node_or_null("/root/AudioManager")
			if am:
				am.play_sfx("coins_pickup")
			var msg = "Você pegou: " + item_name
			if count > 1:
				msg += " (" + str(count) + ")"
			# Envia para o HUD
			var hud = get_tree().get_first_node_in_group("hud")
			if hud and hud.has_method("add_combat_log"):
				hud.add_combat_log(msg)
			queue_free()
