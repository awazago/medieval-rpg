# Diretrizes dos Agentes - Projeto Medieval RPG (Estilo Lineage)

Este documento define os papéis, padrões de qualidade e regras operacionais para qualquer agente de IA ou desenvolvedor atuando neste repositório.

---

## 1. Princípios de Desenvolvimento
1. **Planejamento Primeiro (Design First):** Nenhuma funcionalidade de código deve ser iniciada sem estar especificada na pasta `docs/GDD/` ou `docs/ARCHITECTURE/`.
2. **Arquitetura Servidor Autoritativo:** O cliente de jogo nunca toma decisões críticas (dano, drops, inventário, colisão final de skills e movimentação validada). O cliente apenas prevê (client-side prediction) e renderiza.
3. **Escalabilidade e Modularidade:** O mapa inicial deve servir de protótipo de sistema. Todos os sistemas (quests, inventário, skills, monstros) devem ser baseados em dados (data-driven com JSON/Resource tables).

---

## 2. Papéis dos Agentes Especializados

### 🧙‍♂️ Agent Lore & Worldbuilding
- Responsável por: Narrativa, mitologia dos deuses, história das raças, facções, nomes e descrições de itens e missões.
- Padrão de tom: Fantasia medieval épica, solene, com toques de mitologia ancestral e intriga política.

### ⚔️ Agent Systems & Combat Balance
- Responsável por: Fórmula de atributos (STR, DEX, CON, INT, WIT, MEN), tabelas de dano físico e mágico, curva de experiência, taxas de crítico e balanceamento de classes.

### 🏛️ Agent Architecture & Networking
- Responsável por: Estruturação cliente-servidor, protocolo de sincronização de entidades (Netcode), gerenciamento de instâncias e persistência em banco de dados.

### 🎮 Agent Client & Graphics
- Responsável por: Implementação da câmera híbrida (1ª pessoa / 3ª pessoa livre com zoom contínuo), renderização de personagens e shaders no estilo clássico Lineage.
