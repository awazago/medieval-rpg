# res://client/ui/inventory_window.gd
# Janela Flutuante de Inventário (24 Slots, Barra de Peso e Ações)
class_name InventoryWindow
extends PanelContainer

@export var inventory_manager: InventoryManager

@onready var grid_container: GridContainer = $Margin/VBox/GridContainer
@onready var label_weight: Label = $Margin/VBox/WeightContainer/LabelWeight
@onready var bar_weight: ProgressBar = $Margin/VBox/WeightContainer/BarWeight
@onready var label_description: Label = $Margin/VBox/LabelDescription

var slot_buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	_create_slots()
	if inventory_manager:
		inventory_manager.inventory_changed.connect(refresh_ui)
		inventory_manager.weight_changed.connect(_on_weight_changed)
		refresh_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		toggle_window()

func toggle_window() -> void:
	visible = not visible
	if visible:
		refresh_ui()

func _create_slots() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	slot_buttons.clear()
	
	for i in range(InventoryManager.MAX_SLOTS):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.pressed.connect(_on_slot_clicked.bind(i))
		grid_container.add_child(btn)
		slot_buttons.append(btn)

func refresh_ui() -> void:
	if not inventory_manager or slot_buttons.is_empty():
		return
		
	for i in range(InventoryManager.MAX_SLOTS):
		var btn = slot_buttons[i]
		var entry = inventory_manager.slots[i]
		
		if entry != null:
			var item_data: Dictionary = entry["data"]
			var text = item_data.get("name", "Item")
			if entry["count"] > 1:
				text += "\n(" + str(entry["count"]) + ")"
			if entry.get("equipped", false):
				text = "[E] " + text
				btn.modulate = Color(1.0, 0.85, 0.3) # Dourado se equipado
			else:
				btn.modulate = Color.WHITE
				
			btn.text = text
		else:
			btn.text = ""
			btn.modulate = Color(0.6, 0.6, 0.6, 0.5)

func _on_slot_clicked(slot_index: int) -> void:
	if not inventory_manager:
		return
		
	var entry = inventory_manager.slots[slot_index]
	if entry != null:
		var item_data = entry["data"]
		var desc = item_data.get("name", "") + " (" + item_data.get("type", "") + ")"
		if item_data.has("p_atk"):
			desc += "\nP.Atk: " + str(item_data["p_atk"]) + " | M.Atk: " + str(item_data.get("m_atk", 0))
		if item_data.has("p_def"):
			desc += "\nP.Def: " + str(item_data["p_def"])
		label_description.text = desc
		
		# Ação de clique: usa ou equipa o item
		inventory_manager.use_or_equip(slot_index)
	else:
		label_description.text = "Slot vazio."

func _on_weight_changed(current: int, max_w: int, percentage: float, tier: int) -> void:
	if bar_weight and label_weight:
		bar_weight.max_value = max_w
		bar_weight.value = current
		label_weight.text = "Peso: %d / %d (%.1f%%)" % [current, max_w, percentage]
		
		match tier:
			0:
				bar_weight.modulate = Color.GREEN
			1:
				bar_weight.modulate = Color.YELLOW # Sem regen
			2:
				bar_weight.modulate = Color.ORANGE # -20% speed
			3:
				bar_weight.modulate = Color.RED    # Sobrecarregado
