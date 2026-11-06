# Project Chronicles: Aethelgard (Medieval MMORPG)

Um MMORPG 3D medieval clássico inspirado nos pilares de jogabilidade, progressão, estética e atmosfera de **Lineage II**, desenvolvido na **Godot Engine 4 (Forward+)** com arquitetura cliente-servidor autoritativa.

---

## 🌟 Características Principais

* **Perspectiva Híbrida Dinâmica:** Câmera imersiva em 1ª pessoa com transição contínua para 3ª pessoa orbital via scroll do mouse.
* **Modelos 3D Poligonais & Rigs Esqueletais (.glb):** Substituição de blocos procedurais por modelos 3D texturizados com esqueleto articulado e animações fluidas integradas (Knight, Mage, Rogue, Barbarian, Esqueleto Guerreiro e Raid Boss Valthor).
* **5 Raças Canônicas com Troca em Tempo Real:** Humanos, Elfos da Luz, Elfos Negros, Orcs e Anões com atributos `STR, DEX, CON, INT, WIT, MEN` e troca instantânea de modelo 3D no preview de criação.
* **Sistema de Paperdoll 3D Texturizado:** Espadas, adagas, cajados arcanos e bestas 3D empunhados fisicamente nos sockets das mãos dos personagens (`handslot.r`).
* **Shaders PBR & Gráficos Forward+:** 
  * Terreno tri-camada procedural (grama, terra e pedra com declive automático).
  * Grama viva com balanço de vento procedural e luz translúcida (`BACKLIGHT`).
  * Oceano dinâmico com ondas Gerstner 3D, reflexo Fresnel e espuma de contato (`depth_texture`).
  * Vila medieval com pedras musgosas, madeira rústica, forja com brasas incandescentes e monólito arcano de Aetherstone.
  * Cripta Ancestral gótica com névoa espectral rasteira, tochas de fogo verde e sarcófagos esculpidos.
* **Combate Físico & Mágico Canônico:** Soulshots dobrando dano físico (`F1`), taxa de acerto crítico, CP (Combat Points), barras de cast, números flutuantes de dano e barra de Raid Boss com moldura dourada.
* **Economia Clássica, Lojas Pessoais & Peso:** 
  * Inventário de 24 slots, capacidade de carga calibrada pela Constituição (`CON`), loja do Ferreiro Torvald e Armazém Geral (Randall).
  * **Sistema Canônico de Private Store (Lineage II):** heróis montam lojas no chão da feira com animação sentada (`sit_shop`), plaquinha flutuante 3D (`[VENDA]` em amarelo e `[COMPRA]` em ciano), definição de preço unitário em Adena e transferência atômica com validação de sobrecarga.
* **Metrópole Comercial de Giran & Grau D (D-Grade):**
  * Praça monumental de 80x80m com Fonte Imperial em mármore, muralhas fortificadas, portão sul e tendas de feirantes.
  * Armas e armaduras D-Grade (*Espada Bastarda*, *Arco Élfico*, *Crucifixo da Bênção*, *Adaga de Mithril*, *Túnica de Brigantina*, *Túnica de Mithril*), *Soulshots D*, *Spiritshots D* e *Cristais D*.
  * NPCs de Giran: Mercadora Valeria, Grão-Mestre Kallum (preparando para a 1ª Mudança de Classe) e Chefe Moke do Armazém.
* **Trilha Sonora Medieval & Áudio Espacial:** Músicas adaptativas com crossfade e efeitos sonoros característicos (Soulshots, cortes, magias, level up, moedas).
* **Servidor Dedicado Autoritativo:** Execução headless via ENet com `--server` e sincronização de estado.

---

## 🗺️ Progresso e Status do Projeto

