# res://client/scripts/npc_warehouse_chief.gd
# Chefe Moke do Armazém Imperial de Giran
class_name NPC_WarehouseChiefMoke
extends CharacterBody3D

@export var npc_name: String = "Chefe Moke"
@export var npc_title: String = "<Guardião do Armazém Imperial de Giran>"

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
	var text = "Bem-vindo ao Grande Armazém da Metrópole de Giran!\n\nNossos cofres de pedra protegidos por encantamentos imperiais são os mais seguros de todo o continente. Guardamos suas preciosidades, lingotes de ferro, cristais D e equipamentos pesados para aliviar o peso de sua jornada.\n\nComo posso servi-lo hoje?"
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "📦 Acessar Cofre Pessoal de Giran (Depositar/Retirar)",
			"action": Callable(self, "_on_open_vault").bind(player, dialog_win)
		},
		{
			"text": "Até breve, Chefe Moke.",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_open_vault(player: CharacterBody3D, dialog_win: Control) -> void:
	dialog_win.hide()
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
	var wh_win = hud.get_node_or_null("WarehouseWindow")
	if wh_win and wh_win.has_method("open_warehouse"):
		wh_win.open_warehouse(player)
