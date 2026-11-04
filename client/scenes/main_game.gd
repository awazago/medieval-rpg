# res://client/scenes/main_game.gd
# Controlador Central da Cena de Jogo e Integração Cliente
extends Node3D

@onready var player: PlayerCharacter = $Player
@onready var hud: GameHUD = $HUD

func _ready() -> void:
	if player and hud:
		player.stats_updated.connect(hud.update_player_status)
		player.target_changed.connect(hud.update_target)
		player.soulshot_toggled.connect(hud.set_soulshot_active)
		
		# Emite estado inicial
		hud.update_player_status(
			player.current_hp, player.max_hp,
			player.current_mp, player.max_mp,
			player.current_cp, player.max_cp
		)
		hud.add_system_message("Pressione [Scroll do Mouse] para alternar entre 1ª Pessoa e 3ª Pessoa Livre.")
		hud.add_system_message("Pressione [Tab] para selecionar o monstro mais próximo.")
		hud.add_system_message("Pressione [F1] para ligar Soulshots. Clique com botão esquerdo para atacar.")
		hud.add_system_message("Pressione [I] para abrir/fechar o Inventário com controle de peso.")

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
		
	# Atualiza a barra de vida do alvo no HUD
	hud.update_target(target)
	
	# Mensagem de log no estilo Lineage II
	var log_msg = "Você causou " + str(damage) + " de dano a " + str(target.get("monster_name")) + "!"
	if is_crit:
		log_msg = "[DANO CRÍTICO!] " + log_msg
	if player.soulshots_enabled:
		log_msg = "[SOULSHOT] " + log_msg
		
	hud.add_combat_log(log_msg)
