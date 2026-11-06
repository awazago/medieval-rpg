# 📜 AGENT HANDOFF: Project Chronicles (Aethelgard)

> **Documento de Continuidade e Passagem de Bastão para Agentes no Remote Project do Antigravity.**  
> Data da Última Atualização: 05 de Novembro de 2026.

---

## 🎯 Identidade do Projeto
* **Nome:** Project Chronicles: Aethelgard
* **Gênero:** MMORPG 3D Medieval de Alta Fantasia (inspirado nos sistemas canônicos de *Lineage II*).
* **Engine:** Godot Engine 4 (GDScript, Forward+ 3D, Servidor Autoritativo ENet).
* **Repositório Git:** `https://github.com/awazago/medieval-rpg.git` (Branch: `main`).

---

## 🗺️ Progresso Concluído até o Momento

### Crônica 1: A Ilha do Alvorecer (Dawn Isle - Níveis 1 ao 20) — 100% Concluída
* **Sprint 1 (Fundação de Gameplay):**
  * Inventário com 24 slots e regras canônicas de peso baseadas em Constituição (`CON`).
  * Drops físicos 3D no chão com coluna de luz (`item_drop_3d.tscn`) e tecla `E` para coleta.
  * NPC Sentinela Marcus com diálogo e primeira missão tutorial.
  * Câmera híbrida (1ª pessoa com zoom out contínuo até 3ª pessoa orbital).
* **Sprint 2 (Vila de Highstone & Combate):**
  * Monólito de Aetherstone pulsante, forja com brasas e paliçadas (`highstone_village.tscn`).
  * Soulshots com partículas douradas (`F1`) dobrando o dano físico.
  * Números de dano flutuantes (amarelo normal, vermelho negrito crítico).
  * Hotbar de habilidades (1 a 8) e Barra de Conjuração central.
* **Sprint 3 (Cripta Ancestral & Servidor Dedicado):**
  * Ruínas góticas com braseiros de fogo verde espectral (`ancient_crypt_ruins.tscn`).
  * Esqueleto Guerreiro agressivo Nível 10 (`skeleton_warrior.tscn`).
  * Tabela de progressão de 20 níveis com efeito visual de Level Up (pilar dourado ascendente).
  * Servidor dedicado headless executável via `--server`.
* **Sprint 4 (As 5 Raças & Paperdoll 3D):**
  * Tela interativa de Seleção/Criação com as 5 raças canônicas (Humano, Elfo, Elfo Negro, Orc e Anão) com atributos STR, DEX, CON, INT, WIT, MEN.
  * Sistema de Paperdoll 3D físico: espada, adaga, cajado e arco empunhados na mão direita (`RightHandSocket`) e troca de materiais de armadura.
* **Sprint 5 (Raid Boss Valthor, Forja & Armazém):**
  * Raid Boss Valthor Nv. 20 (4.800 HP) com AoE *Earthquake Stomp* e barra de Raid com moldura dourada.
  * Loja do Ferreiro Torvald (compra e venda com Adena).
  * Armazém Geral com cofre para estocar itens e aliviar peso.
* **Trilha Sonora & Efeitos Sonoros:**
  * 3 músicas orquestradas adaptativas (Vila de Highstone, Cripta Ancestral, Batalha de Valthor).
  * 6 SFX (ativação de Soulshot, impacto, level up, corte de lâmina, conjuração mágica, coleta de moedas).
  * Autoload `AudioManager` com crossfade.

### Crônica 2 & Camada Visual: A Ilha do Alvorecer Revitalizada
* **Sprint 6 (Porto de Highstone, Rota Marítima & Porto de Giran):**
  * Píer de madeira com caravela 3D ("Vento de Aden") e NPC Capitão Drake (`highstone_harbor.tscn`).
  * Regra de acesso: Nível 20+ ou `ticket_continental_ship`.
  * Cena interativa de travessia do oceano com balanço dinâmico (`ocean_voyage.tscn`).
  * Chegada monumental ao Porto Imperial de Giran com NPC Oficial Lauren e Arco Triunfal (`giran_harbor.tscn`).
