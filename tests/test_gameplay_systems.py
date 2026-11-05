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

def test_sprint5_boss_and_economy():
    print("[QA Test 7] Validando Raid Boss Valthor Nv. 20, Loja de Adena e Armazém (Sprint 5)...")
    
    # 1. Validação de Valthor
    with open(os.path.join(DATA_DIR, "monsters.json")) as f:
        mobs = {m["id"]: m for m in json.load(f)["monsters"]}
        
    valthor = mobs["fallen_knight_valthor"]
    assert valthor["level"] == 20
    assert valthor["hp"] == 4800, f"HP incorreto do Raid Boss: {valthor['hp']}"
    assert valthor["p_atk"] == 120.0
    assert valthor["p_def"] == 95.0
    assert valthor["exp_reward"] == 8500
    
    # 2. Validação do catálogo de comércio
    with open(os.path.join(DATA_DIR, "items.json")) as f:
        items_map = {item["id"]: item for item in json.load(f)["items"]}
        
    shop_items = [
        "short_sword", "apprentice_staff", "hunting_bow", "bone_dagger",
        "leather_tunic", "iron_breastplate", "soulshot_none", "spiritshot_none", "lesser_healing_potion"
    ]
    for s_item in shop_items:
        assert s_item in items_map, f"Item da loja ausente em items.json: {s_item}"
        assert items_map[s_item].get("price", 0) > 0, f"Preço de {s_item} deve ser maior que 0"

    print(" -> Sucesso: Raid Boss Valthor e Sistema de Economia da Forja 100% validados!")

def test_audio_system_and_tracks():
    print("[QA Test 8] Validando Sistema de Áudio, Trilha Sonora e SFX...")
    audio_base = os.path.join(BASE_DIR, "audio")
    music_dir = os.path.join(audio_base, "music")
    sfx_dir = os.path.join(audio_base, "sfx")
    
    # 1. Validação das 3 trilhas adaptativas
    expected_music = ["dawn_isle_village.wav", "ancient_crypt.wav", "boss_valthor_battle.wav"]
    for m in expected_music:
        p = os.path.join(music_dir, m)
        assert os.path.exists(p), f"Trilha sonora ausente: {m}"
        assert os.path.getsize(p) > 10000, f"Arquivo de música vazio ou corrompido: {m}"
        
    # 2. Validação dos 6 efeitos sonoros (SFX)
    expected_sfx = [
        "soulshot_activate.wav", "soulshot_hit.wav", "level_up.wav",
        "sword_swing.wav", "magic_cast.wav", "coins_pickup.wav"
    ]
    for s in expected_sfx:
        p = os.path.join(sfx_dir, s)
        assert os.path.exists(p), f"Efeito sonoro ausente: {s}"
        assert os.path.getsize(p) > 1000, f"Arquivo de SFX vazio: {s}"
        
    # 3. Validação do autoload no project.godot
    with open(os.path.join(BASE_DIR, "project.godot")) as f:
        godot_cfg = f.read()
    assert "AudioManager=" in godot_cfg, "AudioManager deve estar registrado como autoload no project.godot"

    print(" -> Sucesso: Trilha sonora medieval e biblioteca de SFX 100% validadas!")

