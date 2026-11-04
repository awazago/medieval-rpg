# Arquitetura Técnica: Modelo Cliente-Servidor Autoritativo

## 1. Visão Geral da Arquitetura
Para garantir que o jogo seja seguro contra trapaças (speedhack, no-clip, item duping) e preparado para suportar centenas de jogadores simultâneos em servidores dedicados, adotamos o modelo **Servidor Autoritativo com Previsão do Cliente (Client-Side Prediction & Server Reconciliation)**.

```
+-------------------------------------------------------------------+
|                        SERVIDOR AUTORITATIVO                      |
|                                                                   |
|   +-------------------+  +-----------------+  +---------------+   |
|   | Simulação Física  |  | Lógica de Jogo  |  |  Banco/State  |   |
|   | e Espacial (Tick) |  | (Dano, Skills,  |  |  (Postgres/   |   |
|   |                   |  |  Quests, Drops) |  |   SQLite)     |   |
|   +---------+---------+  +--------+--------+  +-------+-------+   |
|             ^                     ^                   ^           |
+-------------|---------------------|-------------------|-----------+
              | Protocolo UDP/WebSocket (Pacotes Binários/JSON)
              v
+-------------------------------------------------------------------+
|                         CLIENTE DE JOGO                           |
|                                                                   |
|   +-------------------+  +-----------------+  +---------------+   |
|   | Input & Câmera    |  | Renderização 3D |  | HUD & UI      |   |
|   | (1ª / 3ª Pessoa)  |  | Shaders & Áudio |  | Inventário &  |   |
|   |                   |  |                 |  | Chat          |   |
|   +-------------------+  +-----------------+  +---------------+   |
+-------------------------------------------------------------------+
```

---

## 2. Escolha da Engine e Tecnologias Recomendadas

Para atingir a qualidade gráfica e estilo de Lineage II com facilidade de execução headless (servidor rodando sem placa de vídeo na nuvem):

### Opção A (Recomendada): **Godot Engine 4.x (C# / GDScript)**
- **Por que é ideal:**
  - Suporte nativo a exportação de **Servidor Headless** leve (consome menos de 200MB de RAM por instância).
  - Renderizador Vulkan/Forward+ com suporte a iluminação moderna, shaders estilizados e PBR.
  - Netcode embutido de alto desempenho via UDP (ENet) com RPCs e replicação de nós.
  - 100% livre de royalties e código aberto.

### Opção B: **Unreal Engine 5**
- **Vantagens:** O Lineage II clássico foi feito na Unreal Engine 2. A UE5 oferece gráficos de última geração nativos e sistema de replicação de rede consagrado.
- **Desvantagens:** Requisitos de hardware pesados e servidores dedicados exigem instâncias com mais poder computacional.

### Opção C: **Cliente WebGL/Three.js/Babylon + Servidor Node.js/Go**
- **Vantagens:** O jogo roda diretamente no navegador sem instalação.
- **Desvantagens:** Performance gráfica e física 3D mais limitadas para um MMORPG denso.

---

## 3. Protocolo de Comunicação e Pacotes
- **Tickrate do Servidor:** 20 a 30 ticks por segundo (ótimo para MMORPG com combate clássico).
- **Pacotes Essenciais:**
  - `C2S_MOVE_REQUEST`: Jogador envia intenção de movimento / clique no mapa.
  - `S2C_ENTITY_UPDATE`: Servidor envia posições interpoladas de monstros e outros jogadores dentro do raio de visão (*Area of Interest*).
  - `C2S_USE_SKILL`: Envia tentativa de conjuração com validação de alcance, cooldown e mana pelo servidor.
  - `S2C_COMBAT_RESULT`: Servidor confirma acerto, dano numérico, crítico e debuffs.

---

## 4. Estrutura de Pastas do Repositório
```
medieval-rpg/
├── AGENTS.md                   # Papéis dos agentes de IA
├── README.md                   # Resumo do projeto
├── docs/                       # Documentação técnica e de design
│   ├── GDD/                    # Game Design Documents
│   └── ARCHITECTURE/           # Arquitetura e protocolos de rede
├── data/                       # Tabelas de dados (JSON/CSV)
│   ├── races.json              # Estatísticas base das raças
│   ├── classes.json            # Árvores de habilidades
│   ├── items.json              # Armas, armaduras e consumíveis
│   ├── monsters.json           # Spawns, stats e tabelas de drop
│   └── quests.json             # Linha de missões da ilha inicial
├── server/                     # Código do servidor autoritativo
└── client/                     # Código do cliente de jogo (3D, HUD, Câmera)
```