* **Camada Visual - Etapa 1: Shaders de Terreno, Grama e Água Oceânica (CONCLUÍDA ✅):**
  * `client/shaders/terrain.gdshader` + `terrain_mat.tres`: mesclagem tri-camada procedural (grama vibrante dual-tone, terra batida e caminhos de pedra) com detecção de declive/rocha e micro-rugosidade PBR.
  * `client/shaders/grass.gdshader` + `grass_mat.tres`: shader de vegetação com balanço de vento procedural no `vertex`, atenuação de raiz fixa, gradiente vertical de cor e translucidez de luz solar (`BACKLIGHT`).
  * `client/scenes/environment/stylized_grass_patch.tscn`: tufo de grama estilizada com 3 lâminas cruzadas distribuídas pela ilha e vila de Highstone (`FoliageField`).
  * `client/shaders/ocean_water.gdshader` + `ocean_water_mat.tres`: água oceânica com ondas Gerstner 3D dinâmicas, espuma de crista, detecção de contato/costa via `depth_texture`, gradiente de profundidade raso/profundo e reflexo Fresnel.
  * Integração completa em `main_game.tscn`, `highstone_harbor.tscn` e `ocean_voyage.tscn`.
* **Camada Visual - Etapa 2: Vila de Highstone PBR & Arquitetura Medieval (CONCLUÍDA ✅):**
  * `client/shaders/mossy_stone.gdshader` + `mossy_stone_mat.tres`: alvenaria medieval de pedras antigas com acúmulo orgânico de musgo baseado em altura e orientação voltada para o topo.
  * `client/shaders/rustic_wood.gdshader` + `rustic_wood_mat.tres`: madeira rústica com veios longitudinais e nós de carpintaria medieval para vigas e paliçadas.
  * `client/shaders/forge_embers.gdshader` + `forge_embers_mat.tres`: brasas incandescentes com pulsação de respiração térmica e gradiente carvão/vermelho/amarelo/branco solar.
  * `client/shaders/aether_crystal.gdshader` + `aether_crystal_mat.tres`: cristal arcano sapphire com reflexão facetada, efeito Fresnel e runas místicas pulsantes.
  * `client/scenes/environment/highstone_village.tscn`:
    * **Forja de Torvald:** chaminé de pedra, tina de têmpera d'água, bancada de ferramentas, bigorna de ferro sobre tora de madeira e braseiro ardente.
    * **Armazém Geral de Randall:** construção com balcão de atendimento, telhado rústico, pilhas de caixotes e barris de mantimentos.
    * **Monólito de Aetherstone:** base de pedra escalonada de 2 níveis, cristal central imponente com fragmentos orbitantes.
    * **Paliçada da Vila:** postes de madeira com ameias/estacas afiadas, plataformas de vigia nas torres e braseiros medievais de ferro fundido.
* **Camada Visual - Etapa 3: Cripta Ancestral & Catacumba Gótica (CONCLUÍDA ✅):**
  * `client/shaders/crypt_gothic_stone.gdshader` + `crypt_gothic_stone_mat.tres`: pedra sepulcral escura desgastada com incisões de runas necromânticas pulsando em verde espectral.
  * `client/shaders/spectral_flame.gdshader` + `spectral_flame_mat.tres`: chamas verdes esmeralda/turquesa com turbulência vertical no vertex e alta energia emissiva.
  * `client/shaders/spectral_mist.gdshader` + `spectral_mist_mat.tres`: névoa espectral rasteira translúcida com desvanecimento suave de profundidade via `depth_texture`.
  * `client/scenes/environment/ancient_crypt_ruins.tscn`:
    * **Portal Gótico Monumental:** pilares canelados de 5.6m com bases, capitéis e topo ogival gótico com rastilho de grades de ferro.
    * **Sarcófagos dos Cavaleiros Tombados:** sepulturas esculpidas com tampas chanfradas e runas de selamento.
    * **Braseiros de Ferro Fundido:** pedestais góticos com caldeirões emitindo chamas verdes e iluminação espacial espectral.
    * **Escadaria Subterrânea:** degraus de descida em pedra escura para o covil do Raid Boss Valthor.
  * 12 suítes de testes de QA passando com 100% de sucesso (`tests/test_gameplay_systems.py`).

