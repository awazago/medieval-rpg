# res://client/scripts/inventory_manager.gd
# Gerenciador de Inventário e Regras de Carga (Lineage II Weight System)
class_name InventoryManager
extends Node

signal inventory_changed()
signal weight_changed(current_weight: int, max_weight: int, percentage: float, penalty_tier: int)
signal item_equipped(item_data: Dictionary, slot_type: String)
signal item_used(item_data: Dictionary)

const MAX_SLOTS: int = 24
const BASE_MAX_WEIGHT: int = 68000 # Unidades de peso clássicas de Lineage II

# Slots do inventário: Array de dicionários ou null
# Estrutura: {"id": String, "count": int, "equipped": bool, "data": Dictionary}
var slots: Array = []
var current_weight: int = 0
var max_weight: int = BASE_MAX_WEIGHT

# Penalidades de peso (0: Normal, 1: 50% Sem Regen, 2: 67% -20% Speed, 3: 80% Sobrecarregado)
var current_penalty_tier: int = 0

var equipped_weapon: Dictionary = {}
var equipped_chest: Dictionary = {}

func _ready() -> void:
	slots.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		slots[i] = null
		
	# Adiciona itens iniciais para teste do aventureiro
	_setup_starter_items()

func setup_weight_limit(con_stat: int) -> void:
	# No Lineage II, a Constituição (CON) dita o multiplicador de carga
	var multiplier = 1.0 + ((con_stat - 30) * 0.035)
	max_weight = int(round(BASE_MAX_WEIGHT * multiplier))
	_recalculate_weight()

func _setup_starter_items() -> void:
	add_item("short_sword", 1)
	add_item("leather_tunic", 1)
	add_item("soulshot_none", 150)
	add_item("lesser_healing_potion", 5)

func add_item(item_id: String, count: int = 1) -> bool:
	var item_info = GameData.get_item(item_id) if GameData else {}
	if item_info.is_empty():
		push_warning("[Inventário] Item desconhecido: " + item_id)
		return false
		
	var is_stackable = item_info.get("type") == "consumable"
	
	# Se for acumulável (Soulshots, Poções, Adena), busca slot existente
	if is_stackable:
		for i in range(MAX_SLOTS):
			if slots[i] != null and slots[i]["id"] == item_id:
				slots[i]["count"] += count
				_recalculate_weight()
				inventory_changed.emit()
				return true
				
	# Busca primeiro slot vazio
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			slots[i] = {
				"id": item_id,
				"count": count,
				"equipped": false,
				"data": item_info
			}
			_recalculate_weight()
			inventory_changed.emit()
			return true
			
	print("[Inventário] Inventário cheio!")
	return false

func use_or_equip(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS or slots[slot_index] == null:
		return
		
	var entry = slots[slot_index]
	var item_data: Dictionary = entry["data"]
	var item_type = item_data.get("type", "")
	
	match item_type:
		"weapon":
			_toggle_equip_weapon(slot_index)
		"armor":
			_toggle_equip_armor(slot_index)
		"consumable":
			_consume_item(slot_index)
			
	inventory_changed.emit()

func _toggle_equip_weapon(slot_index: int) -> void:
	var entry = slots[slot_index]
	if entry["equipped"]:
		entry["equipped"] = false
		equipped_weapon = {}
		item_equipped.emit({}, "weapon")
	else:
		# Desequipa qualquer outra arma antes
		for s in slots:
			if s != null and s["data"].get("type") == "weapon":
				s["equipped"] = false
		entry["equipped"] = true
		equipped_weapon = entry["data"]
		item_equipped.emit(equipped_weapon, "weapon")

func _toggle_equip_armor(slot_index: int) -> void:
	var entry = slots[slot_index]
	if entry["equipped"]:
		entry["equipped"] = false
		equipped_chest = {}
		item_equipped.emit({}, "chest")
	else:
		for s in slots:
			if s != null and s["data"].get("type") == "armor":
				s["equipped"] = false
		entry["equipped"] = true
		equipped_chest = entry["data"]
		item_equipped.emit(equipped_chest, "chest")

func _consume_item(slot_index: int) -> void:
	var entry = slots[slot_index]
	item_used.emit(entry["data"])
	entry["count"] -= 1
	if entry["count"] <= 0:
		slots[slot_index] = null
	_recalculate_weight()

func has_item(item_id: String, min_count: int = 1) -> bool:
	var total = 0
	for s in slots:
		if s != null and s["id"] == item_id:
			total += s["count"]
			if total >= min_count:
				return true
	return false

func _recalculate_weight() -> void:
	current_weight = 0
	for s in slots:
		if s != null:
			var unit_weight = s["data"].get("weight", 10)
			current_weight += unit_weight * s["count"]
			
	var percentage = (float(current_weight) / float(max_weight)) * 100.0
	if percentage >= 80.0:
		current_penalty_tier = 3 # Sobrecarregado
	elif percentage >= 67.0:
		current_penalty_tier = 2 # -20% Move Speed
	elif percentage >= 50.0:
		current_penalty_tier = 1 # Sem Regen
	else:
		current_penalty_tier = 0 # Sem penalidade
		
	weight_changed.emit(current_weight, max_weight, percentage, current_penalty_tier)
