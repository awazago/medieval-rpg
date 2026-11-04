# Sprint 1: Fundação de Gameplay & Economia Inicial

## Meta da Sprint
Entregar o ciclo completo de exploração inicial: derrotar monstros, coletar recompensas visíveis do chão, gerenciar inventário com limite de peso (fórmula clássica Lineage) e interagir com o primeiro NPC para receber a missão tutorial.

---

### Story 1.1: Sistema de Inventário & Limite de Peso (Lineage II Rules)
- **Como** jogador aventureiro,
- **Quero** ter um inventário em grade com controle de peso e capacidade de equipar armas/armaduras e consumir poções/soulshots,
- **Para que** eu possa gerenciar meus espólios de guerra e sentir o impacto real da força (STR) e constituição (CON) no peso carregado.

#### Critérios de Aceite:
1. **Limite de Peso (Weight Limit):**
   - Calculado pela fórmula canônica baseada em CON e STR (base: 68.000 unidades de peso com multiplicadores).
   - Faixas de penalidade clássicas do Lineage II:
     - 0% - 49%: Sem penalidade.
     - 50% - 66%: Sem regeneração passiva de HP/MP.
     - 67% - 79%: Velocidade de movimento reduzida em 20%.
     - 80%+: Personagem fica sobrecarregado (não pode correr nem iniciar novos ataques).
2. **Grade de Itens (Slots):**
   - 24 slots iniciais exibindo ícone/nome, quantidade acumulável (stackable para Adena, Soulshots, Poções) e peso unitário.
3. **Equipamento:**
   - Clicar duas vezes em uma arma equipa o item no slot de mão direita e recalcula o `p_atk` e `m_atk` do personagem.
4. **Interface:**
   - Tecla de atalho `I` ou `Tab` abre/fecha a janela flutuante de inventário sem travar o jogo.

---

### Story 1.2: Drop de Loot no Chão & Coleta 3D
- **Como** jogador,
- **Quero** que os monstros abatidos gerem pacotes de itens brilhantes e pilhas de moedas (Adena) caídos no chão,
- **Para que** haja a clássica satisfação sensorial de coletar recompensas após a batalha.

#### Critérios de Aceite:
1. Quando a vida de um monstro chega a 0, a tabela de drops (`data/monsters.json`) é sorteada pelo servidor.
2. Cada item dropado surge no mundo 3D com um marcador visual brilhante (feixe de luz ou malha dourada).
3. Ao aproximar e pressionar uma tecla de coleta (tecla `E` ou clique no item), o item é transferido para o inventário do jogador e uma mensagem surge no chat: `"Você pegou X Adena."` ou `"Você pegou Espada Curta de Ferro."`.

---

### Story 1.3: NPC Sentinela Marcus & Caixa de Diálogo
- **Como** novo aventureiro na Ilha do Alvorecer,
- **Quero** conversar com o Sentinela Marcus na saída da vila,
- **Para que** eu receba a quest "Primeiros Passos em Highstone" e entenda os perigos da ilha.

#### Critérios de Aceite:
1. NPC Sentinela Marcus posicionado na zona segura da vila.
2. Ao se aproximar e interagir (tecla `F` ou clique), uma janela estilizada de diálogo se abre no HUD.
3. O NPC apresenta as opções: *"Aceitar Missão"*, *"Como lutar com Soulshots?"* e *"Encerrar Diálogo"*.
4. Ao aceitar a missão, o objetivo é adicionado ao rastreador de quests do jogador.