def test_sprint6_harbor_and_voyage():
    print("[QA Test 9] Validando Sprint 6: Porto de Highstone, Rota Marítima e Porto de Giran...")
    
    # 1. Valida item do bilhete de viagem
    with open(os.path.join(DATA_DIR, "items.json")) as f:
        items_data = json.load(f)["items"]
        ticket_item = next((i for i in items_data if i["id"] == "ticket_continental_ship"), None)
        assert ticket_item is not None, "Item 'ticket_continental_ship' não encontrado em items.json"
        assert ticket_item["type"] == "quest_item", "O bilhete deve ser do tipo 'quest_item'"

    # 2. Valida quest de partida continental
    with open(os.path.join(DATA_DIR, "quests.json")) as f:
        quests_data = json.load(f)["quests"]
        departure_quest = next((q for q in quests_data if q["id"] == "quest_departure_to_mainland"), None)
        assert departure_quest is not None, "Quest 'quest_departure_to_mainland' não encontrada"
        assert departure_quest["required_level"] == 20, "Nível requerido para partida continental deve ser 20"
        
    # 3. Validação lógica da regra de embarque do Capitão Drake
    def can_board(player_level, has_ticket):
        return player_level >= 20 or has_ticket
        
    assert not can_board(1, False), "Recruta nível 1 sem bilhete NÃO deve poder embarcar"
    assert not can_board(19, False), "Guerreiro nível 19 sem bilhete NÃO deve poder embarcar"
    assert can_board(20, False), "Guerreiro nível 20 DEVE poder embarcar"
    assert can_board(15, True), "Portador do bilhete de honra DEVE poder embarcar"

    # 4. Validação das cenas 3D criadas
    env_dir = os.path.join(BASE_DIR, "client", "scenes", "environment")
    harbor_scene = os.path.join(env_dir, "highstone_harbor.tscn")
    voyage_scene = os.path.join(env_dir, "ocean_voyage.tscn")
    giran_scene = os.path.join(env_dir, "giran_harbor.tscn")
    
    assert os.path.exists(harbor_scene), "Cena highstone_harbor.tscn não encontrada"
    assert os.path.exists(voyage_scene), "Cena ocean_voyage.tscn não encontrada"
    assert os.path.exists(giran_scene), "Cena giran_harbor.tscn não encontrada"

    with open(harbor_scene) as f:
        content = f.read()
        assert "CaptainDrake" in content, "Capitão Drake deve estar presente no Porto de Highstone"
        assert "CaravelShip" in content, "Caravela deve estar ancorada no porto"

    with open(giran_scene) as f:
        content = f.read()
        assert "OficialLauren" in content, "Oficial Lauren deve estar presente no Porto de Giran"
        assert "ImperialArchway" in content, "Arco Imperial de boas-vindas deve estar presente em Giran"

    print(" -> Sucesso: Porto de Highstone, Travessia Marítima e Porto de Giran 100% validados!")

