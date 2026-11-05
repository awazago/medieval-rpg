# res://client/scripts/npc_private_store_dummy.gd
# NPC Feirante Sentado com Loja Pessoal Ativa (Simulador Canônico da Feira de Giran)
class_name NPC_PrivateStoreDummy
extends CharacterBody3D

@export var merchant_name: String = "Feirante Goran"
@export var store_type: int = 1 # 1 = Sell, 2 = Buy
@export var store_title: String = "Soulshots D & Cristais D Barato!"
@export var race_name: String = "dwarf"

@onready var rig: HumanoidCharacterRig = $VisualMesh/HumanoidCharacterRig if has_node("VisualMesh/HumanoidCharacterRig") else null
@onready var sign_3d: PrivateStoreSign3D = $PrivateStoreSign3D if has_node("PrivateStoreSign3D") else null

var store_manager: PrivateStoreManager = null

func _ready() -> void:
	add_to_group("npcs")
	add_to_group("private_stores")
	
	# Inicializa gerenciador de loja pessoal próprio
	store_manager = PrivateStoreManager.new()
	add_child(store_manager)
	
	# Popula os itens da banca baseado no tipo
	var items: Array[Dictionary] = []
	if store_type == 1:
		# Loja de Venda
		items = [
			{
				"id": "soulshot_d",
				"name": "Pedra de Alma (Grau D)",
				"count": 500,
				"price_per_unit": 35,
				"data": {"name": "Pedra de Alma (Grau D)", "price": 35, "weight": 3, "grade": "D"}
			},
			{
				"id": "crystal_d",
				"name": "Cristal Grau D",
				"count": 50,
				"price_per_unit": 550,
				"data": {"name": "Cristal Grau D", "price": 550, "weight": 2, "grade": "D"}
			},
			{
				"id": "scroll_of_escape_giran",
				"name": "Pergaminho de Teletransporte: Giran",
				"count": 10,
				"price_per_unit": 500,
				"data": {"name": "Pergaminho de Teletransporte: Giran", "price": 500, "weight": 12}
			}
		]
		store_manager.open_sell_store(self, store_title, items)
	else:
		# Loja de Compra
		items = [
			{
				"id": "crystal_d",
				"name": "Cristal Grau D",
				"count": 20,
				"price_per_unit": 500,
				"data": {"name": "Cristal Grau D", "price": 500, "weight": 2}
			},
			{
				"id": "bone_dagger",
				"name": "Adaga de Osso Reforçada",
				"count": 2,
				"price_per_unit": 350,
				"data": {"name": "Adaga de Osso Reforçada", "price": 350, "weight": 700}
			}
		]
		store_manager.open_buy_store(self, store_title, items)
		
	# Configura a postura sentada e plaquinha flutuante
	if rig:
		rig.play_sit_shop()
		
	if sign_3d:
		sign_3d.setup(store_type, store_title)

func interact(player: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
		
	var store_win = hud.get_node_or_null("PrivateStoreWindow")
	if not store_win:
		store_win = get_tree().get_first_node_in_group("private_store_window")
		
	if store_win and store_manager:
		store_win.open_browse_store(player, store_manager)
