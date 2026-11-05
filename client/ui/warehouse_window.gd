# res://client/ui/warehouse_window.gd
# Janela do Armazém Geral da Cidade (Depósito e Retirada para Alívio de Peso)
class_name WarehouseWindow
extends PanelContainer

@onready var container_inventory: VBoxContainer = $Margin/VBox/HBox/InvVBox/Scroll/InvList
@onready var container_vault: VBoxContainer = $Margin/VBox/HBox/VaultVBox/Scroll/VaultList
@onready var btn_close: Button = $Margin/VBox/BtnClose

var player_character: PlayerCharacter = null
# Armazenamento seguro de itens do jogador na cidade
static var deposited_vault_items: Array = []

func _ready() -> void:
	add_to_group("warehouse_window")
	visible = false
	if btn_close:
		btn_close.pressed.connect(close_warehouse)

func open_warehouse(player: PlayerCharacter) -> void:
	player_character = player
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	refresh_lists()

func close_warehouse() -> void:
	visible = false
	player_character = null

func refresh_lists() -> void:
	_build_inventory_list()
	_build_vault_list()

func _build_inventory_list() -> void:
	for child in container_inventory.get_children():
		child.queue_free()
		
	if not player_character or not player_character.inventory:
		return
		
	for i in range(InventoryManager.MAX_SLOTS):
		var slot = player_character.inventory.slots[i]
		if slot != null:
			var item_data = slot["data"]
			var row = HBoxContainer.new()
			
			var lbl = Label.new()
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var name_str = item_data.get("name", "Item")
			if slot["count"] > 1:
				name_str += " (" + str(slot["count"]) + ")"
			lbl.text = name_str
			row.add_child(lbl)
			
			var btn_deposit = Button.new()
			btn_deposit.text = "Guardar"
			btn_deposit.pressed.connect(_on_deposit_clicked.bind(i))
			row.add_child(btn_deposit)
			
			container_inventory.add_child(row)

func _build_vault_list() -> void:
	for child in container_vault.get_children():
		child.queue_free()
		
	for i in range(deposited_vault_items.size()):
		var entry = deposited_vault_items[i]
		var row = HBoxContainer.new()
		
		var lbl = Label.new()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var item_data = entry["data"]
		var name_str = item_data.get("name", "Item")
		if entry["count"] > 1:
			name_str += " (" + str(entry["count"]) + ")"
		lbl.text = name_str
		row.add_child(lbl)
		
		var btn_withdraw = Button.new()
		btn_withdraw.text = "Retirar"
		btn_withdraw.pressed.connect(_on_withdraw_clicked.bind(i))
		row.add_child(btn_withdraw)
		
		container_vault.add_child(row)

func _on_deposit_clicked(slot_index: int) -> void:
	if not player_character or not player_character.inventory:
		return
		
	var slot = player_character.inventory.slots[slot_index]
	if slot != null:
		deposited_vault_items.append({
			"id": slot["id"],
			"count": slot["count"],
			"data": slot["data"]
		})
		player_character.inventory.slots[slot_index] = null
		player_character.inventory._recalculate_weight()
		player_character.inventory.inventory_changed.emit()
		refresh_lists()
		
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("📦 Item guardado com segurança no Armazém Geral!")

func _on_withdraw_clicked(vault_index: int) -> void:
	if not player_character or not player_character.inventory:
		return
	if vault_index < 0 or vault_index >= deposited_vault_items.size():
		return
		
	var entry = deposited_vault_items[vault_index]
	var added = player_character.inventory.add_item(entry["id"], entry["count"])
	if added:
		deposited_vault_items.remove_at(vault_index)
		refresh_lists()
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("📦 Item retirado do Armazém para seu inventário.")
	else:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("[color=red]Inventário cheio! Não foi possível retirar.[/color]")
