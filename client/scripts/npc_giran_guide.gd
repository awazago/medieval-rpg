extends CharacterBody3D

@export var npc_name: String = "Oficial Lauren"
@export var npc_title: String = "<Guia e Guarda Imperial de Giran>"

func _ready() -> void:
	add_to_group("npcs")

func interact(player: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
		
	var dialog_win = hud.get_node_or_null("DialogWindow")
	if not dialog_win:
		return
		
	var title = npc_name + " " + npc_title
	var text = "Saudações e bem-vindo ao Continente de Aden!\n\nVocê acaba de ancorar no Porto de Giran. A estrada à sua frente leva diretamente à grande Metrópole Comercial de Giran, o centro nevrálgico do comércio, das guildas e do poder militar do reino.\n\nComo posso orientá-lo em seus primeiros passos no continente?"
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "📜 Como faço a 1ª Mudança de Classe (Nível 20)?",
			"action": Callable(self, "_on_class_transfer_info").bind(dialog_win)
		},
		{
			"text": "💰 O que é o Grande Mercado de Giran?",
			"action": Callable(self, "_on_market_info").bind(dialog_win)
		},
		{
			"text": "⛵ Retornar de barco para a Ilha do Alvorecer",
			"action": Callable(self, "_on_return_to_dawn_isle").bind(player)
		},
		{
			"text": "Obrigado, vou explorar a cidade por conta própria.",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_class_transfer_info(dialog_win: Control) -> void:
	var title = npc_name + " " + npc_title
	var text = "[color=yellow]A Sagrada 1ª Mudança de Classe:[/color]\n\n\"No centro de Giran você encontrará os Mestres de cada clã:\n- Grande Mestre dos Guerreiros (Gladiator / Warlord / Knight)\n- Grão-Mago da Torre de Éter (Sorcerer / Necromancer)\n- Mestre Ladino dos Arqueiros e Adagueiros (Hawkeye / Treasure Hunter)\n- Clérigos do Templo de Einhasad (Bishop / Prophet)\n\nAtingir o Nível 20 e realizar o ritual concederá a você novas armas D-Grade e suas habilidades verdadeiras!\""
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "Excelente, buscarei meus mestres!",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_market_info(dialog_win: Control) -> void:
	var title = npc_name + " " + npc_title
	var text = "[color=gold]O Grande Mercado Livre de Giran:[/color]\n\n\"A praça central de Giran é onde jogadores de todos os cantos do reino montam suas Lojas Pessoais (Private Stores) de Compra e Venda. Lá são negociados pergaminhos de encantamento, armas D-Grade e materiais raros. Guarde bem sua Adena!\""
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "Entendido!",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_return_to_dawn_isle(_player: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("DialogWindow"):
		hud.get_node("DialogWindow").hide()
		
	get_tree().change_scene_to_file("res://client/scenes/main_game.tscn")
