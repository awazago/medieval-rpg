# res://client/ui/private_store_window.gd
# Janela de Configuração e Navegação de Lojas Pessoais (Private Store UI)
class_name PrivateStoreWindow
extends PanelContainer

signal store_started()
signal store_stopped()

@onready var tab_sell_btn: Button = $Margin/VBox/TabButtons/BtnTabSell
@onready var tab_buy_btn: Button = $Margin/VBox/TabButtons/BtnTabBuy
@onready var line_title: LineEdit = $Margin/VBox/ConfigSection/LineTitle
@onready var list_items: VBoxContainer = $Margin/VBox/ConfigSection/ScrollItems/ItemsList
@onready var btn_open_store: Button = $Margin/VBox/BtnOpenStore
@onready var btn_close_store: Button = $Margin/VBox/BtnCloseStore
@onready var status_label: Label = $Margin/VBox/StatusLabel
@onready var btn_close_win: Button = $Margin/VBox/BtnCloseWindow

var current_mode: int = 1 # 1 = Sell, 2 = Buy
var player_character: PlayerCharacter = null
var current_store_manager: PrivateStoreManager = null
var staging_items: Array[Dictionary] = []

# Referência a uma loja externa sendo navegada (quando clica em outro jogador)
var browsing_external_store: PrivateStoreManager = null

func _ready() -> void:
	add_to_group("private_store_window")
	visible = false
	
	if tab_sell_btn:
		tab_sell_btn.pressed.connect(_on_select_sell_mode)
	if tab_buy_btn:
		tab_buy_btn.pressed.connect(_on_select_buy_mode)
	if btn_open_store:
		btn_open_store.pressed.connect(_on_open_store_pressed)
	if btn_close_store:
		btn_close_store.pressed.connect(_on_close_store_pressed)
	if btn_close_win:
		btn_close_win.pressed.connect(close_window)

func open_for_player(player: PlayerCharacter, store_mgr: PrivateStoreManager) -> void:
	player_character = player
	current_store_manager = store_mgr
	browsing_external_store = null
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_refresh_ui_state()

func open_browse_store(client_player: PlayerCharacter, target_store: PrivateStoreManager) -> void:
	player_character = client_player
	browsing_external_store = target_store
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_external_store_view()

func close_window() -> void:
	visible = false
	browsing_external_store = null

func _on_select_sell_mode() -> void:
	current_mode = 1
	staging_items.clear()
	_refresh_ui_state()

func _on_select_buy_mode() -> void:
	current_mode = 2
	staging_items.clear()
	_refresh_ui_state()

func _refresh_ui_state() -> void:
	if not current_store_manager:
		return
		
	var is_active = current_store_manager.is_active
	if btn_open_store:
		btn_open_store.visible = not is_active
	if btn_close_store:
		btn_close_store.visible = is_active
		
	if is_active:
		if status_label:
			status_label.text = "🟢 Sua loja está aberta no chão de Giran!"
			status_label.modulate = Color(0.3, 1.0, 0.4)
		_display_active_store_items()
	else:
		if status_label:
			status_label.text = "Configure sua banca e selecione os itens:"
			status_label.modulate = Color(0.9, 0.9, 0.9)
		_build_staging_inventory_list()

func _build_staging_inventory_list() -> void:
	if not list_items or not player_character or not player_character.inventory:
		return
		
	for child in list_items.get_children():
		child.queue_free()
		
	var slots = player_character.inventory.slots
	for i in range(slots.size()):
		var slot = slots[i]
		if slot == null or slot["id"] == "adena":
			continue
			
		var item_id = slot["id"]
		var item_name = slot["data"].get("name", item_id)
		var item_count = slot["count"]
		var base_price = slot["data"].get("price", 100)
		
		var row = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = "%s (x%d)" % [item_name, item_count]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		
		var price_spin = SpinBox.new()
		price_spin.min_value = 1
		price_spin.max_value = 10000000
		price_spin.value = base_price
		price_spin.tooltip_text = "Preço por unidade (Adena)"
		row.add_child(price_spin)
		
		var add_btn = Button.new()
		add_btn.text = "Adicionar"
		add_btn.pressed.connect(_on_add_to_staging.bind(item_id, item_name, item_count, price_spin, slot["data"]))
		row.add_child(add_btn)
		
		list_items.add_child(row)

