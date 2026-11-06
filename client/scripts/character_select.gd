# res://client/scripts/character_select.gd
# Tela de Criação e Seleção das 5 Raças Clássicas e Classes de Aethelgard (Lineage II Style)
class_name CharacterSelect
extends Node3D

signal character_created(char_name: String, race_id: String, archetype: String)

var input_name: LineEdit = null
var label_race_name: Label = null
var label_race_desc: Label = null

var btn_warrior: Button = null
var btn_mage: Button = null

var bar_str: ProgressBar = null
var bar_dex: ProgressBar = null
var bar_con: ProgressBar = null
var bar_int: ProgressBar = null
var bar_wit: ProgressBar = null
var bar_men: ProgressBar = null

var label_str: Label = null
var label_dex: Label = null
var label_con: Label = null
var label_int: Label = null
var label_wit: Label = null
var label_men: Label = null

var label_derived: Label = null
var preview_model: Node3D = null
var btn_enter_world: Button = null

var selected_race: String = "human"
var selected_archetype: String = "warrior"

func _get_game_data() -> Node:
	return get_node_or_null("/root/GameData")

func _ready() -> void:
	print("[CharacterSelect] Inicializando tela de criação de personagem e classes...")
	
	input_name = find_child("InputName", true, false)
	label_race_name = find_child("LabelRaceTitle", true, false)
	label_race_desc = find_child("LabelRaceDesc", true, false)
	btn_warrior = find_child("BtnWarrior", true, false)
	btn_mage = find_child("BtnMage", true, false)
	bar_str = find_child("BarSTR", true, false)
	bar_dex = find_child("BarDEX", true, false)
	bar_con = find_child("BarCON", true, false)
	bar_int = find_child("BarINT", true, false)
	bar_wit = find_child("BarWIT", true, false)
	bar_men = find_child("BarMEN", true, false)
	label_str = find_child("LabelSTR", true, false)
	label_dex = find_child("LabelDEX", true, false)
	label_con = find_child("LabelCON", true, false)
	label_int = find_child("LabelINT", true, false)
	label_wit = find_child("LabelWIT", true, false)
	label_men = find_child("LabelMEN", true, false)
	label_derived = find_child("LabelDerivedStats", true, false)
	preview_model = find_child("VisualMesh", true, false)
	btn_enter_world = find_child("BtnEnterWorld", true, false)
	
	# 1. Conecta o botão de Despertar prioritariamente
	if btn_enter_world and not btn_enter_world.pressed.is_connected(_on_enter_world_pressed):
		btn_enter_world.pressed.connect(_on_enter_world_pressed)
		print("[CharacterSelect] Botão Despertar conectado com sucesso.")
		
	# 2. Conecta os botões de raça
	_connect_race_button("BtnHuman", "human")
	_connect_race_button("BtnLightElf", "light_elf")
	_connect_race_button("BtnDarkElf", "dark_elf")
	_connect_race_button("BtnOrc", "orc")
	_connect_race_button("BtnDwarf", "dwarf")

	# 3. Conecta os botões de classe / arquétipo
	if btn_warrior and not btn_warrior.pressed.is_connected(select_archetype):
		btn_warrior.pressed.connect(func(): select_archetype("warrior"))
	if btn_mage and not btn_mage.pressed.is_connected(select_archetype):
		btn_mage.pressed.connect(func(): select_archetype("mystic"))

	# 4. Seleção inicial padrão: Humano Guerreiro
	select_race("human")
	select_archetype("warrior")

func _connect_race_button(button_name: String, race_key: String) -> void:
	var btn = find_child(button_name, true, false)
	if btn and not btn.pressed.is_connected(select_race):
		btn.pressed.connect(func(): select_race(race_key))

func select_archetype(arch_key: String) -> void:
	selected_archetype = arch_key
	print("[CharacterSelect] Classe selecionada: ", arch_key)
	
	# Atualiza realce visual dos botões de classe
	if btn_warrior:
		btn_warrior.modulate = Color(1.3, 1.2, 0.4) if arch_key == "warrior" else Color(0.8, 0.8, 0.8)
	if btn_mage:
		btn_mage.modulate = Color(0.5, 1.2, 1.5) if arch_key == "mystic" else Color(0.8, 0.8, 0.8)
		
	# Re-atualiza a ficha e o modelo 3D com a nova classe
	_refresh_race_and_class_ui()
	_update_preview_silhouette(selected_race)

func select_race(race_key: String) -> void:
	selected_race = race_key
	print("[CharacterSelect] Raça selecionada: ", race_key)
	
	# Ajusta os rótulos de classe especiais para o Anão
	if selected_race == "dwarf":
		if btn_warrior: btn_warrior.text = "🔨 Artífice"
		if btn_mage: btn_mage.text = "⛏ Coletor"
	else:
		if btn_warrior: btn_warrior.text = "⚔ Guerreiro"
		if btn_mage: btn_mage.text = "🔮 Místico"
		
	_refresh_race_and_class_ui()
	_update_preview_silhouette(race_key)