* **Camada Visual - Etapa 4: Rig Humanoide, Articulação 3D & Ciclos de Animação (CONCLUÍDA ✅):**
  * `client/scenes/character/humanoid_character.tscn` & `humanoid_character.gd`:
    * Modelo 3D articulado com tronco couraçado, ombreiras, cinto com fivela dourada, elmo com visor, braços e pernas articulados com pés e mãos.
    * `RightHandSocket` para o sistema de Paperdoll físico de armas (espadas, adagas, cajados, arcos).
    * `AnimationPlayer` com 4 animações fluidas integradas:
      * `"idle"`: ciclo de respiração e equilíbrio postural.
      * `"run"`: passada bípede natural, balanço alternado de braços e pernas e quique vertical do tronco.
      * `"attack"`: recuo de golpe, arco de corte dinâmico com rotação de tronco e recuperação.
      * `"cast"`: postura de canalização arcana elevando ambos os braços e impulsão mágica para a frente.
  * Integração completa em `player_character.gd` (transições automáticas de movimento e chamadas de ataque/magia) e `main_game.gd`.
  * Instanciado no Jogador, em todos os NPCs (`NPC_SentinelMarcus`, `NPC_BlacksmithTorvald`, `NPC_WarehouseRandall`) e na tela de seleção de raças (`character_select.tscn`).
* **Camada Visual - Etapa 5: Polimento de Partículas (VFX) & Iluminação Forward+ (CONCLUÍDA ✅):**
  * `client/scenes/vfx/ambient_sun_motes.tscn`: motes de poeira dourada flutuando com suavidade sob a luz do sol de Highstone.
  * `client/scenes/vfx/chimney_embers.tscn`: faíscas incandescentes e brasas subindo da chaminé da forja de Torvald.
  * `client/scenes/vfx/crypt_spores.tscn`: esporos espectrais verdes e partículas mágicas levitando na entrada da Cripta.
  * Calibração de `WorldEnvironment`: SSAO (raio 1.6, intensidade 2.2), SSIL (iluminação indireta Forward+), Glow Bloom (intensidade 0.85, bloom 0.2), Volumetric Fog atmosférico e Tonemap ACES cinematográfico.
  * Calibração de `DirectionalLight3D`: luz solar dourada quente (`Color(1.0, 0.96, 0.88)`), sombras suaves (`shadow_bias = 0.03`, `directional_shadow_blend_splits = true`).
  * Calibração de `DirectionalLight3D`: luz solar dourada quente (`Color(1.0, 0.96, 0.88)`), sombras suaves (`shadow_bias = 0.03`, `directional_shadow_blend_splits = true`).
  * 14 suítes de testes de QA passando com 100% de sucesso (`tests/test_gameplay_systems.py`).
