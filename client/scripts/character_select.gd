# res://client/scripts/character_select.gd
# Tela de Criação e Seleção das 5 Raças Clássicas de Aethelgard
class_name CharacterSelect
extends Control

signal character_created(char_name: String, race_id: String, archetype: String)

@onready var input_name: LineEdit = $Panel/VBox/InputName
@onready var label_race_name: Label = $PanelStats/VBox/LabelRaceTitle
@onready var label_race_desc: Label = $PanelStats/VBox/LabelRaceDesc

@onready var bar_str: ProgressBar = $PanelStats/VBox/StatsGrid/BarSTR
@onready var bar_dex: ProgressBar = $PanelStats/VBox/StatsGrid/BarDEX
@onready var bar_con: ProgressBar = $PanelStats/VBox/StatsGrid/BarCON
@onready var bar_int: ProgressBar = $PanelStats/VBox/StatsGrid/BarINT
@onready var bar_wit: ProgressBar = $PanelStats/VBox/StatsGrid/BarWIT
@onready var bar_men: ProgressBar = $PanelStats/VBox/StatsGrid/BarMEN

@onready var label_str: Label = $PanelStats/VBox/StatsGrid/LabelSTR
@onready var label_dex: Label = $PanelStats/VBox/StatsGrid/LabelDEX
@onready var label_con: Label = $PanelStats/VBox/StatsGrid/LabelCON
@onready var label_int: Label = $PanelStats/VBox/StatsGrid/LabelINT
@onready var label_wit: Label = $PanelStats/VBox/StatsGrid/LabelWIT
@onready var label_men: Label = $PanelStats/VBox/StatsGrid/LabelMEN

@onready var label_derived: Label = $PanelStats/VBox/LabelDerivedStats
@onready var preview_model: Node3D = $SubViewportContainer/SubViewport/PreviewCharacter/VisualMesh
@onready var btn_enter_world: Button = $Panel/VBox/BtnEnterWorld

var selected_race: String = "human"
var selected_archetype: String = "warrior"

func _ready() -> void:
	# Seleção inicial padrão
	select_race("human")
	if btn_enter_world:
		btn_enter_world.pressed.connect(_on_enter_world_pressed)

func select_race(race_key: String) -> void:
	selected_race = race_key
	var race_data = GameData.get_race(race_key) if GameData else {}
	if race_data.is_empty():
		return
		
	var stats = race_data.get("base_stats", {})
	var r_name = race_data.get("name", "Raça")
	var r_desc = race_data.get("description", "")
	
	if label_race_name:
		label_race_name.text = r_name
	if label_race_desc:
		label_race_desc.text = r_desc
		
	# Atualiza Barras e Rótulos dos Atributos
	_set_stat(bar_str, label_str, "STR", stats.get("str", 30))
	_set_stat(bar_dex, label_dex, "DEX", stats.get("dex", 30))
	_set_stat(bar_con, label_con, "CON", stats.get("con", 30))
	_set_stat(bar_int, label_int, "INT", stats.get("int", 20))
	_set_stat(bar_wit, label_wit, "WIT", stats.get("wit", 10))
	_set_stat(bar_men, label_men, "MEN", stats.get("men", 25))
	
	if label_derived:
		var hp = race_data.get("base_hp", 100)
		var mp = race_data.get("base_mp", 80)
		var spd = race_data.get("base_speed", 125)
		label_derived.text = "HP Base: %d  |  MP Base: %d  |  Velocidade: %d" % [hp, mp, spd]
		
	# Atualiza Silhueta 3D no Preview
	_update_preview_silhouette(race_key)

func _set_stat(bar: ProgressBar, lbl: Label, stat_name: String, val: int) -> void:
	if bar:
		bar.value = val
	if lbl:
		lbl.text = stat_name + ": " + str(val)

func _update_preview_silhouette(race_key: String) -> void:
	if not preview_model:
		return
		
	var rig = preview_model.get_node_or_null("HumanoidCharacterRig")
	if rig and rig.has_method("set_character_model"):
		match race_key:
			"human":
				rig.set_character_model("knight")
			"light_elf":
				rig.set_character_model("mage")
			"dark_elf":
				rig.set_character_model("rogue")
			"orc":
				rig.set_character_model("barbarian")
			"dwarf":
				rig.set_character_model("knight")
			_:
				rig.set_character_model("knight")
		
	match race_key:
		"orc":
			preview_model.scale = Vector3(1.3, 1.15, 1.3)
		"light_elf":
			preview_model.scale = Vector3(0.9, 1.12, 0.9)
		"dark_elf":
			preview_model.scale = Vector3(0.92, 1.08, 0.92)
		"dwarf":
			preview_model.scale = Vector3(1.22, 0.78, 1.22)
		_: # Humano
			preview_model.scale = Vector3(1.0, 1.0, 1.0)

func _on_enter_world_pressed() -> void:
	var final_name = input_name.text.strip_edges() if input_name and input_name.text.strip_edges() != "" else "Valente"
	print("[Criação] Personagem criado: ", final_name, " | Raça: ", selected_race)
	
	# Transição para o mundo de jogo
	var main_scene = load("res://client/scenes/main_game.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	
	# Configura dados raciais no jogador
	var player = main_scene.get_node_or_null("Player")
	if player and player.has_method("apply_race_data"):
		player.character_name = final_name
		player.apply_race_data(selected_race)
		
	# Libera a tela de criação
	queue_free()