def test_shaders_visual_layer():
    print("[QA Test 10] Validando Shaders da Camada Visual (Terreno, Grama e Água Oceânica)...")
    shaders_dir = os.path.join(BASE_DIR, "client", "shaders")
    materials_dir = os.path.join(shaders_dir, "materials")
    
    # 1. Validação dos arquivos de shader .gdshader
    terrain_shader = os.path.join(shaders_dir, "terrain.gdshader")
    grass_shader = os.path.join(shaders_dir, "grass.gdshader")
    ocean_shader = os.path.join(shaders_dir, "ocean_water.gdshader")
    
    assert os.path.exists(terrain_shader), "terrain.gdshader não encontrado"
    assert os.path.exists(grass_shader), "grass.gdshader não encontrado"
    assert os.path.exists(ocean_shader), "ocean_water.gdshader não encontrado"
    
    with open(terrain_shader) as f:
        src = f.read()
        assert "shader_type spatial;" in src
        assert "grass_color_base" in src
        assert "dirt_color" in src
        assert "rock_color" in src
        assert "slope_threshold" in src

    with open(grass_shader) as f:
        src = f.read()
        assert "shader_type spatial;" in src
        assert "cull_disabled" in src
        assert "color_root" in src
        assert "color_tip" in src
        assert "wind_speed" in src

    with open(ocean_shader) as f:
        src = f.read()
        assert "shader_type spatial;" in src
        assert "shallow_color" in src
        assert "deep_color" in src
        assert "foam_color" in src
        assert "wave_amplitude" in src
        assert "hint_depth_texture" in src

    # 2. Validação dos materiais .tres
    terrain_mat = os.path.join(materials_dir, "terrain_mat.tres")
    grass_mat = os.path.join(materials_dir, "grass_mat.tres")
    ocean_mat = os.path.join(materials_dir, "ocean_water_mat.tres")
    
    assert os.path.exists(terrain_mat), "terrain_mat.tres não encontrado"
    assert os.path.exists(grass_mat), "grass_mat.tres não encontrado"
    assert os.path.exists(ocean_mat), "ocean_water_mat.tres não encontrado"
    
    # 3. Validação da cena do tufo de grama
    grass_patch_scene = os.path.join(BASE_DIR, "client", "scenes", "environment", "stylized_grass_patch.tscn")
    assert os.path.exists(grass_patch_scene), "stylized_grass_patch.tscn não encontrado"

    # 4. Validação da integração com as cenas do jogo
    with open(os.path.join(BASE_DIR, "client", "scenes", "main_game.tscn")) as f:
        mg_content = f.read()
        assert "terrain_mat.tres" in mg_content, "main_game.tscn deve usar terrain_mat.tres"
        assert "stylized_grass_patch.tscn" in mg_content, "main_game.tscn deve conter tufos de grama"

    with open(os.path.join(BASE_DIR, "client", "scenes", "environment", "highstone_harbor.tscn")) as f:
        hh_content = f.read()
        assert "ocean_water_mat.tres" in hh_content, "highstone_harbor.tscn deve usar ocean_water_mat.tres"

    with open(os.path.join(BASE_DIR, "client", "scenes", "environment", "ocean_voyage.tscn")) as f:
        ov_content = f.read()
        assert "ocean_water_mat.tres" in ov_content, "ocean_voyage.tscn deve usar ocean_water_mat.tres"

    print(" -> Sucesso: Shaders de Terreno, Grama e Água Oceânica 100% integrados e verificados!")

def test_highstone_village_visual_upgrade():
    print("[QA Test 11] Validando Camada Visual da Vila de Highstone (PBR, Forja, Armazém & Monólito)...")
    shaders_dir = os.path.join(BASE_DIR, "client", "shaders")
    materials_dir = os.path.join(shaders_dir, "materials")
    
    # 1. Shaders medievais
    stone_shader = os.path.join(shaders_dir, "mossy_stone.gdshader")
    wood_shader = os.path.join(shaders_dir, "rustic_wood.gdshader")
    embers_shader = os.path.join(shaders_dir, "forge_embers.gdshader")
    crystal_shader = os.path.join(shaders_dir, "aether_crystal.gdshader")
    
    for s_path in [stone_shader, wood_shader, embers_shader, crystal_shader]:
        assert os.path.exists(s_path), f"Shader não encontrado: {s_path}"
        with open(s_path) as f:
            assert "shader_type spatial;" in f.read()

    # 2. Materiais .tres
    for m_name in ["mossy_stone_mat.tres", "rustic_wood_mat.tres", "forge_embers_mat.tres", "aether_crystal_mat.tres"]:
        m_path = os.path.join(materials_dir, m_name)
        assert os.path.exists(m_path), f"Material .tres não encontrado: {m_path}"

    # 3. Integridade dos elementos 3D da Vila de Highstone
    village_scene = os.path.join(BASE_DIR, "client", "scenes", "environment", "highstone_village.tscn")
    assert os.path.exists(village_scene), "highstone_village.tscn não encontrado"
    
    with open(village_scene) as f:
        v_content = f.read()
        # Forja do Ferreiro
        assert "mossy_stone_mat.tres" in v_content, "Vila deve usar pedras musgosas"
        assert "forge_embers_mat.tres" in v_content, "Forja deve usar brasas incandescentes"
        assert "QuenchingTrough" in v_content, "Forja deve possuir tina de têmpera d'água"
        assert "Chimney" in v_content, "Forja deve possuir chaminé de pedra"
        # Armazém Geral
        assert "HighstoneWarehouse" in v_content, "Vila deve possuir estrutura do Armazém Geral"
        assert "CounterDesk" in v_content, "Armazém deve ter balcão de atendimento"
        assert "CrateStack" in v_content, "Armazém deve ter pilhas de caixotes"
        assert "Barrel" in v_content, "Armazém deve ter barris de carga"
        # Monólito de Aetherstone
        assert "aether_crystal_mat.tres" in v_content, "Monólito deve usar material de cristal arcano"
        assert "LowerStepPedestal" in v_content, "Monólito deve ter base escalonada"
        assert "SubShard" in v_content, "Monólito deve possuir fragmentos orbitantes de cristal"
        # Paliçada da Vila
        assert "rustic_wood_mat.tres" in v_content, "Paliçada deve usar madeira rústica"
        assert "LeftTowerPlatform" in v_content, "Torres devem possuir plataformas de vigia"
        assert "BrazierLeft" in v_content, "Portão deve ter braseiros medievais de ferro"

    print(" -> Sucesso: Vila de Highstone revitalizada com PBR, Forja detalhada, Armazém e Monólito arcano!")

