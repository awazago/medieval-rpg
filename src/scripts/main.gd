extends Node2D

@onready var player: Node2D = $Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	if player:
		player.global_position = Vector2(21 * 32, 36 * 32)
		if player.has_method("emit_stats"):
			player.emit_stats()
