# Sprint 5: Raid Boss Valthor, Forja de Equipamentos & Armazém Geral

## Meta da Sprint
Concluir todo o ciclo da Ilha do Alvorecer (níveis 1 ao 20): criar o lendário Raid Boss Valthor com mecânicas de ataque em área e barra de vida épica, implementar a loja de equipamentos e consumíveis com o Ferreiro Torvald usando moedas (Adena), e adicionar o NPC de Armazém (Warehouse) para guardar itens e gerenciar peso.

---

### Story 5.1: Raid Boss Valthor, o Cavaleiro Caído (Nv. 20)
- **Como** grupo de aventureiros na Ilha do Alvorecer,
- **Quero** enfrentar Valthor, o Cavaleiro Caído, na câmara mais profunda da Cripta com ataques em área e barra de vida colossal,
- **Para que** haja um confronto memorável e desafiador exigindo coordenação, poções e Soulshots.

#### Critérios de Aceite:
1. **Arena e Modelo 3D de Valthor:**
   - Estatura imponente (duas vezes a altura de um guerreiro normal) em armadura de ferro negro com aura carmesim e montante de duas mãos.
   - 4.800 pontos de vida, 120 de ataque físico e 95 de defesa.
2. **Barra de Vida Épica de Raid Boss:**
   - Ao selecionar Valthor, surge no topo da tela uma moldura dourada ornamentada com o título `👑 RAID BOSS: Valthor, o Cavaleiro Caído (Nv. 20)`.
3. **Habilidade de Área (AoE Stomp):**
   - A cada 12 segundos em combate, Valthor canaliza e desfere o *Pisão Terremoto*, causando dano e onda de choque a todos os jogadores num raio de 8 metros com aviso no chat.
4. **Recompensas Lendárias:**
   - Abater o chefe garante drop de Peitoral de Ferro, Espada Curta, centenas de Soulshots e 8.500 de XP.

---

### Story 5.2: NPC Ferreiro Torvald & Sistema de Loja de Equipamentos
- **Como** jogador acumulando Adena nas caçadas,
- **Quero** conversar com o Ferreiro Torvald na vila e acessar uma janela de comércio para comprar novas armas, armaduras e pacotes de Soulshots,
- **Para que** eu possa reinvestir minhas riquezas em poder de combate.

#### Critérios de Aceite:
1. Ferreiro Torvald localizado na forja da Aldeia de Highstone.
2. Ao interagir com tecla `F`, abre a janela de loja exibindo catálogo de itens e preços em Adena.
3. Botão "Comprar": deduz Adena do inventário e entrega o item nos slots livres.
4. Botão "Vender": permite vender itens do inventário recebendo metade do valor de mercado.

---

### Story 5.3: NPC Armazém Geral (Warehouse Keeper)
- **Como** aventureiro carregando muitos materiais e armas reservas,
- **Quero** depositar itens pesados no Armazém da vila,
- **Para que** eu possa aliviar meu peso de carga e evitar as penalidades de velocidade e regeneração.

#### Critérios de Aceite:
1. NPC Armazém Geral posicionado no centro da vila.
2. Janela com abas duplas: *Meu Inventário* (esquerda) e *Armazém* (direita).
3. Clicar em um item transfere-o instantaneamente para o cofre seguro da cidade.
