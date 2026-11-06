extends CanvasLayer
class_name HUD

@onready var hp_bar: ProgressBar = $TopLeft/Bars/HPBar
@onready var hp_label: Label = $TopLeft/Bars/HPBar/HPLabel
@onready var stamina_bar: ProgressBar = $TopLeft/Bars/StaminaBar
@onready var xp_bar: ProgressBar = $TopLeft/Bars/XPBar
@onready var level_label: Label = $TopLeft/LevelBadge/LevelLabel
@onready var gold_label: Label = $TopRight/GoldContainer/GoldLabel

@onready var boss_container: VBoxContainer = $BossContainer
@onready var boss_name_label: Label = $BossContainer/BossName
@onready var boss_bar: ProgressBar = $BossContainer/BossBar

@onready var game_over_panel: Control = $GameOverPanel
@onready var victory_panel: Control = $VictoryPanel

func _ready() -> void:
	add_to_group("hud")
	boss_container.visible = false
	game_over_panel.visible = false
	victory_panel.visible = false

func update_stats(hp: int, max_hp: int, stamina: float, max_stamina: float, gold: int, level: int, xp: int, xp_needed: int) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_label.text = "HP: %d / %d" % [hp, max_hp]
		
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
		
	if xp_bar:
		xp_bar.max_value = xp_needed
		xp_bar.value = xp
		
	if level_label:
		level_label.text = "LV %d" % level
		
	if gold_label:
		gold_label.text = "%d G" % gold

func show_boss_bar(boss_name: String, max_hp: int, current_hp: int) -> void:
	boss_container.visible = true
	boss_name_label.text = boss_name
	boss_bar.max_value = max_hp
	boss_bar.value = current_hp

func update_boss_hp(current_hp: int) -> void:
	if boss_bar:
		boss_bar.value = current_hp

func on_boss_defeated() -> void:
	boss_container.visible = false
	show_victory()

func show_game_over() -> void:
	game_over_panel.visible = true
	var t = create_tween()
	game_over_panel.modulate.a = 0.0
	t.tween_property(game_over_panel, "modulate:a", 1.0, 0.4)

func show_victory() -> void:
	victory_panel.visible = true
	var t = create_tween()
	victory_panel.modulate.a = 0.0
	t.tween_property(victory_panel, "modulate:a", 1.0, 0.4)

func _unhandled_input(event: InputEvent) -> void:
	if (game_over_panel.visible or victory_panel.visible):
		if event is InputEventKey and event.pressed and event.keycode == KEY_R:
			restart_game()

func restart_game() -> void:
	get_tree().reload_current_scene()

func _on_restart_button_pressed() -> void:
	restart_game()
