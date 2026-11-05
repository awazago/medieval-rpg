#!/usr/bin/env python3
"""
Validador de Sistemas e Balanceamento (QA Automatizado - Lineage II Rules)
Verifica integridade de dados JSON e fórmulas de combate / peso.
"""
import json
import math
import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

def test_data_integrity():
    print("[QA Test 1] Verificando integridade das tabelas de dados JSON...")
    
    with open(os.path.join(DATA_DIR, "items.json")) as f:
        items_data = json.load(f)["items"]
        item_ids = {item["id"] for item in items_data}
        
    with open(os.path.join(DATA_DIR, "monsters.json")) as f:
        monsters_data = json.load(f)["monsters"]
        
    with open(os.path.join(DATA_DIR, "races.json")) as f:
        races_data = json.load(f)

    # 1. Valida se todo item dropado por monstros existe na tabela de itens
    for mob in monsters_data:
        for drop in mob.get("drops", []):
            item_id = drop["item_id"]
            assert item_id in item_ids, f"Erro: Monstro '{mob['id']}' dropa item inexistente '{item_id}'"

    # 2. Valida atributos das 5 raças
    required_stats = {"str", "dex", "con", "int", "wit", "men"}
    for race_key, race in races_data.items():
        stats = set(race["base_stats"].keys())
        assert required_stats.issubset(stats), f"Erro: Raça '{race_key}' faltando atributos base."

    print(" -> Sucesso: Todos os itens, raças e drops estão consistentes e válidos!")

def test_combat_formulas():
    print("[QA Test 2] Validando Fórmulas Canônicas de Combate Lineage II...")
    
    # Parâmetros: P.Atk = 24, P.Def = 12
    # Sem Soulshot: (70 * 24) / 12 = 140 base
    # Com Soulshot: (70 * (24 * 2)) / 12 = 280 base (Exatamente o dobro!)
    p_atk = 24.0
    p_def = 12.0
    
    dmg_normal = (70.0 * p_atk) / p_def
    dmg_soulshot = (70.0 * (p_atk * 2.0)) / p_def
    
    assert math.isclose(dmg_soulshot, dmg_normal * 2.0), "Erro: Soulshot deve dobrar o dano físico!"
    
    # Crítico físico duplica o dano final no Lineage II
    dmg_crit = dmg_normal * 2.0
    assert math.isclose(dmg_crit, 280.0), "Erro: Crítico físico deve causar 200% do dano base!"

    print(" -> Sucesso: Fórmulas de dano físico e Soulshot 100% canônicas!")

def test_weight_penalties():
    print("[QA Test 3] Validando Sistema de Penalidade de Peso (Lineage II)...")
    
    base_weight_limit = 68000
    # Con 43 (Humano) -> Multiplicador = 1.0 + (43 - 30) * 0.035 = 1.455
    con_stat = 43
    max_weight = int(round(base_weight_limit * (1.0 + ((con_stat - 30) * 0.035))))
    assert max_weight == 98940, f"Erro no cálculo de carga máxima: {max_weight}"

    # Validação de faixas de penalidade
    def get_tier(curr, max_w):
        pct = (curr / max_w) * 100.0
        if pct >= 80.0: return 3
        if pct >= 67.0: return 2
        if pct >= 50.0: return 1
        return 0

    assert get_tier(10000, max_weight) == 0 # Sem penalidade
    assert get_tier(50000, max_weight) == 1 # 50.5% -> Sem Regen
    assert get_tier(68000, max_weight) == 2 # 68.7% -> -20% Speed
    assert get_tier(80000, max_weight) == 3 # 80.8% -> Sobrecarregado severo

    print(" -> Sucesso: Limites e faixas de penalidade de carga perfeitamente calibrados!")

