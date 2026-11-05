# res://client/scripts/economy/private_store_manager.gd
# Gerenciador de Lojas Pessoais dos Jogadores (Lineage II Canonical Private Store)
class_name PrivateStoreManager
extends Node

enum StoreType { NONE = 0, SELL = 1, BUY = 2 }

signal store_opened(store_type: int, title: String)
signal store_closed()
signal transaction_completed(type: String, item_id: String, count: int, price: int)

var store_type: int = StoreType.NONE
var store_title: String = ""
var is_active: bool = false
var owner_player: Node = null

# Itens ofertados na loja: cada item = {"id": String, "name": String, "count": int, "price_per_unit": int, "data": Dictionary}
var items_for_sale: Array[Dictionary] = []
var items_for_buy: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("private_store_manager")

## Abre uma Loja de Venda (Private Store - Sell)
func open_sell_store(owner: Node, title: String, items: Array) -> Dictionary:
	if is_active:
		return {"success": false, "message": "Você já possui uma loja aberta."}
	if title.strip_edges() == "":
		return {"success": false, "message": "O título da loja não pode ser vazio."}
	if items.is_empty():
		return {"success": false, "message": "Selecione ao menos um item para colocar à venda."}
		
	owner_player = owner
	store_type = StoreType.SELL
	store_title = title
	items_for_sale.clear()
	
	for entry in items:
		items_for_sale.append({
			"id": entry["id"],
			"name": entry.get("name", entry["id"]),
			"count": int(entry["count"]),
			"price_per_unit": int(entry["price_per_unit"]),
			"data": entry.get("data", {})
		})
		
	is_active = true
	
	# Coloca o personagem na pose sentada canônica de Lineage II
	if owner_player and owner_player.has_method("start_sitting_shop"):
		owner_player.start_sitting_shop(store_type, store_title)
		
	store_opened.emit(store_type, store_title)
	return {"success": true, "message": "Loja de venda aberta com sucesso!"}

## Abre uma Loja de Compra (Private Store - Buy)
func open_buy_store(owner: Node, title: String, items: Array) -> Dictionary:
	if is_active:
		return {"success": false, "message": "Você já possui uma loja aberta."}
	if title.strip_edges() == "":
		return {"success": false, "message": "O título da loja não pode ser vazio."}
	if items.is_empty():
		return {"success": false, "message": "Selecione ao menos um item para encomendar compra."}
		
	# Calcula se o dono tem Adena suficiente para cobrir os pedidos de compra
	var total_required_funds = 0
	for entry in items:
		total_required_funds += int(entry["count"]) * int(entry["price_per_unit"])
		
	var available_adena = _get_character_adena(owner)
	if available_adena < total_required_funds:
		return {
			"success": false, 
			"message": "Adena insuficiente para cobrir as encomendas (Necessário: %d 🪙, Você tem: %d 🪙)." % [total_required_funds, available_adena]
		}
		
	owner_player = owner
	store_type = StoreType.BUY
	store_title = title
	items_for_buy.clear()
	
	for entry in items:
		items_for_buy.append({
			"id": entry["id"],
			"name": entry.get("name", entry["id"]),
			"count": int(entry["count"]),
			"price_per_unit": int(entry["price_per_unit"]),
			"data": entry.get("data", {})
		})
		
	is_active = true
	
	if owner_player and owner_player.has_method("start_sitting_shop"):
		owner_player.start_sitting_shop(store_type, store_title)
		
	store_opened.emit(store_type, store_title)
	return {"success": true, "message": "Loja de compra aberta com sucesso!"}

## Fecha a loja pessoal e levanta o jogador
func close_store() -> void:
	if not is_active:
		return
		
	is_active = false
	store_type = StoreType.NONE
	store_title = ""
	items_for_sale.clear()
	items_for_buy.clear()
	
	if owner_player and owner_player.has_method("stop_sitting_shop"):
		owner_player.stop_sitting_shop()
		
	owner_player = null
	store_closed.emit()

