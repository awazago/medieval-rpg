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

func _get_game_data() -> Node:
	return get_node_or_null("/root/GameData")

func _ready() -> void:
	print("[CharacterSelect] Inicializando tela de criação de personagem...")
	
	# 1. Conecta o botão de Despertar prioritariamente
	if btn_enter_world and not btn_enter_world.pressed.is_connected(_on_enter_world_pressed):
		btn_enter_world.pressed.connect(_on_enter_world_pressed)
		print("[CharacterSelect] Botão Despertar conectado com sucesso.")
		
	# 2. Conecta explicitamente os botões de raça
	_connect_race_button("Panel/VBox/BtnHuman", "human")
	_connect_race_button("Panel/VBox/BtnLightElf", "light_elf")
	_connect_race_button("Panel/VBox/BtnDarkElf", "dark_elf")
	_connect_race_button("Panel/VBox/BtnOrc", "orc")
	_connect_race_button("Panel/VBox/BtnDwarf", "dwarf")

	# 3. Seleção inicial da raça padrão
	select_race("human")

func _connect_race_button(button_path: String, race_key: String) -> void:
	var btn = get_node_or_null(button_path)
	if btn and not btn.pressed.is_connected(select_race):
		btn.pressed.connect(func(): select_race(race_key))

func select_race(race_key: String) -> void:
	selected_race = race_key
	print("[CharacterSelect] Raça selecionada: ", race_key)
	
	var gd = _get_game_data()
	var race_data: Dictionary = {}
	if gd and gd.has_method("get_race"):
		race_data = gd.get_race(race_key)
	elif FileAccess.file_exists("res://data/races.json"):
		var f = FileAccess.open("res://data/races.json", FileAccess.READ)
		var j = JSON.new()
		if j.parse(f.get_as_text()) == OK and j.data is Dictionary:
			race_data = j.data.get(race_key, {})
		
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
		push_warning("[CharacterSelect] preview_model é nulo no viewport!")
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
			preview_model.scale = Vector3(1.22, 1.42, 1.22)
		"light_elf":
			preview_model.scale = Vector3(0.80, 1.38, 0.80)
		"dark_elf":
			preview_model.scale = Vector3(0.82, 1.35, 0.82)
		"dwarf":
			preview_model.scale = Vector3(1.15, 0.98, 1.15)
		_: # Humano
			preview_model.scale = Vector3(0.86, 1.32, 0.86)

func _on_enter_world_pressed() -> void:
	var final_name = input_name.text.strip_edges() if input_name and input_name.text.strip_edges() != "" else "Valente"
	print("[CharacterSelect] Botão Despertar clicado! Herói: ", final_name, " | Raça: ", selected_race)
	
	var gd = _get_game_data()
	if gd:
		gd.selected_character_name = final_name
		gd.selected_race_id = selected_race
		
	# Transição limpa e oficial do Godot 4
	var err = get_tree().change_scene_to_file("res://client/scenes/main_game.tscn")
	if err != OK:
		push_error("[CharacterSelect] Erro na transição de cena: " + str(err))