* **Crônica 2 - Sprint 7: A Metrópole de Giran, Grau D & Private Stores (CONCLUÍDA ✅):**
  * `data/items.json`: expansão completa com equipamentos e suprimentos de **Grau D (D-Grade)**:
    * *Espada Bastarda* (84 P.Atk, 54 M.Atk, 3 Soulshots D)
    * *Arco Élfico* (112 P.Atk, 50 M.Atk, 4 Soulshots D)
    * *Crucifixo da Bênção* (45 P.Atk, 89 M.Atk, 3 Spiritshots D)
    * *Adaga de Mithril* (72 P.Atk, 48 M.Atk, 2 Soulshots D)
    * *Túnica de Brigantina* (68 P.Def) e *Túnica de Mithril* (48 P.Def)
    * Consumíveis D: *Soulshot: D-Grade*, *Spiritshot: D-Grade*, *Cristal D* e *Pergaminho de Teletransporte: Giran*.
  * `client/scenes/environment/giran_city.tscn` & `giran_city.gd`:
    * Grande Praça Comercial de Giran pavimentada com lajes imperiais (80x80m).
    * Fonte Monumental Imperial com bacia de mármore em camadas, anel decorativo dourado e coluna central esculpida.
    * Muralhas de pedra fortificada com ameias e Portão Sul conectando à estrada do Porto de Giran.
    * Tendas medievais de feirantes com toldos vermelhos e azuis.
    * NPCs imperiais integrados:
      * `NPC_GiranTraderValeria` (Vendedora de Armas e Armaduras D-Grade).
      * `NPC_GrandMasterKallum` (Grão-Mestre preparando os heróis para a 1ª Mudança de Classe).
      * `NPC_WarehouseChiefMoke` (Chefe do Armazém com cofres imperiais).
      * Feirantes sentados simuladores (`NPC_StoreSellerGoran` e `NPC_StoreBuyerLyra`).
  * **Sistema Canônico de Lojas Pessoais (Private Stores - Lineage II):**
    * `client/scripts/economy/private_store_manager.gd`: gerenciador com enum `StoreType { SELL, BUY }`, validação de inventário, transferências atômicas de Adena e itens e checagem de sobrecarga.
    * `client/scenes/ui/private_store_sign_3d.tscn` & `private_store_sign_3d.gd`: plaquinha flutuante 3D estilo billboard clássico (`[VENDA]` em amarelo/dourado e `[COMPRA]` em ciano/azul).
    * `client/ui/private_store_window.gd`: interface com abas de Vender/Comprar, seleção de itens, definição de preços e modo de navegação externa para negociar com terceiros.
    * `client/scenes/character/humanoid_character.tscn` & `humanoid_character.gd`: animação e postura sentada `"sit_shop"` integrada com travamento de locomoção.
    * Atalho `[P]` no HUD e teclado para abrir/fechar o painel comercial.
  * 15 suítes de testes de QA passando com 100% de sucesso (`tests/test_gameplay_systems.py`).

* **Camada Visual - Upgrade Definitivo de Modelos 3D (.glb) e Rigs Esqueletais (CONCLUÍDA ✅):**
  * Substituição completa de malhas procedurais CSG por modelos 3D poligonais texturizados (.glb/.gltf) com UV mapping e esqueleto skinned:
    * `client/assets/models/characters/`:
      * `Knight.glb` (Armadura de placas, elmo, capa, espada, 76 animações esqueletais e sockets de mão).
      * `Mage.glb` (Vestes místicas, chapéu de mago, capa, 76 animações).
      * `Rogue.glb` & `Rogue_Hooded.glb` (Traje de couro reforçado, capuz, mantos de ladino).
      * `Barbarian.glb` (Peitoral bárbaro, elmo com chifres, peles nórdicas).
      * `Skeleton_Warrior.glb`, `Skeleton_Mage.glb`, `Skeleton_Minion.glb` (Monstros esqueléticos completos).
    * `client/assets/models/weapons/`:
      * `sword_1handed.gltf`, `dagger.gltf`, `staff.gltf`, `crossbow_1handed.gltf`, escudos e acessórios com texturas dedicadas.
  * `client/scripts/character/humanoid_character.gd`:
    * Dicionário `MODEL_PRESETS` para troca a quente de malhas.
    * Mapeamento de animações `ANIMATION_MAP` (`idle` -> `Idle`, `run` -> `Running_A`, `attack` -> `1H_Melee_Attack_Slice_Horizontal`, `cast` -> `Spellcast_Shoot`, `sit_shop` -> `Sit_Floor_Idle`).
    * Conexão com o socket esqueletal nativo do modelo (`handslot.r`).
  * `client/scripts/player_character.gd`:
    * Associação das 5 raças clássicas aos modelos poligonais (Humano: Knight, Elfo da Luz: Mage, Elfo Negro: Rogue, Orc: Barbarian, Anão: Knight com escala 0.78).
  * `client/scripts/character_select.gd`:
    * Alternância instantânea dos modelos 3D no preview em tempo real ao selecionar as raças.
  * `server/skeleton_warrior.tscn` & `server/boss_valthor.tscn`:
    * Instanciação direta do modelo 3D `Skeleton_Warrior.glb`, com escala 1.7x e iluminação de aura carmesim no Raid Boss Valthor.
  * 16 suítes de testes de QA passando com 100% de sucesso (`tests/test_gameplay_systems.py`).

