# res://client/scripts/npc_blacksmith.gd
# NPC Ferreiro Torvald da Vila de Highstone (Abre Loja de Equipamentos)
class_name NPCBlacksmith
extends NPCCharacter

func _ready() -> void:
	super._ready()
	npc_id = "blacksmith_torvald"
	npc_name = "Ferreiro Torvald"
	npc_title = "<Mestre da Forja de Highstone>"
	if label_name:
		label_name.text = npc_name + "\n" + npc_title

func interact(player: PlayerCharacter) -> void:
	var shop = get_tree().get_first_node_in_group("shop_window")
	if shop and shop.has_method("open_shop"):
		shop.open_shop(player)
