# res://client/ui/dialog_window.gd
# Caixa de Diálogo Clássica de NPC (Estilo Lineage II)
class_name DialogWindow
extends PanelContainer

@onready var label_speaker: Label = $Margin/VBox/LabelSpeaker
@onready var label_body: RichTextLabel = $Margin/VBox/TextBody
@onready var options_container: VBoxContainer = $Margin/VBox/OptionsContainer

var current_npc: NPCCharacter = null

func _ready() -> void:
	add_to_group("dialog_window")
	visible = false

func open_dialogue(npc: NPCCharacter) -> void:
	current_npc = npc
	visible = true
	
	if label_speaker:
		label_speaker.text = npc.npc_name + " " + npc.npc_title
	if label_body:
		label_body.text = npc.greeting_text
		
	_build_options()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_dialogue() -> void:
	visible = false
	current_npc = null
	# Opcional: restaura mouse capturado se preferido pelo jogador

func _build_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
		
	# Opção 1: Missão tutorial
	var btn_quest = Button.new()
	btn_quest.text = "📜 [Missão] Aceitar: Primeiros Passos em Highstone"
	btn_quest.pressed.connect(_on_accept_quest)
	options_container.add_child(btn_quest)
	
	# Opção 2: Dica sobre Soulshots
	var btn_tip = Button.new()
	btn_tip.text = "💡 Como funcionam as Pedras de Alma (Soulshots)?"
	btn_tip.pressed.connect(_on_soulshot_tip)
	options_container.add_child(btn_tip)
	
	# Opção 3: Sair
	var btn_exit = Button.new()
	btn_exit.text = "✖ Encerrar Conversa"
	btn_exit.pressed.connect(close_dialogue)
	options_container.add_child(btn_exit)

func _on_accept_quest() -> void:
	label_body.text = "[color=yellow]Missão Aceita: Primeiros Passos em Highstone![/color]\n\n\"Excelente bravura, recruta! Vá até a Campina dos Sussurros ao leste e derrote 5 Raposas Jovens. Traga suas peles de volta e eu recompensarei você com Adena e Soulshots.\""
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("add_system_message"):
		hud.add_system_message("Nova Missão Iniciada: Primeiros Passos em Highstone (0/5 Raposas derrotadas).")

func _on_soulshot_tip() -> void:
	label_body.text = "\"As Pedras de Alma (Soulshots) comprimem espíritos guerreiros na sua lâmina. Pressione [F1] para ativá-las. Cada golpe com Soulshot consome uma pedra do seu inventário e DOBRA o dano físico do seu ataque! Use-as com sabedoria para acelerar suas caçadas.\""
