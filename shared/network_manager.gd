# res://shared/network_manager.gd
# Gerenciador de Rede ENet (Arquitetura Cliente-Servidor Autoritativo)
extends Node

const DEFAULT_PORT: int = 7777
const MAX_CLIENTS: int = 64

signal server_started()
signal connection_successful()
signal connection_failed()
signal peer_connected(id: int)
signal peer_disconnected(id: int)

var peer: ENetMultiplayerPeer
var is_server: bool = false
var local_player_id: int = 1

# Estado de jogadores conectados: id -> { "name": String, "position": Vector3, "hp": int, "max_hp": int }
var connected_players: Dictionary = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

## Inicia o servidor autoritativo (Headless ou com interface)
func start_server(port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_CLIENTS)
	if error != OK:
		push_error("[NetworkManager] Falha ao criar servidor na porta " + str(port) + ": " + str(error))
		return error
		
	multiplayer.multiplayer_peer = peer
	is_server = true
	local_player_id = 1
	print("[NetworkManager] Servidor iniciado na porta ", port, " (Pronto para conexões)")
	server_started.emit()
	return OK

## Conecta um cliente ao servidor especificado
func join_server(ip: String = "127.0.0.1", port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		push_error("[NetworkManager] Falha ao conectar ao servidor " + ip + ":" + str(port))
		return error
		
	multiplayer.multiplayer_peer = peer
	is_server = false
	print("[NetworkManager] Conectando a ", ip, ":", port, "...")
	return OK

func _on_peer_connected(id: int) -> void:
	print("[NetworkManager] Novo peer conectado: ID ", id)
	peer_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	print("[NetworkManager] Peer desconectado: ID ", id)
	connected_players.erase(id)
	peer_disconnected.emit(id)

func _on_connected_to_server() -> void:
	local_player_id = multiplayer.get_unique_id()
	print("[NetworkManager] Conexão bem-sucedida! Meu ID local: ", local_player_id)
	connection_successful.emit()

func _on_connection_failed() -> void:
	push_warning("[NetworkManager] Conexão falhou.")
	connection_failed.emit()

func _on_server_disconnected() -> void:
	print("[NetworkManager] Desconectado do servidor.")