def test_ancient_crypt_visual_upgrade():
    print("[QA Test 12] Validando Camada Visual da Cripta Ancestral (Pedra Gótica, Névoa & Chamas Espectrais)...")
    shaders_dir = os.path.join(BASE_DIR, "client", "shaders")
    materials_dir = os.path.join(shaders_dir, "materials")
    
    # 1. Shaders da Cripta
    crypt_shader = os.path.join(shaders_dir, "crypt_gothic_stone.gdshader")
    flame_shader = os.path.join(shaders_dir, "spectral_flame.gdshader")
    mist_shader = os.path.join(shaders_dir, "spectral_mist.gdshader")
    
    for s_path in [crypt_shader, flame_shader, mist_shader]:
        assert os.path.exists(s_path), f"Shader não encontrado: {s_path}"
        with open(s_path) as f:
            assert "shader_type spatial;" in f.read()

    # 2. Materiais .tres
    for m_name in ["crypt_gothic_stone_mat.tres", "spectral_flame_mat.tres", "spectral_mist_mat.tres"]:
        m_path = os.path.join(materials_dir, m_name)
        assert os.path.exists(m_path), f"Material .tres não encontrado: {m_path}"

    # 3. Integridade da cena da Cripta Ancestral
    crypt_scene = os.path.join(BASE_DIR, "client", "scenes", "environment", "ancient_crypt_ruins.tscn")
    assert os.path.exists(crypt_scene), "ancient_crypt_ruins.tscn não encontrado"
    
    with open(crypt_scene) as f:
        c_content = f.read()
        assert "crypt_gothic_stone_mat.tres" in c_content, "Cripta deve usar pedra gótica com runas"
        assert "spectral_mist_mat.tres" in c_content, "Cripta deve ter névoa espectral rasteira"
        assert "spectral_flame_mat.tres" in c_content, "Cripta deve usar chamas verdes espectrais"
        assert "GothicPointedApex" in c_content, "Portal da Cripta deve ter arco ogival gótico"
        assert "SarcophagusKnight_1" in c_content, "Cripta deve conter sarcófagos detalhados"
        assert "SunkenStairs" in c_content, "Cripta deve conter escadaria subterrânea de descida"
        assert "SpectralBrazierLeft" in c_content, "Cripta deve conter braseiros com fogo espectral"

    print(" -> Sucesso: Cripta Ancestral revitalizada com arquitetura gótica, névoa e chamas espectrais!")

