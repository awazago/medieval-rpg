extends Node3D

@onready var ship_node: Node3D = $CaravelShip
@onready var progress_bar: ProgressBar = $HUD/ProgressContainer/VBox/ProgressBar
@onready var label_status: Label = $HUD/ProgressContainer/VBox/LabelStatus
@onready var btn_skip: Button = $HUD/ProgressContainer/VBox/BtnSkip

var voyage_duration: float = 6.0
var elapsed_time: float = 0.0
var ship_speed: float = 12.0

func _ready() -> void:
	if btn_skip:
		btn_skip.pressed.connect(_on_reach_giran)
		
	# Inicia música de travessia / oceano se disponível
	if AudioManager:
		AudioManager.play_music("dawn_isle_village", 1.5)

func _process(delta: float) -> void:
	elapsed_time += delta
	var progress = clamp(elapsed_time / voyage_duration, 0.0, 1.0)
	
	if progress_bar:
		progress_bar.value = progress * 100.0
		
	# Movimento suave do navio avançando no oceano e leve balanço marítimo
	if ship_node:
		ship_node.position.z -= ship_speed * delta
		ship_node.rotation_degrees.z = sin(elapsed_time * 2.0) * 1.8
		ship_node.rotation_degrees.x = cos(elapsed_time * 1.5) * 1.2
		
	if elapsed_time >= voyage_duration:
		_on_reach_giran()

func _on_reach_giran() -> void:
	set_process(false)
	get_tree().change_scene_to_file("res://client/scenes/environment/giran_harbor.tscn")
