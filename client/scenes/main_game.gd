# res://client/scenes/main_game.gd
# Controlador Central da Cena de Jogo e Integração Cliente
extends Node3D

const FLOAT_NUMBER_SCENE = preload("res://client/scenes/vfx/floating_damage_number.tscn")
const SOULSHOT_BURST_SCENE = preload("res://client/scenes/vfx/soulshot_particles.tscn")

@onready var player: PlayerCharacter = $Player
@onready var hud: GameHUD = $HUD
@onready var hotbar: Hotbar = $HUD/Hotbar

func _ready() -> void:
	if player:
		if GameData:
			if GameData.selected_character_name != "":
				player.character_name = GameData.selected_character_name
			if GameData.selected_race_id != "" and player.has_method("apply_race_data"):
				player.apply_race_data(GameData.selected_race_id)

	if player and hud:
		player.stats_updated.connect(hud.update_player_status)
		player.target_changed.connect(hud.update_target)
		player.soulshot_toggled.connect(hud.set_soulshot_active)
		player.exp_updated.connect(hud.update_exp)
		player.leveled_up.connect(hud.update_level_display)
		
		# Emite estado inicial
		hud.update_player_status(
			player.current_hp, player.max_hp,
			player.current_mp, player.max_mp,
			player.current_cp, player.max_cp
		)
		hud.update_exp(player.current_exp, player.required_exp, 0.0, player.current_sp)
		hud.add_system_message("Pressione [Scroll do Mouse] para alternar entre 1ª Pessoa e 3ª Pessoa Livre.")
		hud.add_system_message("Pressione [Tab] para selecionar o monstro mais próximo.")
		hud.add_system_message("Pressione [F1] para ligar Soulshots. Clique com botão esquerdo para atacar.")
		hud.add_system_message("Pressione [I] para abrir/fechar o Inventário com controle de peso.")
		hud.add_system_message("Teclas [1 a 8]: Barra de atalhos rápida e conjuração de habilidades.")

	if hotbar:
		hotbar.skill_triggered.connect(_on_skill_triggered)
		hotbar.item_shortcut_triggered.connect(_on_item_shortcut_triggered)

var music_check_timer: float = 0.0

func _process(delta: float) -> void:
	music_check_timer += delta
	if music_check_timer >= 1.0: # Checa transição de música a cada 1 segundo
		music_check_timer = 0.0
		_update_music_zone()

## Transição dinâmica de trilha sonora baseada na localização e combate
func _update_music_zone() -> void:
	if not AudioManager or not player:
		return
		
	# 1. Combate com Raid Boss Valthor ou câmara profunda
	if player.global_position.z <= -50.0 or (player.selected_target and player.selected_target.get("is_raid_boss") == true):
		AudioManager.play_music("boss", 1.5)
	# 2. Cripta Antiga e Ruínas
	elif player.global_position.z <= -24.0:
		AudioManager.play_music("crypt", 2.0)
	# 3. Vila de Highstone e campinas ensolaradas
	else:
		AudioManager.play_music("village", 2.5)

func _unhandled_input(event: InputEvent) -> void:
	# Ataque básico com o botão esquerdo do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_attempt_player_attack()

func _attempt_player_attack() -> void:
	if player.selected_target == null or not is_instance_valid(player.selected_target):
		return
		
	var target = player.selected_target
	var distance = player.global_position.distance_to(target.global_position)
	
	# Alcance corpo a corpo
	if distance > 3.5:
		hud.add_system_message("O alvo está muito longe para atacar!")
		return
		
	# Calcula o dano canônico estilo Lineage II
	var target_p_def = target.get("p_def") if target.get("p_def") else 12.0
	var result = CombatFormulas.calculate_physical_damage(
		player.p_atk,
		target_p_def,
		30, # DEX padrão
		8,  # Crit rate da arma básica
		player.soulshots_enabled,
		0.0 # Sem skill, ataque normal
	)
	
	var damage = result["damage"]
	var is_crit = result["is_critical"]
	
	# Aplica dano na entidade
	if target.has_method("take_damage"):
		target.take_damage(damage, player)
		
	# Aplica animação de ataque
	if player.has_method("play_attack_animation"):
		player.play_attack_animation()
		
	# Efeito visual de Soulshot
	if player.soulshots_enabled:
		_spawn_soulshot_burst(target.global_position + Vector3(0, 0.8, 0))
		if AudioManager:
			AudioManager.play_sfx("soulshot_hit")
	else:
		if AudioManager:
			AudioManager.play_sfx("sword_swing")
		
	# Número de dano flutuante 3D
	_spawn_floating_damage(target.global_position + Vector3(0, 1.2, 0), damage, is_crit)
	
	# Atualiza a barra de vida do alvo no HUD
	hud.update_target(target)
	
	# Mensagem de log no estilo Lineage II
	var log_msg = "Você causou " + str(damage) + " de dano a " + str(target.get("monster_name")) + "!"
	if is_crit:
		log_msg = "[DANO CRÍTICO!] " + log_msg
	if player.soulshots_enabled:
		log_msg = "[SOULSHOT] " + log_msg
		
	hud.add_combat_log(log_msg)

