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

### Crônica 2: A Chegada ao Continente (Níveis 20 ao 40) — Iniciada
* **Sprint 6 (Porto de Highstone, Rota Marítima & Porto de Giran):**
  * Píer de madeira com caravela 3D ("Vento de Aden") e NPC Capitão Drake (`highstone_harbor.tscn`).
  * Regra de acesso: Nível 20+ ou `ticket_continental_ship`.
  * Cena interativa de travessia do oceano com balanço dinâmico (`ocean_voyage.tscn`).
  * Chegada monumental ao Porto Imperial de Giran com NPC Oficial Lauren e Arco Triunfal (`giran_harbor.tscn`).
  * 9 suítes de testes de QA passando com 100% de sucesso (`tests/test_gameplay_systems.py`).

---

## 🚀 Próxima Missão / Próximos Passos Imediatos

O usuário solicitou avançar na **Camada Visual da Ilha do Alvorecer (Sprints 1 a 5)**:
Substituir o visual de protótipo (blocos e geometrias primitivas CSG) por elementos estéticos detalhados:
1. **Etapa 1:** Shaders de Terreno (mesclagem de grama estilizada, terra batida e caminhos de pedra) e Shader de Água Oceânica com ondas dinâmicas.
2. **Etapa 2:** Texturas PBR e modelos 3D medievais para a Vila de Highstone (pedras musgosas, madeira rústica, forja).
3. **Etapa 3:** Cripta Ancestral com iluminação volumétrica, runas brilhantes e sarcófagos detalhados.
4. **Etapa 4:** Modelos 3D com rig e animações esqueléticas para o personagem e NPCs (Idle, Run, Attack).

---

## 🧪 Comandos Úteis para o Novo Agente
* Rodar testes automatizados:
  ```bash
  python3 tests/test_gameplay_systems.py
  ```
* Iniciar servidor headless:
  ```bash
  godot --headless --server
  ```
* Arquitetura e Regras:
  Consulte [`docs/ARCHITECTURE/`](docs/ARCHITECTURE/) e [`docs/ROADMAP_EVOLUCAO_CONTINUA.md`](docs/ROADMAP_EVOLUCAO_CONTINUA.md).
