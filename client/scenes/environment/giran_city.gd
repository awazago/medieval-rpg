# res://client/scenes/environment/giran_city.gd
# Controlador de Cena da Metrópole Comercial de Giran (Crônica 2 - Sprint 7)
extends Node3D

@onready var player: PlayerCharacter = $Player
@onready var hud: Control = $HUD
@onready var hotbar: Hotbar = $HUD/Hotbar if has_node("HUD/Hotbar") else null
@onready var private_store_win: PrivateStoreWindow = $HUD/PrivateStoreWindow if has_node("HUD/PrivateStoreWindow") else null
@onready var private_store_mgr: PrivateStoreManager = $PrivateStoreManager if has_node("PrivateStoreManager") else null

func _ready() -> void:
	if player and hud:
		if hud.has_method("update_player_status"):
			player.stats_updated.connect(hud.update_player_status)
		if hud.has_method("update_target"):
			player.target_changed.connect(hud.update_target)
		if hud.has_method("set_soulshot_active"):
			player.soulshot_toggled.connect(hud.set_soulshot_active)
		if hud.has_method("update_exp"):
			player.exp_updated.connect(hud.update_exp)
		if hud.has_method("update_level_display"):
			player.leveled_up.connect(hud.update_level_display)
			
		# Status inicial
		if hud.has_method("update_player_status"):
			hud.update_player_status(
				player.current_hp, player.max_hp,
				player.current_mp, player.max_mp,
				player.current_cp, player.max_cp
			)
		if hud.has_method("add_system_message"):
			hud.add_system_message("🏰 Bem-vindo à Metrópole Comercial de Giran!")
			hud.add_system_message("Pressione [P] para abrir/fechar o painel de Loja Pessoal (Private Store).")
			hud.add_system_message("Pressione [F] próximo a NPCs ou Feirantes sentados para negociar.")
			hud.add_system_message("Pressione [I] para ver seu Inventário e peso de carga.")
			
	# Trilha sonora urbana nobre de Giran
	if AudioManager:
		AudioManager.play_music("village", 2.0)

func _unhandled_input(event: InputEvent) -> void:
	# Tecla P para alternar janela de Loja Pessoal
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		if private_store_win and player and private_store_mgr:
			if private_store_win.visible:
				private_store_win.close_window()
			else:
				private_store_win.open_for_player(player, private_store_mgr)

	# Tecla I para inventário
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		var inv_win = hud.get_node_or_null("InventoryWindow") if hud else null
		if inv_win and player and player.inventory:
			if inv_win.visible:
				inv_win.close_inventory()
			else:
				inv_win.open_inventory(player.inventory)

	# Tecla F para interagir com o NPC mais próximo
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		_interact_nearest_npc()

func _interact_nearest_npc() -> void:
	if not player:
		return
	var npcs = get_tree().get_nodes_in_group("npcs")
	var closest: Node3D = null
	var min_dist = 4.0 # Alcance de interação
	
	for npc in npcs:
		if npc is Node3D and npc != player:
			var d = player.global_position.distance_to(npc.global_position)
			if d < min_dist:
				min_dist = d
				closest = npc
				
	if closest and closest.has_method("interact"):
		closest.interact(player)