func _on_add_to_staging(item_id: String, item_name: String, max_count: int, price_spin: SpinBox, data: Dictionary) -> void:
	var price = int(price_spin.value)
	staging_items.append({
		"id": item_id,
		"name": item_name,
		"count": max_count,
		"price_per_unit": price,
		"data": data
	})
	if status_label:
		status_label.text = "Item adicionado: %s (%d 🪙 cada)" % [item_name, price]

func _on_open_store_pressed() -> void:
	if not current_store_manager or not player_character:
		return
		
	var title = line_title.text if line_title else "Loja de Giran"
	if title.strip_edges() == "":
		title = "Loja de Giran"
		
	if staging_items.is_empty():
		# Se não adicionou nada manualmente, adiciona o primeiro item válido do inventário como demonstração imediata
		for slot in player_character.inventory.slots:
			if slot != null and slot["id"] != "adena":
				staging_items.append({
					"id": slot["id"],
					"name": slot["data"].get("name", slot["id"]),
					"count": slot["count"],
					"price_per_unit": slot["data"].get("price", 100),
					"data": slot["data"]
				})
				break
				
	var res: Dictionary
	if current_mode == 1:
		res = current_store_manager.open_sell_store(player_character, title, staging_items)
	else:
		res = current_store_manager.open_buy_store(player_character, title, staging_items)
		
	if res.get("success", false):
		_refresh_ui_state()
		store_started.emit()
	else:
		if status_label:
			status_label.text = "❌ " + res.get("message", "Erro ao abrir loja.")
			status_label.modulate = Color(1.0, 0.3, 0.3)

func _on_close_store_pressed() -> void:
	if current_store_manager:
		current_store_manager.close_store()
		_refresh_ui_state()
		store_stopped.emit()

func _display_active_store_items() -> void:
	if not list_items or not current_store_manager:
		return
	for child in list_items.get_children():
		child.queue_free()
		
	var items = current_store_manager.items_for_sale if current_store_manager.store_type == 1 else current_store_manager.items_for_buy
	for entry in items:
		var lbl = Label.new()
		lbl.text = "📦 %s x%d - %d 🪙 cada" % [entry["name"], entry["count"], entry["price_per_unit"]]
		list_items.add_child(lbl)

## Visualização de Lojas de Terceiros (Comprar/Vender diretamente na banca de outro jogador ou NPC)
func _build_external_store_view() -> void:
	if not list_items or not browsing_external_store:
		return
	for child in list_items.get_children():
		child.queue_free()
		
	if btn_open_store:
		btn_open_store.visible = false
	if btn_close_store:
		btn_close_store.visible = false
		
	var is_sell_type = browsing_external_store.store_type == 1
	if status_label:
		status_label.text = "Banca de: %s" % browsing_external_store.store_title
		status_label.modulate = Color(1.0, 0.85, 0.2) if is_sell_type else Color(0.3, 0.85, 1.0)
		
	var items = browsing_external_store.items_for_sale if is_sell_type else browsing_external_store.items_for_buy
	for entry in items:
		var row = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = "%s (Qtd: %d) - %d 🪙" % [entry["name"], entry["count"], entry["price_per_unit"]]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		
		var action_btn = Button.new()
		if is_sell_type:
			action_btn.text = "Comprar"
			action_btn.pressed.connect(_on_client_buy_item.bind(entry["id"], 1))
		else:
			action_btn.text = "Vender"
			action_btn.pressed.connect(_on_client_sell_item.bind(entry["id"], 1))
		row.add_child(action_btn)
		
		list_items.add_child(row)

func _on_client_buy_item(item_id: String, count: int) -> void:
	if browsing_external_store and player_character:
		var res = browsing_external_store.execute_client_purchase(player_character, item_id, count)
		if status_label:
			status_label.text = res.get("message", "")
		_build_external_store_view()

func _on_client_sell_item(item_id: String, count: int) -> void:
	if browsing_external_store and player_character:
		var res = browsing_external_store.execute_client_sale(player_character, item_id, count)
		if status_label:
			status_label.text = res.get("message", "")
		_build_external_store_view()
