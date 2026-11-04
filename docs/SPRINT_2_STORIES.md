# Sprint 2: Vila de Highstone, Soulshot FX, Números Flutuantes & Barra de Habilidades (Hotbar)

## Meta da Sprint
Elevar a fidelidade visual e a satisfação de combate para o padrão Lineage II: construir a arquitetura 3D da Aldeia de Highstone (paliçadas, tendas, forja e caminhos), adicionar efeitos de partículas brilhantes de Soulshots na arma, números de dano flutuantes 3D e a barra de atalhos (Hotbar) com conjuração de habilidades e barra de cast.

---

### Story 2.1: Construção do Cenário da Aldeia de Highstone (Vila Inicial)
- **Como** jogador,
- **Quero** explorar uma vila medieval estruturada com portões de madeira, forja, tendas de comércio e caminhos de pedra que levam às áreas selvagens,
- **Para que** o mundo passe a sensação de um posto avançado habitado e seguro antes de me aventurar nas terras perigosas.

#### Critérios de Aceite:
1. Aldeia de Highstone cercada por paliçadas de madeira defensivas e torres de observação.
2. Portão principal de saída com tochas acesas conectando a zona segura às Campinas dos Sussurros.
3. Estruturas identificáveis: Posto do Sentinela, Forja do Ferreiro com bigorna e tendas de suprimentos.
4. Caminhos de terra batida e pedra demarcando as rotas da vila até as ruínas dos esqueletos.
5. Zona de Paz (Peace Zone) claramente delimitada no centro da vila.

---

### Story 2.2: Partículas de Soulshot & Números de Dano Flutuantes 3D (Floating Combat Text)
- **Como** jogador no combate,
- **Quero** ver o brilho de partículas douradas na arma ao desferir um golpe com Soulshot e ver os números de dano subindo na tela sobre o alvo,
- **Para que** haja o feedback sensorial e impacto visceral característico dos confrontos de Lineage II.

#### Critérios de Aceite:
1. **Soulshot FX:** Ao golpear com Soulshot ativo, uma emissão de partículas douradas (`GPUParticles3D` / Shaders de brilho) irrompe da lâmina da arma com um flash iluminado.
2. **Floating Damage Text:**
   - Dano normal: número branco/amarelo flutuando e sumindo para cima da cabeça do monstro.
   - Dano crítico: número em vermelho/dourado ampliado com texto `CRÍTICO!`.
   - Se for o jogador recebendo dano: número em vermelho flutua sobre seu personagem.

---

### Story 2.3: Barra de Atalhos (Hotbar) & Conjuração de Habilidades com Cast Bar
- **Como** jogador,
- **Quero** ter uma barra de atalhos na parte inferior da tela configurável com habilidades e itens (F1 a F8 ou números 1 a 8),
- **Para que** eu possa desferir ataques especiais (como Golpe Poderoso e Flecha Ígnea) visualizando a barra de conjuração (Cast Bar).

#### Critérios de Aceite:
1. Hotbar inferior com 8 slots de acesso rápido mapeados no teclado (teclas 1 a 8 / F1 a F4).
2. Conjurar uma habilidade (ex: `Golpe Poderoso`) consome MP do personagem, inicia a barra de conjuração no centro do HUD e aplica cooldown visual no slot.
3. Se o jogador sofrer dano pesado ou se mover durante habilidades com cast longo, o cast pode ser cancelado.