func _refresh_race_and_class_ui() -> void:
	var gd = _get_game_data()
	var race_data: Dictionary = {}
	if gd and gd.has_method("get_race"):
		race_data = gd.get_race(selected_race)
	elif FileAccess.file_exists("res://data/races.json"):
		var f = FileAccess.open("res://data/races.json", FileAccess.READ)
		var j = JSON.new()
		if j.parse(f.get_as_text()) == OK and j.data is Dictionary:
			race_data = j.data.get(selected_race, {})
		
	var stats = race_data.get("base_stats", {})
	var r_name = race_data.get("name", "Raça")
	
	var is_mystic = (selected_archetype == "mystic" or selected_archetype == "mage")
	
	# Modificadores de Atributos Canônicos por Classe (Lineage II)
	var str_mod = -4 if is_mystic else +5
	var dex_mod = +2 if not is_mystic else 0
	var con_mod = -3 if is_mystic else +4
	var int_mod = +6 if is_mystic else -5
	var wit_mod = +4 if is_mystic else -3
	var men_mod = +3 if is_mystic else -2
	
	var final_str = maxi(10, stats.get("str", 30) + str_mod)
	var final_dex = maxi(10, stats.get("dex", 30) + dex_mod)
	var final_con = maxi(10, stats.get("con", 30) + con_mod)
	var final_int = maxi(10, stats.get("int", 20) + int_mod)
	var final_wit = maxi(10, stats.get("wit", 10) + wit_mod)
	var final_men = maxi(10, stats.get("men", 25) + men_mod)

	var class_title = "Guerreiro"
	if gd and gd.has_method("get_class_display_name"):
		class_title = gd.get_class_display_name(selected_race, selected_archetype)
	else:
		class_title = ("Místico " + r_name) if is_mystic else ("Guerreiro " + r_name)

	if label_race_name:
		label_race_name.text = class_title
		
	if label_race_desc:
		if is_mystic:
			label_race_desc.text = "Canalizador das forças arcanas e elementais de Aethelgard. Domina magias de ataque à distância (Wind Strike, Flame Bolt), escudos arcanos e regeneração mística."
		else:
			label_race_desc.text = "Especialista em combate corpo-a-corpo, armaduras pesadas e corte marcial. Destrói oponentes com Golpe Demolidor (Power Strike) e bloqueios resolutos de escudo."
		
	# Atualiza Barras e Rótulos dos Atributos
	_set_stat(bar_str, label_str, "STR", final_str)
	_set_stat(bar_dex, label_dex, "DEX", final_dex)
	_set_stat(bar_con, label_con, "CON", final_con)
	_set_stat(bar_int, label_int, "INT", final_int)
	_set_stat(bar_wit, label_wit, "WIT", final_wit)
	_set_stat(bar_men, label_men, "MEN", final_men)
	
	if label_derived:
		var base_h = race_data.get("base_hp", 120)
		var base_m = race_data.get("base_mp", 80)
		var spd = race_data.get("base_speed", 125)
		var final_hp = int(base_h * (0.85 if is_mystic else 1.25))
		var final_mp = int(base_m * (1.6 if is_mystic else 0.8))
		label_derived.text = "HP: %d  |  MP: %d  |  Velocidade: %d" % [final_hp, final_mp, spd]

func _set_stat(bar: ProgressBar, lbl: Label, stat_name: String, val: int) -> void:
	if bar:
		bar.value = val
	if lbl:
		lbl.text = stat_name + ": " + str(val)

func _update_preview_silhouette(race_key: String) -> void:
	if not preview_model:
		preview_model = find_child("VisualMesh", true, false)
	if not preview_model:
		return
		
	var rig = preview_model.get_node_or_null("HumanoidCharacterRig")
	if not rig:
		rig = preview_model.find_child("HumanoidCharacterRig", true, false)
	if rig and rig.has_method("set_character_model"):
		var is_mystic = (selected_archetype == "mystic" or selected_archetype == "mage")
		if is_mystic:
			rig.set_character_model("mage")
			if rig.has_method("equip_weapon"):
				rig.equip_weapon("staff")
		else:
			match race_key:
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
		
	match race_key:
		"orc":
			preview_model.scale = Vector3(1.15, 1.15, 1.15)
		"light_elf":
			preview_model.scale = Vector3(0.92, 1.05, 0.92)
		"dark_elf":
			preview_model.scale = Vector3(0.92, 1.02, 0.92)
		"dwarf":
			preview_model.scale = Vector3(1.12, 0.85, 1.12)
		_: # Humano
			preview_model.scale = Vector3(1.0, 1.0, 1.0)

func _on_enter_world_pressed() -> void:
	var final_name = input_name.text.strip_edges() if input_name and input_name.text.strip_edges() != "" else "Valente"
	print("[CharacterSelect] Despertar clicado! Herói: ", final_name, " | Raça: ", selected_race, " | Classe: ", selected_archetype)
	
	var gd = _get_game_data()
	if gd:
		gd.selected_character_name = final_name
		gd.selected_race_id = selected_race
		gd.selected_archetype = selected_archetype
		
	character_created.emit(final_name, selected_race, selected_archetype)
	
	# Transição limpa e oficial do Godot 4
	var err = get_tree().change_scene_to_file("res://client/scenes/main_game.tscn")
	if err != OK:
		push_error("[CharacterSelect] Erro na transição de cena: " + str(err))
