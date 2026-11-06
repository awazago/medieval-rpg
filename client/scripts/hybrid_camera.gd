# res://client/scripts/hybrid_camera.gd
# Controlador de Câmera Híbrida 1ª Pessoa / 3ª Pessoa Livre com Zoom Contínuo
class_name HybridCamera
extends SpringArm3D

signal perspective_changed(is_first_person: bool)

@export_category("Zoom & Perspectiva")
@export var min_zoom_distance: float = 0.0      # 0.0 ativa a 1ª Pessoa
@export var max_zoom_distance: float = 12.0     # 3ª Pessoa orbital aberta
@export var zoom_step: float = 0.8              # Velocidade do zoom por tick da roda do mouse
@export var zoom_smoothness: float = 12.0       # Interpolação suave de câmera
@export var first_person_threshold: float = 0.35 # Distância em que a malha do player é ocultada

@export_category("Rotação & Sensibilidade")
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -75.0            # Olhar para cima
@export var max_pitch: float = 65.0             # Olhar para baixo

var current_target_distance: float = 4.5
var is_first_person: bool = false
var is_cursor_captured: bool = true

@onready var camera_node: Camera3D = $Camera3D
@export var character_mesh_node: Node3D         # Referência à malha do personagem

func _ready() -> void:
	spring_length = current_target_distance
	if get_parent() is CollisionObject3D:
		add_excluded_object(get_parent().get_rid())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_update_perspective_mode(false)

func _input(event: InputEvent) -> void:
	# Alternar cursor livre (para clicar em UI/alvos) com a tecla Alt
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		_toggle_mouse_capture()
		
	# Zoom via roda do mouse (Scroll Wheel)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_adjust_zoom(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_adjust_zoom(zoom_step)
			
	# Rotação da câmera pelo mouse
	if event is InputEventMouseMotion and (is_cursor_captured or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		_rotate_camera(event.relative)

func _adjust_zoom(delta: float) -> void:
	current_target_distance = clampf(current_target_distance + delta, min_zoom_distance, max_zoom_distance)
	
	var should_be_first_person = (current_target_distance <= first_person_threshold)
	if should_be_first_person != is_first_person:
		_update_perspective_mode(should_be_first_person)

func _update_perspective_mode(first_person: bool) -> void:
	is_first_person = first_person
	
	if is_first_person:
		# Modo 1ª Pessoa: oculta o corpo para a câmera não colidir dentro da cabeça
		if character_mesh_node:
			character_mesh_node.visible = false
		camera_node.fov = 85.0
	else:
		# Modo 3ª Pessoa: reexibe o personagem em corpo inteiro com armaduras e armas
		if character_mesh_node:
			character_mesh_node.visible = true
		camera_node.fov = 75.0
		
	perspective_changed.emit(is_first_person)

func _physics_process(delta: float) -> void:
	# Interpolação suave do comprimento do braço (SpringArm3D)
	spring_length = lerpf(spring_length, current_target_distance, zoom_smoothness * delta)

func _rotate_camera(relative_motion: Vector2) -> void:
	# Rotação Horizontal (Yaw)
	get_parent().rotate_y(-relative_motion.x * mouse_sensitivity)
	
	# Rotação Vertical (Pitch) no SpringArm
	rotation.x -= relative_motion.y * mouse_sensitivity
	rotation.x = clampf(rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _toggle_mouse_capture() -> void:
	is_cursor_captured = not is_cursor_captured
	if is_cursor_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
