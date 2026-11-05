# res://client/scripts/npc_warehouse.gd
# NPC Guardião do Armazém Geral (Warehouse Keeper)
class_name NPCWarehouse
extends NPCCharacter

func _ready() -> void:
	model_preset = "mage"
	super._ready()
	npc_id = "warehouse_randall"
	npc_name = "Guardião Randall"
	npc_title = "<Armazém Geral de Highstone>"
	if label_name:
		label_name.text = npc_name + "\n" + npc_title

func interact(player: PlayerCharacter) -> void:
	var wh = get_tree().get_first_node_in_group("warehouse_window")
	if wh and wh.has_method("open_warehouse"):
		wh.open_warehouse(player)
