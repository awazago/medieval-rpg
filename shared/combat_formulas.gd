# res://shared/combat_formulas.gd
# Fórmulas matemáticas de combate baseadas nos parâmetros e curvas clássicas de Lineage II
class_name CombatFormulas
extends RefCounted

# Multiplicador canônico de ataque físico Lineage II
const PHYSICAL_DAMAGE_CONSTANT: float = 70.0
# Multiplicador canônico de ataque mágico Lineage II
const MAGICAL_DAMAGE_CONSTANT: float = 91.0

## Cálculo de Dano Físico
## Retorna um dicionário: {"damage": int, "is_critical": bool}
static func calculate_physical_damage(
	attacker_p_atk: float,
	target_p_def: float,
	attacker_dex: int,
	weapon_crit_rate: int,
	soulshot_active: bool = false,
	skill_power: float = 0.0
) -> Dictionary:
	var effective_p_atk: float = attacker_p_atk
	if soulshot_active:
		effective_p_atk *= 2.0 # Efeito canônico de Soulshot (dobra o P.Atk)
		
	# Chance de crítico físico: escala com DEX e com o crit_rate da arma
	var crit_chance: float = (weapon_crit_rate * (attacker_dex / 30.0)) * 0.1 # Escala de 0.0 a 1.0
	var is_critical: bool = randf() < clampf(crit_chance, 0.04, 0.50) # Teto de 50% de crítico
	
	# Fórmula base: (70 * (P.Atk + SkillPower)) / P.Def
	var total_atk: float = effective_p_atk + skill_power
	var base_damage: float = (PHYSICAL_DAMAGE_CONSTANT * total_atk) / maxf(target_p_def, 1.0)
	
	# Variação randômica aleatória (Damage Variance de 5%)
	var variance: float = randf_range(0.95, 1.05)
	var final_damage: float = base_damage * variance
	
	if is_critical:
		final_damage *= 2.0 # Crítico dobra o dano no Lineage II
		
	return {
		"damage": maxi(1, int(round(final_damage))),
		"is_critical": is_critical
	}

## Cálculo de Dano Mágico
static func calculate_magical_damage(
	attacker_m_atk: float,
	target_m_def: float,
	attacker_wit: int,
	skill_power: float,
	spiritshot_active: bool = false
) -> Dictionary:
	var effective_m_atk: float = attacker_m_atk
	if spiritshot_active:
		effective_m_atk *= 4.0 # Spiritshot quadruplica o M.Atk base para magias
		
	# Chance de crítico mágico: escala com WIT
	var crit_chance: float = (attacker_wit / 100.0) * 0.35
	var is_critical: bool = randf() < clampf(crit_chance, 0.02, 0.30)
	
	# Fórmula: (91 * sqrt(M.Atk) * SkillPower) / M.Def
	var base_damage: float = (MAGICAL_DAMAGE_CONSTANT * sqrt(maxf(effective_m_atk, 1.0)) * skill_power) / maxf(target_m_def, 1.0)
	var variance: float = randf_range(0.90, 1.10)
	var final_damage: float = base_damage * variance
	
	if is_critical:
		final_damage *= 3.0 # Crítico mágico triplica o dano
		
	return {
		"damage": maxi(1, int(round(final_damage))),
		"is_critical": is_critical
	}
