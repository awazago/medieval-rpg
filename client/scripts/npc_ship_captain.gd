extends CharacterBody3D

@export var npc_id: String = "captain_drake"
@export var npc_name: String = "Capitão Drake"
@export var npc_title: String = "<Mestre Navegador do Sul>"

func _ready() -> void:
	add_to_group("npcs")

func interact(player: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
		
	var dialog_win = hud.get_node_or_null("DialogWindow")
	if not dialog_win:
		return
		
	var player_level = 1
	var has_ticket = false
	
	if "level" in player:
		player_level = player.level
		
	if "inventory" in player and player.inventory != null:
		has_ticket = player.inventory.has_item("ticket_continental_ship")
		
	var title = npc_name + " " + npc_title
	var text = ""
	
	if player_level >= 20 or has_ticket:
		text = "Saudações, herói de Highstone! Os ecos de sua vitória chegaram até o porto. A caravela 'Vento de Aden' está abastecida e pronta para partir rumo ao Porto Imperial de Giran.\n\nDeseja zarpar para o continente agora?"
		dialog_win.show_dialog_custom(title, text, [
			{
				"text": "Sim! Içar velas para Giran!",
				"action": Callable(self, "_on_board_ship").bind(player)
			},
			{
				"text": "Ainda não, preciso organizar minhas malas.",
				"action": Callable(dialog_win, "hide")
			}
		])
	else:
		text = "Ahoy, recruta! As águas do alto mar são infestadas de serpentes marinhas e piratas sem lei.\n\nPara embarcar rumo ao Continente de Giran, você deve atingir o Nível 20 ou obter o Bilhete de Embarque Continental com o Sentinela Marcus após dominar a ilha.\n\nVolte quando estiver pronto!"
		dialog_win.show_dialog_custom(title, text, [
			{
				"text": "Entendido, voltarei mais forte.",
				"action": Callable(dialog_win, "hide")
			}
		])

func _on_board_ship(_player: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("DialogWindow"):
		hud.get_node("DialogWindow").hide()
		
	# Toca som de partida ou transição
	if AudioManager:
		AudioManager.play_sfx("coins_pickup") # placeholder de transição
		
	# Inicia cena de viagem marítima
	get_tree().change_scene_to_file("res://client/scenes/environment/ocean_voyage.tscn")
