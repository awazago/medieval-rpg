# res://client/ui/network_menu.gd
# Menu Flutuante de Conexão Multiplayer / Servidor Dedicado
class_name NetworkMenu
extends PanelContainer

@onready var input_ip: LineEdit = get_node_or_null("Margin/VBox/InputIP")
@onready var input_port: LineEdit = get_node_or_null("Margin/VBox/InputPort")
@onready var btn_host: Button = get_node_or_null("Margin/VBox/HBox/BtnHost") if has_node("Margin/VBox/HBox/BtnHost") else get_node_or_null("Margin/VBox/BtnHost")
@onready var btn_join: Button = get_node_or_null("Margin/VBox/HBox/BtnJoin") if has_node("Margin/VBox/HBox/BtnJoin") else get_node_or_null("Margin/VBox/BtnJoin")
@onready var label_status: Label = get_node_or_null("Margin/VBox/LabelStatus")

func _ready() -> void:
	if btn_host:
		btn_host.pressed.connect(_on_host_pressed)
	if btn_join:
		btn_join.pressed.connect(_on_join_pressed)
		
	if NetworkManager:
		NetworkManager.server_started.connect(_on_server_started)
		NetworkManager.connection_successful.connect(_on_connection_success)
		NetworkManager.connection_failed.connect(_on_connection_failed)
		NetworkManager.peer_connected.connect(_on_peer_connected)

func _on_host_pressed() -> void:
	var port = int(input_port.text) if input_port and input_port.text != "" else 7777
	label_status.text = "Iniciando Servidor..."
	NetworkManager.start_server(port)

func _on_join_pressed() -> void:
	var ip = input_ip.text if input_ip and input_ip.text != "" else "127.0.0.1"
	var port = int(input_port.text) if input_port and input_port.text != "" else 7777
	label_status.text = "Conectando a " + ip + ":" + str(port) + "..."
	NetworkManager.join_server(ip, port)

func _on_server_started() -> void:
	label_status.text = "Servidor Ativo (Porta " + input_port.text + ")"
	label_status.modulate = Color.GREEN
	btn_host.disabled = true
	btn_join.disabled = true

func _on_connection_success() -> void:
	label_status.text = "Conectado ao Servidor!"
	label_status.modulate = Color.GREEN
	btn_host.disabled = true
	btn_join.disabled = true

func _on_connection_failed() -> void:
	label_status.text = "Falha na Conexão!"
	label_status.modulate = Color.RED

func _on_peer_connected(id: int) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("add_system_message"):
		hud.add_system_message("[color=green]Novo Jogador Conectado (ID: " + str(id) + ")![/color]")
