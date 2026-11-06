# res://client/ui/shop_window.gd
# Janela de Comércio e Loja do Ferreiro Torvald (Compra e Venda por Adena)
class_name ShopWindow
extends PanelContainer

@onready var label_adena: Label = $Margin/VBox/Header/LabelAdena
@onready var items_container: VBoxContainer = $Margin/VBox/Scroll/ItemsList
@onready var btn_close: Button = $Margin/VBox/BtnClose

var player_character: PlayerCharacter = null

# Itens à venda na forja inicial
const SHOP_CATALOG = [
	"short_sword",
	"apprentice_staff",
	"hunting_bow",
	"bone_dagger",
	"leather_tunic",
	"iron_breastplate",
	"soulshot_none",
	"spiritshot_none",
	"lesser_healing_potion"
]

func _ready() -> void:
	add_to_group("shop_window")
	visible = false
	if btn_close:
		btn_close.pressed.connect(close_shop)

func open_shop(player: PlayerCharacter) -> void:
	player_character = player
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_catalog()
	_update_adena_display()

func close_shop() -> void:
	visible = false
	player_character = null

func _update_adena_display() -> void:
	if label_adena and player_character and player_character.inventory:
		var adena_count = _get_player_adena()
		label_adena.text = "Sua Adena: %d 🪙" % adena_count

func _get_player_adena() -> int:
	if not player_character or not player_character.inventory:
		return 0
	for slot in player_character.inventory.slots:
		if slot != null and slot["id"] == "adena":
			return slot["count"]
	return 1500 # Saldo inicial concedido para testes de comércio

func _get_game_data() -> Node:
	return get_node_or_null("/root/GameData")

func _build_catalog() -> void:
	for child in items_container.get_children():
		child.queue_free()
		
	var gd = _get_game_data()
	for item_id in SHOP_CATALOG:
		var item_data = gd.get_item(item_id) if gd else {}
		if item_data.is_empty():
			continue
			
		var row = HBoxContainer.new()
		
		var lbl_info = Label.new()
		lbl_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var price = item_data.get("price", 100)
		var item_name = item_data.get("name", item_id)
		lbl_info.text = "%s  (%d 🪙)" % [item_name, price]
		row.add_child(lbl_info)
		
		var btn_buy = Button.new()
		btn_buy.text = "Comprar"
		btn_buy.pressed.connect(_on_buy_clicked.bind(item_id, price))
		row.add_child(btn_buy)
		
		items_container.add_child(row)

func _on_buy_clicked(item_id: String, price: int) -> void:
	if not player_character or not player_character.inventory:
		return
		
	var success = player_character.inventory.add_item(item_id, 1)
	if success:
		var hud = get_tree().get_first_node_in_group("hud")
		var gd = _get_game_data()
		var item_data = gd.get_item(item_id) if gd else {}
		var item_name = item_data.get("name", item_id)
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("🪙 Você comprou [color=gold]" + item_name + "[/color] por " + str(price) + " Adena!")
		_update_adena_display()
	else:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_system_message"):
			hud.add_system_message("[color=red]Inventário cheio! Não foi possível comprar.[/color]")