func _on_skill_triggered(skill_id: String) -> void:
	var skill_data = GameData.get_skill(skill_id) if GameData else {}
	if skill_data.is_empty():
		return
		
	var mp_cost = skill_data.get("mp_cost", 10)
	if player.current_mp < mp_cost:
		hud.add_system_message("[color=red]Mana insuficiente![/color]")
		return
		
	# Consome MP
	player.current_mp -= mp_cost
	if AudioManager:
		AudioManager.play_sfx("magic_cast")
	hud.update_player_status(
		player.current_hp, player.max_hp,
		player.current_mp, player.max_mp,
		player.current_cp, player.max_cp
	)
	
	# Habilidade de Cura (Auto-cast ou Alvo)
	if skill_id == "lesser_heal":
		var heal_val = skill_data.get("power", 60)
		player.current_hp = mini(player.max_hp, player.current_hp + heal_val)
		if player.has_method("play_cast_animation"):
			player.play_cast_animation()
		hud.update_player_status(
			player.current_hp, player.max_hp,
			player.current_mp, player.max_mp,
			player.current_cp, player.max_cp
		)
		_spawn_floating_damage(player.global_position + Vector3(0, 1.5, 0), heal_val, false)
		hud.add_combat_log("[CURA] Você restaurou " + str(heal_val) + " pontos de vida.")
		return
		
	# Habilidade de Ataque
	if player.selected_target == null or not is_instance_valid(player.selected_target):
		hud.add_system_message("Selecione um alvo para usar " + skill_data.get("name", "esta habilidade") + "!")
		return
		
	var target = player.selected_target
	var distance = player.global_position.distance_to(target.global_position)
	var max_range = skill_data.get("range_units", 3.0)
	
	if distance > max_range:
		hud.add_system_message("Alvo fora de alcance (" + str(int(distance)) + "m / máx " + str(int(max_range)) + "m)!")
		return
		
	var target_p_def = target.get("p_def") if target.get("p_def") else 12.0
	var target_m_def = target.get("m_def") if target.get("m_def") else 10.0
	var skill_power = skill_data.get("power", 30.0)
	var result: Dictionary
	
	if skill_data.get("element"):
		# Magia (ex: Flecha Ígnea)
		if player.has_method("play_cast_animation"):
			player.play_cast_animation()
		result = CombatFormulas.calculate_magical_damage(player.m_atk, target_m_def, 12, skill_power, player.soulshots_enabled)
	else:
		# Físico (ex: Golpe Poderoso)
		if player.has_method("play_attack_animation"):
			player.play_attack_animation()
		result = CombatFormulas.calculate_physical_damage(player.p_atk, target_p_def, 30, 8, player.soulshots_enabled, skill_power)
		
	var damage = result["damage"]
	var is_crit = result["is_critical"]
	
	if target.has_method("take_damage"):
		target.take_damage(damage, player)
		
	if player.soulshots_enabled:
		_spawn_soulshot_burst(target.global_position + Vector3(0, 0.8, 0))
		
	_spawn_floating_damage(target.global_position + Vector3(0, 1.2, 0), damage, is_crit)
	hud.update_target(target)
	
	var msg = "[" + skill_data.get("name") + "] causou " + str(damage) + " de dano!"
	if is_crit:
		msg = "[CRÍTICO!] " + msg
	hud.add_combat_log(msg)

func _on_item_shortcut_triggered(item_id: String) -> void:
	if player and player.inventory:
		for i in range(InventoryManager.MAX_SLOTS):
			var slot = player.inventory.slots[i]
			if slot != null and slot["id"] == item_id:
				player.inventory.use_or_equip(i)
				hud.add_system_message("Item usado da barra de atalhos: " + slot["data"].get("name"))
				break

func _spawn_soulshot_burst(pos: Vector3) -> void:
	var burst = SOULSHOT_BURST_SCENE.instantiate()
	add_child(burst)
	burst.global_position = pos

func _spawn_floating_damage(pos: Vector3, amount: int, is_crit: bool) -> void:
	var float_num = FLOAT_NUMBER_SCENE.instantiate()
	add_child(float_num)
	float_num.global_position = pos
	float_num.setup(amount, is_crit)