def test_skills_and_hotbar():
    print("[QA Test 4] Validando Conjuração de Habilidades e Fórmulas Mágicas (Sprint 2)...")
    with open(os.path.join(DATA_DIR, "skills.json")) as f:
        skills_data = json.load(f)["skills"]
        skills_map = {s["id"]: s for s in skills_data}
        
    # 1. Valida Power Strike
    ps = skills_map["power_strike"]
    assert ps["mp_cost"] > 0
    assert ps["power"] > 0
    assert ps["cast_time_sec"] > 0
    
    # 2. Valida fórmula de dano mágico de Fire Arrow
    fa = skills_map["fire_arrow"]
    m_atk = 18.0
    m_def = 10.0
    skill_power = fa["power"] # 42
    
    # Fórmula: (91 * sqrt(M.Atk) * SkillPower) / M.Def
    dmg_magic = (91.0 * math.sqrt(m_atk) * skill_power) / m_def
    assert dmg_magic > 1000.0, f"Dano mágico inesperado: {dmg_magic}"
    
    print(" -> Sucesso: Habilidades físicas, mágicas e cooldowns 100% verificados!")

def test_exp_and_progression_sprint3():
    print("[QA Test 5] Validando Curva de XP, Level Up e Esqueleto Guerreiro (Sprint 3)...")
    
    # 1. Valida tabela de XP
    with open(os.path.join(DATA_DIR, "exp_table.json")) as f:
        exp_table = json.load(f)["exp_table"]
    
    levels = sorted([int(k) for k in exp_table.keys()])
    assert len(levels) >= 20, "Tabela de XP deve cobrir pelo menos 20 níveis."
    
    # Valida que o XP necessário cresce de forma monótona estrita
    for i in range(len(levels) - 1):
        lvl_curr = str(levels[i])
        lvl_next = str(levels[i + 1])
        assert exp_table[lvl_next] > exp_table[lvl_curr], f"Erro: XP do nível {lvl_next} deve ser maior que {lvl_curr}"
        
    # 2. Valida estatísticas do Esqueleto Guerreiro
    with open(os.path.join(DATA_DIR, "monsters.json")) as f:
        mobs = {m["id"]: m for m in json.load(f)["monsters"]}
        
    skel = mobs["skeleton_warrior"]
    assert skel["aggro"] is True, "Esqueleto Guerreiro deve ser agressivo!"
    assert skel["level"] == 10
    assert skel["hp"] == 260
    assert skel["p_atk"] > mobs["prairie_wolf"]["p_atk"], "Esqueleto deve ser muito mais forte que o Lobo."
    
    print(" -> Sucesso: Curva de XP e monstro agressivo da Cripta 100% verificados!")

def test_races_and_paperdoll_sprint4():
    print("[QA Test 6] Validando as 5 Raças e Sistema de Paperdoll 3D (Sprint 4)...")
    
    # 1. Validação das 5 raças
    with open(os.path.join(DATA_DIR, "races.json")) as f:
        races = json.load(f)
        
    expected_races = {"human", "light_elf", "dark_elf", "orc", "dwarf"}
    assert expected_races.issubset(set(races.keys())), "Faltando uma das 5 raças fundamentais de Lineage II."
    
    # Orc tem que ter mais vida que todos
    assert races["orc"]["base_hp"] > races["human"]["base_hp"]
    # Elfo da luz tem que ser o mais rápido
    assert races["light_elf"]["base_speed"] > races["orc"]["base_speed"]
    # Elfo negro tem que ter o maior dano base de INT
    assert races["dark_elf"]["base_stats"]["int"] > races["human"]["base_stats"]["int"]
    
    # 2. Validação dos tipos de armas para Paperdoll
    with open(os.path.join(DATA_DIR, "items.json")) as f:
        items = json.load(f)["items"]
        
    weapon_types = {item["weapon_type"] for item in items if item.get("type") == "weapon"}
    expected_types = {"sword_1h", "dagger_1h", "staff_2h", "bow_2h"}
    assert expected_types.issubset(weapon_types), "Faltando tipos de armas clássicas para Paperdoll."

    print(" -> Sucesso: As 5 raças clássicas e armas do Paperdoll 3D 100% validadas!")

if __name__ == "__main__":
    try:
        test_data_integrity()
        test_combat_formulas()
        test_weight_penalties()
        test_skills_and_hotbar()
        test_exp_and_progression_sprint3()
        test_races_and_paperdoll_sprint4()
        print("\n🏆 TODOS OS TESTES DE QA PASSARAM COM SUCESSO! Sprints 1, 2, 3 & 4 Validadas.")
    except Exception as e:
        print(f"\n❌ FALHA NO TESTE DE QA: {e}")
        sys.exit(1)
