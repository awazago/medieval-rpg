# res://client/scripts/npc_character.gd
# NPC Interativo de Vila / Missão (Estilo Lineage II)
class_name NPCCharacter
extends CharacterBody3D

signal dialogue_requested(npc: NPCCharacter)

@export var npc_id: String = "sentinel_marcus"
@export var npc_name: String = "Sentinela Marcus"
@export var npc_title: String = "<Guarda da Vila de Highstone>"

@export_multiline var greeting_text: String = "Saudações, recruta. A Ilha do Alvorecer costumava ser um refúgio sereno, mas as feras selvagens e os mortos inquietos nas criptas antigas estão ameaçando os camponeses. O que o traz até aqui?"

var available_quests: Array[String] = ["quest_first_steps"]

@onready var label_name: Label3D = $LabelName
@onready var interaction_area: Area3D = $InteractionArea

var player_in_range: PlayerCharacter = null

func _ready() -> void:
	add_to_group("npcs")
	if label_name:
		label_name.text = npc_name + "\n" + npc_title

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		player_in_range = body
		# Notifica HUD sobre tecla de interação
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("Pressione [F] para falar com " + npc_name + ".")

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body == player_in_range:
		player_in_range = null
		# Fecha diálogo se afastar
		var dialog_win = get_tree().get_first_node_in_group("dialog_window")
		if dialog_win and dialog_win.has_method("close_dialogue"):
			dialog_win.close_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if player_in_range != null:
			interact(player_in_range)

func interact(_player: PlayerCharacter) -> void:
	var dialog_win = get_tree().get_first_node_in_group("dialog_window")
	if dialog_win and dialog_win.has_method("open_dialogue"):
		dialog_win.open_dialogue(self)