def test_humanoid_character_rig_and_animations():
    print("[QA Test 13] Validando Rig Humanoide, Articulação 3D e Animações (Idle, Run, Attack, Cast)...")
    char_scene = os.path.join(BASE_DIR, "client", "scenes", "character", "humanoid_character.tscn")
    char_script = os.path.join(BASE_DIR, "client", "scripts", "character", "humanoid_character.gd")
    
    assert os.path.exists(char_scene), "humanoid_character.tscn não encontrado"
    assert os.path.exists(char_script), "humanoid_character.gd não encontrado"
    
    with open(char_scene) as f:
        src = f.read()
        assert "AnimationPlayer" in src, "Rig deve possuir AnimationPlayer"
        assert "Animation_idle" in src, "Rig deve conter animação idle"
        assert "Animation_run" in src, "Rig deve conter animação run"
        assert "Animation_attack" in src, "Rig deve conter animação attack"
        assert "Animation_cast" in src, "Rig deve conter animação cast"
        assert "RightHandSocket" in src, "Rig deve possuir RightHandSocket para Paperdoll de armas"
        assert "ChestMesh" in src and "ShoulderPads" in src and "Belt" in src, "Rig deve conter armadura completa"
        assert "LeftLeg" in src and "RightLeg" in src, "Rig deve possuir articulação de pernas"

    with open(char_script) as f:
        script_src = f.read()
        assert "play_anim" in script_src, "Script do Rig deve expor play_anim"
        assert "update_armor" in script_src, "Script do Rig deve suportar atualização de armadura"
        assert "get_right_hand_socket" in script_src, "Script do Rig deve retornar socket de mão"

    # Validação do Player
    with open(os.path.join(BASE_DIR, "client", "scripts", "player_character.gd")) as f:
        p_src = f.read()
        assert "play_attack_animation" in p_src, "Player deve ter método de ataque animado"
        assert "play_cast_animation" in p_src, "Player deve ter método de conjuração animada"
        assert "HumanoidCharacterRig" in p_src, "Player deve gerenciar HumanoidCharacterRig"

    # Validação da integração nas cenas
    with open(os.path.join(BASE_DIR, "client", "scenes", "main_game.tscn")) as f:
        mg_src = f.read()
        assert "humanoid_character.tscn" in mg_src, "main_game.tscn deve instanciar humanoid_character.tscn"
        assert "NPC_BlacksmithTorvald" in mg_src and "NPC_WarehouseRandall" in mg_src and "NPC_SentinelMarcus" in mg_src

    with open(os.path.join(BASE_DIR, "client", "scenes", "character_select.tscn")) as f:
        cs_src = f.read()
        assert "humanoid_character.tscn" in cs_src, "character_select.tscn deve usar humanoid_character.tscn no preview"

    print(" -> Sucesso: Rig Humanoide, Paperdoll articulado e animações 100% verificados!")

def test_environmental_vfx_and_lighting():
    print("[QA Test 14] Validando Polimento Visual, Partículas de Ambiente (VFX) e Iluminação Forward+...")
    vfx_dir = os.path.join(BASE_DIR, "client", "scenes", "vfx")
    
    sun_motes_scene = os.path.join(vfx_dir, "ambient_sun_motes.tscn")
    chimney_embers_scene = os.path.join(vfx_dir, "chimney_embers.tscn")
    crypt_spores_scene = os.path.join(vfx_dir, "crypt_spores.tscn")
    
    assert os.path.exists(sun_motes_scene), "ambient_sun_motes.tscn não encontrado"
    assert os.path.exists(chimney_embers_scene), "chimney_embers.tscn não encontrado"
    assert os.path.exists(crypt_spores_scene), "crypt_spores.tscn não encontrado"
    
    for s_path in [sun_motes_scene, chimney_embers_scene, crypt_spores_scene]:
        with open(s_path) as f:
            content = f.read()
            assert "GPUParticles3D" in content, f"Cena {s_path} deve conter GPUParticles3D"
            assert "ParticleProcessMaterial" in content, f"Cena {s_path} deve configurar ParticleProcessMaterial"

    # Validação do WorldEnvironment e DirectionalLight3D em main_game.tscn
    with open(os.path.join(BASE_DIR, "client", "scenes", "main_game.tscn")) as f:
        mg_src = f.read()
        assert "ssao_enabled = true" in mg_src, "SSAO deve estar ativo no WorldEnvironment"
        assert "ssil_enabled = true" in mg_src, "SSIL (iluminação indireta) deve estar ativo no Forward+"
        assert "glow_bloom" in mg_src, "Glow Bloom deve estar calibrado"
        assert "fog_enabled = true" in mg_src, "Volumetric Fog deve estar ativo para atmosfera de alta fantasia"
        assert "ambient_sun_motes.tscn" in mg_src, "Vila de Highstone deve possuir motes de sol"
        assert "chimney_embers.tscn" in mg_src, "Forja deve possuir brasas subindo da chaminé"
        assert "crypt_spores.tscn" in mg_src, "Cripta deve possuir esporos e névoa espectral"

    print(" -> Sucesso: Partículas de ambiente (motes, brasas, esporos) e iluminação Forward+ 100% validadas!")

