# res://client/ui/hotbar.gd
# Barra de Atalhos Inferior com Cooldowns e Acionamento (Estilo Lineage II)
class_name Hotbar
extends PanelContainer

signal skill_triggered(skill_id: String)
signal item_shortcut_triggered(item_id: String)

@onready var slots_container: HBoxContainer = $Margin/HBox
@onready var cast_bar_container: Control = $"../CastBarContainer"
@onready var cast_bar: ProgressBar = $"../CastBarContainer/VBox/CastBar"
@onready var cast_label: Label = $"../CastBarContainer/VBox/CastLabel"

const NUM_SLOTS: int = 8

# Definição dos atalhos padrão
var slot_configs: Array[Dictionary] = [
	{"type": "attack", "id": "basic_attack", "label": "Ataque", "key": "1"},
	{"type": "skill", "id": "power_strike", "label": "Golpe", "key": "2"},
	{"type": "skill", "id": "fire_arrow", "label": "Fogo", "key": "3"},
	{"type": "skill", "id": "lesser_heal", "label": "Cura", "key": "4"},
	{"type": "item", "id": "lesser_healing_potion", "label": "Poção", "key": "5"},
	{"type": "soulshot", "id": "toggle_shot", "label": "Soulshot", "key": "6"},
	{"type": "empty", "id": "", "label": "", "key": "7"},
	{"type": "empty", "id": "", "label": "", "key": "8"}
]

var slot_buttons: Array[Button] = []
var cooldowns: Dictionary = {} # id -> remaining_seconds

# Estado de Conjuração (Cast Bar)
var is_casting: bool = false
var current_casting_skill: Dictionary = {}
var cast_duration: float = 0.0
var cast_progress: float = 0.0

func _ready() -> void:
	if cast_bar_container:
		cast_bar_container.visible = false
	_build_hotbar()

func _build_hotbar() -> void:
	for child in slots_container.get_children():
		child.queue_free()
	slot_buttons.clear()
	
	for i in range(NUM_SLOTS):
		var cfg = slot_configs[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(54, 54)
		btn.text = "[" + cfg["key"] + "]\n" + cfg["label"]
		btn.pressed.connect(_on_slot_pressed.bind(i))
		slots_container.add_child(btn)
		slot_buttons.append(btn)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		for i in range(NUM_SLOTS):
			var key_str = slot_configs[i]["key"]
			if event.as_text() == key_str:
				_on_slot_pressed(i)
				break

func _process(delta: float) -> void:
	# Atualiza Cooldowns
	for skill_id in cooldowns.keys():
		cooldowns[skill_id] = maxf(0.0, cooldowns[skill_id] - delta)
		if cooldowns[skill_id] <= 0.0:
			cooldowns.erase(skill_id)
			_update_slot_visuals()
			
	# Atualiza Cast Bar
	if is_casting:
		cast_progress += delta
		if cast_bar:
			cast_bar.value = (cast_progress / cast_duration) * 100.0
		if cast_progress >= cast_duration:
			_complete_cast()

func _on_slot_pressed(index: int) -> void:
	if index < 0 or index >= NUM_SLOTS:
		return
	var cfg = slot_configs[index]
	var action_type = cfg["type"]
	var action_id = cfg["id"]
	
	if cooldowns.has(action_id):
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("Habilidade em recarga (%.1fs restantes)." % cooldowns[action_id])
		return
		
	match action_type:
		"attack":
			# Dispara o ataque básico padrão
			var main = get_tree().current_scene
			if main and main.has_method("_attempt_player_attack"):
				main._attempt_player_attack()
		"skill":
			start_casting_skill(action_id)
		"item":
			item_shortcut_triggered.emit(action_id)
		"soulshot":
			var player = get_tree().get_first_node_in_group("players")
			if player and player.has_method("toggle_soulshots"):
				player.toggle_soulshots()

func start_casting_skill(skill_id: String) -> void:
	if is_casting:
		return
		
	var skill_data = GameData.get_skill(skill_id) if GameData else {}
	if skill_data.is_empty():
		return
		
	var cast_time = skill_data.get("cast_time_sec", 1.0)
	is_casting = true
	current_casting_skill = skill_data
	cast_duration = cast_time
	cast_progress = 0.0
	
	if cast_bar_container and cast_label and cast_bar:
		cast_bar_container.visible = true
		cast_label.text = "Conjurando: " + skill_data.get("name", "Habilidade")
		cast_bar.value = 0.0

func _complete_cast() -> void:
	is_casting = false
	if cast_bar_container:
		cast_bar_container.visible = false
		
	var skill_id = current_casting_skill.get("id", "")
	var cd = current_casting_skill.get("cooldown_sec", 3.0)
	cooldowns[skill_id] = cd
	
	skill_triggered.emit(skill_id)
	_update_slot_visuals()

func cancel_cast() -> void:
	if is_casting:
		is_casting = false
		if cast_bar_container:
			cast_bar_container.visible = false
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("[color=red]Conjuração Interrompida![/color]")

func _update_slot_visuals() -> void:
	for i in range(NUM_SLOTS):
		var cfg = slot_configs[i]
		var btn = slot_buttons[i]
		if cooldowns.has(cfg["id"]):
			btn.modulate = Color(0.5, 0.5, 0.5, 0.8)
		else:
			btn.modulate = Color.WHITE
