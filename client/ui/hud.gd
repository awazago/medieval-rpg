# res://client/ui/hud.gd
# HUD Clássico estilo Lineage II (Status do Personagem, Target Box, Hotbar e Chat)
class_name GameHUD
extends CanvasLayer

@onready var label_name: Label = $TopLeftStatus/VBox/LabelName
@onready var bar_cp: ProgressBar = $TopLeftStatus/VBox/BarCP
@onready var bar_hp: ProgressBar = $TopLeftStatus/VBox/BarHP
@onready var bar_mp: ProgressBar = $TopLeftStatus/VBox/BarMP

@onready var target_box: Control = $TopCenterTarget
@onready var label_target_name: Label = $TopCenterTarget/VBox/LabelTargetName
@onready var bar_target_hp: ProgressBar = $TopCenterTarget/VBox/BarTargetHP

@onready var label_soulshot: Label = $BottomBar/SoulshotIndicator
@onready var chat_log: RichTextLabel = $BottomLeftChat/ChatLog

@onready var bar_xp: ProgressBar = $BottomXPBar/BarXP
@onready var label_xp: Label = $BottomXPBar/LabelXP

func _ready() -> void:
	if target_box:
		target_box.visible = false
	add_system_message("Bem-vindo a Aethelgard! Conectado aos servidores.")

func update_player_status(hp: int, max_hp: int, mp: int, max_mp: int, cp: int, max_cp: int) -> void:
	if bar_hp:
		bar_hp.max_value = max_hp
		bar_hp.value = hp
	if bar_mp:
		bar_mp.max_value = max_mp
		bar_mp.value = mp
	if bar_cp:
		bar_cp.max_value = max_cp
		bar_cp.value = cp

func update_target(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		if target_box:
			target_box.visible = false
		return
		
	if target_box:
		target_box.visible = true
		if target.has_method("get") and target.get("monster_name"):
			label_target_name.text = str(target.get("monster_name")) + " (Nv. " + str(target.get("level")) + ")"
			bar_target_hp.max_value = target.get("max_hp")
			bar_target_hp.value = target.get("current_hp")
		else:
			label_target_name.text = target.name
			bar_target_hp.value = 100

func set_soulshot_active(active: bool) -> void:
	if label_soulshot:
		if active:
			label_soulshot.text = "[SOULSHOT: ATIVO]"
			label_soulshot.modulate = Color(1.0, 0.8, 0.1) # Dourado
		else:
			label_soulshot.text = "[SOULSHOT: INATIVO]"
			label_soulshot.modulate = Color(0.6, 0.6, 0.6)

func add_combat_log(message: String) -> void:
	if chat_log:
		chat_log.append_text("[color=yellow]" + message + "[/color]\n")

func add_system_message(message: String) -> void:
	if chat_log:
		chat_log.append_text("[color=aqua]" + message + "[/color]\n")

func update_exp(current: int, required: int, pct: float, sp: int) -> void:
	if bar_xp:
		bar_xp.max_value = 100.0
		bar_xp.value = pct
	if label_xp:
		label_xp.text = "XP: %.2f%% (%d / %d) | SP: %d" % [pct, current, required, sp]

func update_level_display(new_level: int) -> void:
	if label_name:
		label_name.text = "Aventureiro (Nv. " + str(new_level) + ")"