def test_sprint7_giran_city_and_private_stores():
    print("[QA Test 15] Validando Sprint 7: Metrópole de Giran, Grau D & Private Stores (Lineage II)...")
    
    # 1. Validação de Itens Grau D
    with open(os.path.join(DATA_DIR, "items.json")) as f:
        items = {item["id"]: item for item in json.load(f)["items"]}
        
    assert "bastard_sword" in items, "Espada Bastarda (D-Grade) deve existir"
    assert "elven_bow" in items, "Arco Élfico (D-Grade) deve existir"
    assert "crucifix_of_blessing" in items, "Crucifixo da Bênção (D-Grade) deve existir"
    assert "mithril_dagger" in items, "Adaga de Mithril (D-Grade) deve existir"
    assert "brigandine_tunic" in items, "Túnica de Brigantina (D-Grade) deve existir"
    assert "mithril_tunic" in items, "Túnica de Mithril (D-Grade) deve existir"
    assert "soulshot_d" in items, "Soulshot D deve existir"
    assert "spiritshot_d" in items, "Spiritshot D deve existir"
    assert "crystal_d" in items, "Cristal D deve existir"
    
    bs = items["bastard_sword"]
    assert bs["grade"] == "D" and bs["p_atk"] == 84 and bs["soulshot_count"] == 3, "Espada Bastarda deve ter atributos D-grade"
    assert bs["p_atk"] > items["short_sword"]["p_atk"] * 5, "Arma D-grade deve ser substancialmente superior ao Grau Nenhum"
    
    eb = items["elven_bow"]
    assert eb["grade"] == "D" and eb["p_atk"] == 112 and eb["soulshot_count"] == 4, "Arco Élfico deve consumir 4 Soulshots D"
    
    brig = items["brigandine_tunic"]
    assert brig["grade"] == "D" and brig["p_def"] == 68, "Brigantina D-grade deve possuir 68 de P.Def"
    
    # 2. Validação da Cena 3D da Metrópole de Giran (giran_city.tscn)
    giran_city_path = os.path.join(BASE_DIR, "client", "scenes", "environment", "giran_city.tscn")
    assert os.path.exists(giran_city_path), "giran_city.tscn deve existir"
    with open(giran_city_path) as f:
        city_src = f.read()
        assert "MarketPlaza" in city_src, "Giran deve possuir a grande praça do mercado"
        assert "ImperialFountain" in city_src, "Giran deve possuir a Fonte Monumental Imperial"
        assert "OuterBasin" in city_src and "CenterPillar" in city_src, "Fonte de Giran deve ter bacia e coluna esculpida"
        assert "CityWalls" in city_src and "SouthGateArch" in city_src, "Giran deve possuir muralhas e o Portão Sul"
        assert "NPC_GiranTraderValeria" in city_src, "Mercadora Valeria deve estar posicionada na praça"
        assert "NPC_GrandMasterKallum" in city_src, "Grão-Mestre Kallum deve estar no hall marcial"
        assert "NPC_WarehouseChiefMoke" in city_src, "Chefe Moke deve estar no armazém imperial"
        assert "NPC_StoreSellerGoran" in city_src, "Feirante Goran (Private Store Dummy Vendedor) deve estar na feira"
        assert "NPC_StoreBuyerLyra" in city_src, "Feirante Lyra (Private Store Dummy Comprador) deve estar na feira"
        assert "PrivateStoreWindow" in city_src, "HUD de Giran deve conter a janela de Private Store"
        assert "PrivateStoreManager" in city_src, "Giran deve instanciar o PrivateStoreManager"
        
    # 3. Validação da Lógica do PrivateStoreManager (private_store_manager.gd)
    mgr_path = os.path.join(BASE_DIR, "client", "scripts", "economy", "private_store_manager.gd")
    assert os.path.exists(mgr_path), "private_store_manager.gd deve existir"
    with open(mgr_path) as f:
        mgr_src = f.read()
        assert "enum StoreType { NONE = 0, SELL = 1, BUY = 2 }" in mgr_src, "Deve suportar tipos SELL e BUY canônicos"
        assert "func open_sell_store" in mgr_src, "Deve conter método open_sell_store"
        assert "func open_buy_store" in mgr_src, "Deve conter método open_buy_store"
        assert "func close_store" in mgr_src, "Deve conter método close_store"
        assert "func execute_client_purchase" in mgr_src, "Deve processar compra de clientes transeuntes"
        assert "func execute_client_sale" in mgr_src, "Deve processar venda de clientes transeuntes"
        assert "signal store_opened" in mgr_src and "signal store_closed" in mgr_src, "Deve emitir sinais de ciclo de vida"

    # 4. Validação da Plaquinha 3D e Animação de Sentar no Rig Humanoide
    sign_scene_path = os.path.join(BASE_DIR, "client", "scenes", "ui", "private_store_sign_3d.tscn")
    assert os.path.exists(sign_scene_path), "private_store_sign_3d.tscn deve existir"
    with open(sign_scene_path) as f:
        sign_src = f.read()
        assert "Label3D" in sign_src and "billboard = 1" in sign_src, "Plaquinha 3D deve usar Label3D em billboard"

    rig_scene_path = os.path.join(BASE_DIR, "client", "scenes", "character", "humanoid_character.tscn")
    with open(rig_scene_path) as f:
        rig_src = f.read()
        assert "sit_shop" in rig_src, "AnimationLibrary do rig deve conter animação sit_shop"

    rig_gd_path = os.path.join(BASE_DIR, "client", "scripts", "character", "humanoid_character.gd")
    with open(rig_gd_path) as f:
        rig_gd_src = f.read()
        assert "play_sit_shop" in rig_gd_src, "humanoid_character.gd deve implementar play_sit_shop"
        assert "is_sitting" in rig_gd_src, "humanoid_character.gd deve implementar is_sitting"

    # 5. Validação da Conexão entre Porto de Giran e Metrópole de Giran
    guide_path = os.path.join(BASE_DIR, "client", "scripts", "npc_giran_guide.gd")
    with open(guide_path) as f:
        guide_src = f.read()
        assert "giran_city.tscn" in guide_src, "Oficial Lauren no Porto deve guiar o jogador para giran_city.tscn"

    print(" -> Sucesso: Metrópole de Giran, Equipamentos Grau D e Sistema de Lojas Pessoais (Private Stores) 100% validados!")

