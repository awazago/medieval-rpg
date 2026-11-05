# res://client/scripts/npc_giran_trader.gd
# Comerciante Valéria da Guilda Mercantil de Giran (Itens e Equipamentos Grau D)
class_name NPC_GiranTraderValeria
extends CharacterBody3D

@export var npc_name: String = "Mercadora Valeria"
@export var npc_title: String = "<Fornecedora de Armas e Armaduras Grau D>"

const GIRAN_D_GRADE_CATALOG = [
	"bastard_sword",
	"elven_bow",
	"crucifix_of_blessing",
	"mithril_dagger",
	"brigandine_tunic",
	"mithril_tunic",
	"soulshot_d",
	"spiritshot_d",
	"crystal_d",
	"scroll_of_escape_giran"
]

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
	var text = "Bem-vindo à Metrópole de Giran, forasteiro!\n\nAqui na praça do mercado você encontra o melhor aço forjado do reino. Nossas armas e armaduras de Grau D são recomendadas para heróis experientes a partir do Nível 20.\n\nDeseja negociar suprimentos imperiais?"
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "⚔️ Ver Armas e Armaduras Grau D à venda",
			"action": Callable(self, "_on_open_d_shop").bind(player, dialog_win)
		},
		{
			"text": "🪙 Como funcionam as Lojas Pessoais (Private Stores)?",
			"action": Callable(self, "_on_store_info").bind(dialog_win)
		},
		{
			"text": "Apenas visitando o mercado por enquanto.",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_open_d_shop(player: CharacterBody3D, dialog_win: Control) -> void:
	dialog_win.hide()
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
	var shop_win = hud.get_node_or_null("ShopWindow")
	if shop_win and shop_win.has_method("open_shop"):
		shop_win.open_shop(player)

func _on_store_info(dialog_win: Control) -> void:
	var title = npc_name + " " + npc_title
	var text = "[color=gold]Lojas Pessoais na Praça de Giran:[/color]\n\n\"Qualquer herói pode abrir sua própria loja aqui na praça! Basta pressionar a tecla [color=yellow][P][/color] para abrir o painel comercial, escolher se deseja Vender ou Comprar, colocar seus itens e sentar no chão com a plaquinha dourada.\n\nOutros viajantes podem negociar diretamente com você pagando ou recebendo Adena à vista!\""
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "Entendi, obrigado!",
			"action": Callable(dialog_win, "hide")
		}
	])