* **Refatoração Geral de Gráficos (Master Graphics Refactor - CONCLUÍDA ✅):**
  * **Cenários & Arquitetura 3D Poligonal:**
    * Vila de Highstone (`highstone_village.tscn`): Ferraria de Torvald (`building_blacksmith_blue.gltf`), Armazém de Randall (`building_home_A_blue.gltf`), Poço central da vila (`building_well_blue.gltf`), Taberna da colina (`building_tavern_blue.gltf`), casas residenciais, pilhas de caixas/barris texturizados e estandartes no portão da paliçada.
    * Cripta Ancestral (`ancient_crypt_ruins.tscn`): Pilares arquitetônicos góticos (`pillar.gltf.glb`), colunas caneladas (`column.gltf.glb`), arcadas esculpidas (`wall_arched.gltf.glb`), tochas de ferro nas paredes com luz espectral e baú de ouro antigo (`chest_gold.glb`).
    * Metrópole de Giran (`giran_city.tscn`): Castelo Imperial em escala 3.5x no horizonte norte (`building_castle_blue.gltf`), Templo de Einhasad (`building_church_blue.gltf`), Taberna e Guilda marcial (`building_tavern_blue.gltf`), Pavilhão comercial do mercado (`building_market_blue.gltf`), colunata monumental circundando a praça e estandartes imperiais vermelhos.
  * **Natureza & Vegetação Densa:**
    * Bosques densos de carvalhos e pinheiros 3D (`trees_A_large.gltf`), árvores isoladas ao longo das estradas (`tree_single_A.gltf`, `tree_single_B.gltf`) e maciços rochosos (`rock_single_B.gltf`) integrados na Ilha do Alvorecer (`main_game.tscn`) e na Vila de Highstone.
  * **Iluminação & Atmosfera Cinemática Forward+:**
    * Screen Space Reflections (SSR) ativado com 64 steps em `main_game.tscn` e `giran_city.tscn` para reflexos de luz em poças e no piso de mármore imperial.
    * Screen Space Indirect Lighting (SSIL) e Screen Space Ambient Occlusion (SSAO) recalibrados para contraste e oclusão de sombras suaves.
    * Volumetric Fog com densidade atmosférica, dispersão frontal de luz (anisotropia 0.28) gerando raios crepusculares (god rays).
    * Curva de céu estilizada com transição do azul profundo ao dourado quente do horizonte.
  * **Interface do Usuário (HUD/UI) Estilo Canônico Lineage II:**
    * `client/ui/hud.gd`: método `_apply_lineage2_theme()` criando `StyleBoxFlat` para barras de CP (âmbar dourado), HP (rubi carmesim), MP (safira elétrico), Target (vermelho escarlate), Boss Raid (moldura dourada real) e EXP (ciano luminoso).
    * Estilização de painéis flutuantes (Inventário, Lojas, Armazém, Diálogos, Hotbar) com fundo obsidiana translúcido e bordas chanfradas em bronze/ouro envelhecido.
  * **Estabilização de Scripts e Transições de Cena (CONCLUÍDA ✅):**
    * `client/scripts/character_select.gd`: corrigido fluxo de transição utilizando `get_tree().change_scene_to_file("res://client/scenes/main_game.tscn")`, eliminando instâncias duplicadas no nó `root`, colisões de câmeras no debugger e referências nulas.
    * `shared/game_data.gd`: adicionadas variáveis globais de persistência `selected_character_name` e `selected_race_id`.
    * `client/scenes/main_game.gd`: inicialização confiável do jogador e HUD em `_ready()` com dados de raça e nome.
    * Validação e recálculo automatizado de `load_steps` exatos em todos os 24 arquivos `.tscn` do projeto, eliminando warnings e erros do parser do Godot.
  * **Fidelidade Visual Realista de Alta Fantasia (Lineage II Authentic) (CONCLUÍDA ✅):**
    * **Proporções Anatômicas Heroicas (Regra das 8 Cabeças):** eliminação total do aspecto chibi/cartoon (bobblehead) através de reescalonamento esbelto e atlético das silhuetas (`Vector3(0.86, 1.32, 0.86)` para Humanos, `Vector3(0.80, 1.38, 0.80)` para Elfos, `Vector3(1.22, 1.42, 1.22)` para Orcs), escala da cabeça reduzida para 0.68 no `Skeleton3D` e reescalonamento dinâmico de todos os keyframes de escala nas animações.
    * **Limpeza e Fixação de Paperdoll Esqueletal:** ocultação de armas e escudos embutidos duplicados que poluiam os modelos (`Knight.glb`, etc.) e conexão direta das armas de alta resolução ao socket esqueletal dinâmico da mão direita (`handslot.r`).
    * **Materiais PBR de Alta Fantasia:** armaduras medievais de metal forjado com reflexos de aço e ouro nobre, capas reais em veludo com iluminação de borda suave (`rim light`) em carmesim e azul imperial.
    * **Cenários & Paleta de Aden:** cores florestais e de terra batida mais profundas e realistas em `terrain_mat.tres` e `grass_mat.tres`, além de iluminação de estúdio no preview de seleção de raças com rim light azulada.
  * 18 suítes de testes de QA passando com 100% de sucesso (`tests/test_gameplay_systems.py`).

