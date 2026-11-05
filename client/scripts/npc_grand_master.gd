# res://client/scripts/npc_grand_master.gd
# Grão-Mestre Kallum da Guilda dos Guerreiros e Magos de Giran
class_name NPC_GrandMasterKallum
extends CharacterBody3D

@export var npc_name: String = "Grão-Mestre Kallum"
@export var npc_title: String = "<Instrutor de Classes de Giran>"

@onready var rig: HumanoidCharacterRig = $VisualMesh/HumanoidCharacterRig if has_node("VisualMesh/HumanoidCharacterRig") else null

func _ready() -> void:
	add_to_group("npcs")
	if rig:
		if rig.has_method("set_character_model"):
			rig.set_character_model("mage")
		rig.play_anim("idle")

func interact(player: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
		
	var dialog_win = hud.get_node_or_null("DialogWindow")
	if not dialog_win:
		return
		
	var player_level = player.level if player and "level" in player else 1
	var title = npc_name + " " + npc_title
	var text = "Saudações, jovem guerreiro de Aethelgard.\n\nSou Kallum, Grão-Mestre das Ordens Marciais de Giran. Minha missão é guiar os aventureiros que alcançam o ápice de sua formação rumo à 1ª Mudança de Classe (Nível 20).\n\nSeu nível atual: [color=yellow]Nível %d[/color]." % player_level
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "📜 Quais são os caminhos de classe disponíveis no Nível 20?",
			"action": Callable(self, "_on_class_paths_info").bind(dialog_win)
		},
		{
			"text": "💎 Como funcionam os Equipamentos e Cristais Grau D?",
			"action": Callable(self, "_on_d_grade_info").bind(dialog_win)
		},
		{
			"text": "Obrigado, retornarei quando atingir o Nível 20.",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_class_paths_info(dialog_win: Control) -> void:
	var title = npc_name + " " + npc_title
	var text = "[color=yellow]As Ordens do Continente de Aden (Sprint 8):[/color]\n\n" + \
		"• [color=gold]Cavaleiro / Paladino:[/color] Mestres do escudo, espada e proteção defensiva incomparável.\n" + \
		"• [color=gold]Gladiador / Warlord:[/color] Especialistas em duas espadas, combate frenético e dano em área.\n" + \
		"• [color=gold]Feiticeiro / Necromante:[/color] Conjuradores das chamas arcanas e magias de maldição espectral.\n" + \
		"• [color=gold]Ladino / Assassino:[/color] Furtividade, ataques críticos letais nas costas e arco de longo alcance.\n" + \
		"• [color=gold]Oráculo / Clérigo:[/color] Bênçãos de suporte, cura milagrosa e fortalecimento de grupos.\n\n" + \
		"Alcance o Nível 20 e traga os três selos das provações para sua ordenação!"
		
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "Honrarei meu destino!",
			"action": Callable(dialog_win, "hide")
		}
	])

func _on_d_grade_info(dialog_win: Control) -> void:
	var title = npc_name + " " + npc_title
	var text = "[color=cyan]Mecânica Canônica de Grau D (Lineage II):[/color]\n\n\"Ao completar o Nível 20, sua penalidade de grau é removida para itens Grau D. Você poderá empunhar a temível Espada Bastarda e o Arco Élfico sem penalidade de acerto ou velocidade de movimento.\n\nAlém disso, armas D utilizam Soulshots Grau D, que dobram a força de seus ataques!\""
	
	dialog_win.show_dialog_custom(title, text, [
		{
			"text": "Compreendido, Grão-Mestre.",
			"action": Callable(dialog_win, "hide")
		}
	])