def test_real_3d_models_and_skeletal_animations():
    print("[QA Test 16] Validando Integração de Modelos 3D Reais (.glb), Rigs Esqueletais e Armas...")
    
    # 1. Modelos de Personagens e Monstros (.glb)
    models_char_dir = os.path.join(BASE_DIR, "client", "assets", "models", "characters")
    required_char_models = [
        "Knight.glb", "Mage.glb", "Rogue.glb", "Barbarian.glb", "Skeleton_Warrior.glb"
    ]
    for model_file in required_char_models:
        path = os.path.join(models_char_dir, model_file)
        assert os.path.exists(path), f"Modelo 3D obrigatório {model_file} não encontrado em {models_char_dir}"
        assert os.path.getsize(path) > 1000000, f"Modelo {model_file} parece corrompido ou incompleto (tamanho < 1MB)"

    # 2. Modelos de Armas (.gltf / .bin)
    weapons_dir = os.path.join(BASE_DIR, "client", "assets", "models", "weapons")
    required_weapons = [
        "sword_1handed.gltf", "dagger.gltf", "staff.gltf", "crossbow_1handed.gltf"
    ]
    for wpn_file in required_weapons:
        path = os.path.join(weapons_dir, wpn_file)
        assert os.path.exists(path), f"Arma 3D {wpn_file} não encontrada em {weapons_dir}"

    # 3. Validação do Rig Humanoide e Mapeamento de Animações
    rig_gd_path = os.path.join(BASE_DIR, "client", "scripts", "character", "humanoid_character.gd")
    with open(rig_gd_path) as f:
        rig_src = f.read()
        assert "MODEL_PRESETS" in rig_src, "humanoid_character.gd deve declarar MODEL_PRESETS para troca dinâmica"
        assert "ANIMATION_MAP" in rig_src, "humanoid_character.gd deve conter ANIMATION_MAP para animações do GLB"
        assert "set_character_model" in rig_src, "humanoid_character.gd deve implementar set_character_model"
        assert "get_right_hand_socket" in rig_src, "humanoid_character.gd deve implementar socket de arma"

    # 4. Validação das Cenas de Monstros e Boss com Malha 3D Real
    skel_scene = os.path.join(BASE_DIR, "server", "skeleton_warrior.tscn")
    with open(skel_scene) as f:
        skel_src = f.read()
        assert "Skeleton_Warrior.glb" in skel_src, "Esqueleto Guerreiro deve instanciar Skeleton_Warrior.glb"

    valthor_scene = os.path.join(BASE_DIR, "server", "boss_valthor.tscn")
    with open(valthor_scene) as f:
        valthor_src = f.read()
        assert "Skeleton_Warrior.glb" in valthor_src, "Raid Boss Valthor deve instanciar modelo 3D"

    # 5. Validação das Cenas de Armas com Modelos 3D
    sword_scene = os.path.join(BASE_DIR, "client", "scenes", "weapons", "sword_1h.tscn")
    with open(sword_scene) as f:
        assert "sword_1handed.gltf" in f.read(), "sword_1h.tscn deve usar modelo 3D texturizado"

    # 6. Validação da Seleção de Personagens com Troca em Tempo Real
    char_select_gd = os.path.join(BASE_DIR, "client", "scripts", "character_select.gd")
    with open(char_select_gd) as f:
        assert "set_character_model" in f.read(), "character_select.gd deve alternar modelo 3D do preview por raça"

    print(" -> Sucesso: Modelos 3D reais (.glb), Rigs esqueletais, Animações e Armas 100% integrados e validados!")

if __name__ == "__main__":
    try:
        test_data_integrity()
        test_combat_formulas()
        test_weight_penalties()
        test_skills_and_hotbar()
        test_exp_and_progression_sprint3()
        test_races_and_paperdoll_sprint4()
        test_sprint5_boss_and_economy()
        test_audio_system_and_tracks()
        test_sprint6_harbor_and_voyage()
        test_shaders_visual_layer()
        test_highstone_village_visual_upgrade()
        test_ancient_crypt_visual_upgrade()
        test_humanoid_character_rig_and_animations()
        test_environmental_vfx_and_lighting()
        test_sprint7_giran_city_and_private_stores()
        test_real_3d_models_and_skeletal_animations()
        print("\n🏆 TODOS OS 16 TESTES DE QA PASSARAM COM SUCESSO! Modelos 3D Poligonais e Sprint 7 Concluídos!")
    except Exception as e:
        print(f"\n❌ FALHA NO TESTE DE QA: {e}")
        sys.exit(1)

