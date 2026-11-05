# Project Chronicles: Aethelgard (Medieval MMORPG)

Um MMORPG 3D medieval clássico inspirado nos pilares de jogabilidade, progressão, estética e atmosfera de **Lineage II**, projetado desde o primeiro dia com arquitetura cliente-servidor autoritativa.

---

## 🌟 Características Principais
- **Perspectiva Híbrida Dinâmica:** Câmera imersiva em 1ª pessoa com transição suave para 3ª pessoa orbital com zoom contínuo via scroll do mouse.
- **Visual Clássico High/Dark Fantasy:** Estética marcante, armaduras brilhantes com graus de equipamento (No-Grade, D, C, B, A, S) e efeitos visuais característicos de combate (*Soulshots/Spiritshots*).
- **5 Raças Iniciais:** Humanos, Elfos da Luz, Elfos Negros, Orcs e Anões.
- **Progressão Robusta:** Curva de XP balanceada, especializações de classe, guildas/clãs estruturados e sistema de encantamento (+1 a +16) com risco de quebra.
- **Mapa Inicial Contido (Ilha do Alvorecer):** Zona de tutorial e progressão do nível 1 ao 20 com cidade pacífica, masmorras e mini-boss de grupo.
- **Preparado para Servidor:** Separação estrita de lógica de servidor (servidor autoritativo headless) e cliente gráfico.

---

## 📂 Documentação e Especificações
- [🎮 Guia do Godot Engine 4 (Instalação, Execução e Controles)](docs/GUIA_GODOT.md)
- [📜 Plano Diretor de Evolução Contínua (Roadmap das Crônicas)](docs/ROADMAP_EVOLUCAO_CONTINUA.md)
- [Papéis dos Agentes de IA](AGENTS.md)
- [GDD 01 - Visão Geral e Mitologia do Mundo](docs/GDD/01_VISAO_GERAL_E_LORE.md)
- [GDD 02 - Raças, Atributos e Classes](docs/GDD/02_RACAS_E_CLASSES.md)
- [GDD 03 - Sistemas de Jogo e Mecânicas Centrais](docs/GDD/03_SISTEMAS_DE_JOGO.md)
- [GDD 04 - Mapa Inicial e Zonas de Expansão](docs/GDD/04_MUNDO_E_MAPAS.md)
- [Arquitetura de Rede Cliente-Servidor](docs/ARCHITECTURE/01_CLIENT_SERVER.md)

---

## 🚀 Como Abrir e Jogar Rápido
1. Baixe o [Godot Engine 4.x](https://godotengine.org/download) (versão padrão, ~80 MB).
2. Abra o Godot, clique em **Import** e selecione o arquivo `project.godot` deste repositório.
3. Pressione **F5** (ou Play ▶️) para jogar:
   - Crie seu herói escolhendo entre as **5 Raças** (*Humano, Elfos, Orc, Anão*).
   - Use o **Scroll do Mouse** para transitar entre 1ª pessoa e 3ª pessoa.
   - Pressione **`I`** para abrir o inventário e ver as armas 3D empunhadas na mão direita.
   - Pressione **`Tab`** para travar a mira e **`1` a `4`** para usar habilidades com Soulshots (`F1`).