| Módulo / Crônica | Status | Detalhes |
| :--- | :---: | :--- |
| **Crônica 1: Sprints 1 a 5 (Gameplay & Fundação)** | **100% Concluída ✅** | Inventário, Soulshots, Cripta, 5 Raças, Paperdoll, Boss Valthor, Loja e Armazém. |
| **Crônica 1: Camada Visual (Etapas 1 a 5)** | **100% Concluída ✅** | Shaders de Terreno, Grama, Água, Vila PBR, Cripta Gótica, Rig Animado e Partículas VFX. |
| **Crônica 2: Sprint 6 (Porto & Rota Marítima)** | **100% Concluída ✅** | Porto de Highstone, Caravela "Vento de Aden", Travessia do Oceano e Porto Imperial de Giran. |
| **Crônica 2: Sprint 7 (Metrópole de Giran & Private Stores)** | **100% Concluída ✅** | Praça comercial livre, sistema de Private Store (Venda/Compra) com plaquinha 3D e itens Grau D. |
| **Refatoração Visual Realista Lineage II (8 Cabeças, PBR & Capas)** | **100% Concluída ✅** | Anatomia heroica esbelta (sem aspecto chibi), materiais PBR de aço/ouro, capas nobres e shaders de Aden. |
| **Estabilidade de Scripts & Transição de Cenas** | **100% Concluída ✅** | Transição limpa via `change_scene_to_file`, recálculo exato de `load_steps` em 24 `.tscn` e zero warnings. |
| **Crônica 2: Sprint 8 (1ª Mudança de Classe - Nv. 20)** | **Próxima Missão 🚀** | Quests de graduação de classe com os Mestres de Giran, novas skills e proficiência Grau D. |

---

## 📂 Documentação do Projeto

* [📜 Passagem de Bastão para Agentes (Handoff)](docs/AGENT_HANDOFF.md)
* [🎮 Guia do Godot Engine 4 (Instalação, Execução e Controles)](docs/GUIA_GODOT.md)
* [🗺️ Plano Diretor de Evolução Contínua (Roadmap das Crônicas)](docs/ROADMAP_EVOLUCAO_CONTINUA.md)
* [🤖 Papéis dos Agentes de IA](AGENTS.md)
* [GDD 01 - Visão Geral e Mitologia do Mundo](docs/GDD/01_VISAO_GERAL_E_LORE.md)
* [GDD 02 - Raças, Atributos e Classes](docs/GDD/02_RACAS_E_CLASSES.md)
* [GDD 03 - Sistemas de Jogo e Mecânicas Centrais](docs/GDD/03_SISTEMAS_DE_JOGO.md)
* [GDD 04 - Mapa Inicial e Zonas de Expansão](docs/GDD/04_MUNDO_E_MAPAS.md)
* [Arquitetura de Rede Cliente-Servidor](docs/ARCHITECTURE/01_CLIENT_SERVER.md)

---

## 🚀 Como Abrir e Jogar

1. Baixe o [Godot Engine 4.x](https://godotengine.org/download) (versão padrão, ~80 MB).
2. Abra o Godot, clique em **Import** e selecione o arquivo `project.godot` deste repositório.
3. Pressione **F5** (ou Play ▶️) para iniciar:
   * **Criação de Personagem:** Escolha seu herói entre as 5 raças clássicas na cena inicial.
   * **W, A, S, D:** Movimentação fluida com animação de corrida (`run`) e quique postural.
   * **Scroll do Mouse:** Alterne continuamente entre 1ª pessoa e 3ª pessoa orbital.
   * **Tab:** Seleciona o monstro ou NPC mais próximo.
   * **Botão Esquerdo do Mouse:** Ataca o alvo com animação de corte de arma.
   * **F1:** Liga / desliga os Soulshots para dobrar o dano físico.
   * **Teclas 1 a 4:** Executa habilidades na Hotbar (`Power Strike`, `Fire Arrow`, `Lesser Heal`).
   * **I:** Abre/fecha a janela de Inventário com controle estrito de peso.
   * **P:** Abre/fecha a janela de **Loja Pessoal (Private Store)** para vender ou comprar itens na feira de Giran.
   * **F:** Interage com NPCs próximos (Sentinela Marcus, Ferreiro Torvald, Mercadora Valeria, Grão-Mestre Kallum, Feirantes sentados).

---

## 🧪 Suíte de Testes Automatizados (QA)

Execute os testes de validação das fórmulas de combate, itens, raças, balanceamento e integridade dos shaders/cenas 3D:

```bash
python3 tests/test_gameplay_systems.py
```

*Status atual: **15/15 testes passando com 100% de sucesso.***