---

## 🗺️ Status Geral do Projeto

| Módulo / Camada | Progresso | Status |
| :--- | :--- | :--- |
| **Crônica 1: Sprints 1 a 5 (Sistemas Centrais de Gameplay)** | 100% | Concluída ✅ |
| **Crônica 1: Camada Visual (Sprints 1 a 5 / Etapas 1 a 5)** | 100% | Concluída ✅ |
| **Crônica 2: Sprint 6 (Porto de Highstone, Rota Marítima, Porto de Giran)** | 100% | Concluída ✅ |
| **Crônica 2: Sprint 7 (Metrópole de Giran, Praça Comercial & Private Stores)** | 100% | Concluída ✅ |
| **Modelos 3D Reais (.glb), Rigs Esqueletais & Paperdoll Texturizado** | 100% | Concluída ✅ |
| **Refatoração Geral de Gráficos (Cenários 3D, Natureza, SSR/Fog, UI Lineage II)** | 100% | Concluída ✅ |
| **Estabilidade de Scripts & Visual Realista Lineage II (8 Cabeças, PBR, Capas)** | 100% | Concluída ✅ |
| **Crônica 2: Sprint 8 (1ª Mudança de Classe - Nível 20 & Class Transfer Quests)** | 0% | Próxima Missão 🚀 |

---

## 🚀 Próxima Missão / Próximos Passos Imediatos

Avançar na **Crônica 2 (A Chegada ao Continente)**:
1. **Sprint 8:** Primeira Mudança de Classe (Class Transfer - Nível 20):
   * Quests de graduação com os Mestres de Giran (Gladiator, Knight, Sorcerer, Necromancer, Hawkeye, Bishop).
   * Novas habilidades ativas e passivas específicas de cada profissão.
   * Remoção da penalidade de proficiência de Grau D para personagens graduados.
2. **Sprint 9:** Sistema de Clãs Completo (Criação de Clã, Crests 16x12 e Níveis de Guilda 1 a 5).

---

## 🧪 Comandos Úteis para o Novo Agente
* Rodar testes automatizados (17 suítes de QA):
  ```bash
  python3 tests/test_gameplay_systems.py
  ```
* Iniciar servidor headless:
  ```bash
  godot --headless --server
  ```
* Arquitetura e Regras:
  Consulte [`docs/ARCHITECTURE/`](docs/ARCHITECTURE/) e [`docs/ROADMAP_EVOLUCAO_CONTINUA.md`](docs/ROADMAP_EVOLUCAO_CONTINUA.md).