## Executa a compra de um item ofertado na loja por um cliente transeunte
func execute_client_purchase(buyer: Node, item_id: String, count: int) -> Dictionary:
	if not is_active or store_type != StoreType.SELL:
		return {"success": false, "message": "Esta loja não está disponível para compras no momento."}
		
	var target_entry = null
	var entry_idx = -1
	for i in range(items_for_sale.size()):
		if items_for_sale[i]["id"] == item_id:
			target_entry = items_for_sale[i]
			entry_idx = i
			break
			
	if target_entry == null:
		return {"success": false, "message": "Item não encontrado no catálogo da loja."}
		
	if count <= 0 or count > target_entry["count"]:
		return {"success": false, "message": "Quantidade inválida ou superior ao estoque disponível."}
		
	var total_cost = count * target_entry["price_per_unit"]
	var buyer_adena = _get_character_adena(buyer)
	if buyer_adena < total_cost:
		return {"success": false, "message": "Você não tem Adena suficiente (%d 🪙 necessária)." % total_cost}
		
	# Transferência de Adena
	_deduct_character_adena(buyer, total_cost)
	_add_character_adena(owner_player, total_cost)
	
	# Transferência do Item
	var item_data = target_entry.get("data", {})
	if buyer and buyer.get("inventory"):
		buyer.inventory.add_item(item_id, count, item_data)
		
	target_entry["count"] -= count
	if target_entry["count"] <= 0:
		items_for_sale.remove_at(entry_idx)
		
	transaction_completed.emit("sell", item_id, count, total_cost)
	
	# Se esgotaram todos os itens à venda, fecha a loja
	if items_for_sale.is_empty():
		close_store()
		
	return {
		"success": true, 
		"message": "Comprou %d x %s por %d 🪙!" % [count, target_entry["name"], total_cost],
		"total_cost": total_cost
	}

## Executa a venda de um item do cliente para o estoque da loja compradora
func execute_client_sale(seller: Node, item_id: String, count: int) -> Dictionary:
	if not is_active or store_type != StoreType.BUY:
		return {"success": false, "message": "Esta loja não está comprando este item no momento."}
		
	var target_entry = null
	var entry_idx = -1
	for i in range(items_for_buy.size()):
		if items_for_buy[i]["id"] == item_id:
			target_entry = items_for_buy[i]
			entry_idx = i
			break
			
	if target_entry == null:
		return {"success": false, "message": "O comprador não tem interesse neste item."}
		
	if count <= 0 or count > target_entry["count"]:
		return {"success": false, "message": "Quantidade maior do que a encomenda da loja."}
		
	var total_payout = count * target_entry["price_per_unit"]
	var owner_funds = _get_character_adena(owner_player)
	if owner_funds < total_payout:
		return {"success": false, "message": "O comprador não tem mais fundos suficientes para pagar."}
		
	# Verifica se o vendedor realmente tem os itens no inventário
	if not _has_character_items(seller, item_id, count):
		return {"success": false, "message": "Você não possui a quantidade deste item no inventário."}
		
	# Executa transação
	_deduct_character_items(seller, item_id, count)
	_deduct_character_adena(owner_player, total_payout)
	_add_character_adena(seller, total_payout)
	
	if owner_player and owner_player.get("inventory"):
		owner_player.inventory.add_item(item_id, count, target_entry.get("data", {}))
		
	target_entry["count"] -= count
	if target_entry["count"] <= 0:
		items_for_buy.remove_at(entry_idx)
		
	transaction_completed.emit("buy", item_id, count, total_payout)
	
	if items_for_buy.is_empty():
		close_store()
		
	return {
		"success": true,
		"message": "Vendeu %d x %s e recebeu %d 🪙!" % [count, target_entry["name"], total_payout],
		"total_payout": total_payout
	}

# --- Helpers de Inventário e Adena ---
func _get_character_adena(character: Node) -> int:
	if not character:
		return 500000 # Fallback para bots/dummies
	var inv = character.get("inventory")
	if not inv:
		return 500000
	for slot in inv.slots:
		if slot != null and slot["id"] == "adena":
			return slot["count"]
	return 0

func _add_character_adena(character: Node, amount: int) -> void:
	if not character:
		return
	var inv = character.get("inventory")
	if inv:
		inv.add_item("adena", amount, {"name": "Adena", "type": "currency", "weight": 0})

func _deduct_character_adena(character: Node, amount: int) -> void:
	if not character:
		return
	var inv = character.get("inventory")
	if inv:
		for i in range(inv.slots.size()):
			var s = inv.slots[i]
			if s != null and s["id"] == "adena":
				s["count"] -= amount
				if s["count"] <= 0:
					inv.slots[i] = null
				inv.inventory_changed.emit()
				break

func _has_character_items(character: Node, item_id: String, count: int) -> bool:
	if not character or not character.get("inventory"):
		return false
	var total = 0
	for s in character.inventory.slots:
		if s != null and s["id"] == item_id:
			total += s["count"]
	return total >= count

func _deduct_character_items(character: Node, item_id: String, count: int) -> void:
	if not character or not character.get("inventory"):
		return
	var remaining = count
	for i in range(character.inventory.slots.size()):
		var s = character.inventory.slots[i]
		if s != null and s["id"] == item_id:
			if s["count"] <= remaining:
				remaining -= s["count"]
				character.inventory.slots[i] = null
			else:
				s["count"] -= remaining
				remaining = 0
			if remaining <= 0:
				break
	character.inventory.inventory_changed.emit()
