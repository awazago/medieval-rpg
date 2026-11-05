# Sprint 4: Criação das 5 Raças & Sistema de Equipamento Visual 3D (Paperdoll)

## Meta da Sprint
Dar identidade única aos heróis: implementar a tela completa de seleção e criação de personagens para as 5 raças clássicas (Humano, Elfo da Luz, Elfo Negro, Orc e Anão) com atributos dinâmicos e proporções visuais, além do sistema de Paperdoll 3D que exibe fisicamente armas equipadas na mão direita e texturas de armaduras no corpo.

---

### Story 4.1: Tela de Criação & Seleção das 5 Raças Clássicas
- **Como** jogador iniciando a aventura,
- **Quero** uma tela de criação de personagens onde eu possa escolher meu nome, raça e arquétipo, vendo os atributos mudarem em tempo real,
- **Para que** eu possa criar um personagem alinhado com meu estilo de combate predileto.

#### Critérios de Aceite:
1. Interface medieval permitindo alternar entre as 5 raças:
   - **Humano:** STR 40, DEX 30, CON 43, INT 21, WIT 11, MEN 25 (Equilíbrio e resiliência).
   - **Elfo da Luz:** STR 36, DEX 35, CON 36, INT 23, WIT 14, MEN 26 (Velocidade máxima e conjuração ágil).
   - **Elfo Negro:** STR 41, DEX 34, CON 32, INT 25, WIT 12, MEN 26 (Maior letalidade física e mágica).
   - **Orc:** STR 43, DEX 26, CON 47, INT 19, WIT 9, MEN 27 (Maior vida e força esmagadora).
   - **Anão:** STR 39, DEX 29, CON 45, INT 18, WIT 10, MEN 27 (Capacidade massiva de carga e foco em forja).
2. Painel de Atributos Dinâmico exibindo barras comparativas e descrição de lore de cada raça.
3. Prévia 3D do personagem refletindo a identidade física da raça (Orc mais largo e maciço, Elfo mais esguio e alto, Anão compacto e robusto).
4. Campo para digitar o nome do herói e botão *"Despertar em Aethelgard"*.

---

### Story 4.2: Sistema de Equipamento Visual Modular 3D (Paperdoll System)
- **Como** jogador,
- **Quero** ver a arma que equipei no inventário aparecer na mão direita do meu personagem e a armadura mudar o visual do meu corpo,
- **Para que** a sensação de progressão de equipamentos seja visível tanto para mim quanto para outros jogadores.

#### Critérios de Aceite:
1. `WeaponSocket` acoplado na mão direita do personagem:
   - Equipar **Espada Curta de Ferro** instancia o modelo 3D da espada com lâmina metálica.
   - Equipar **Cajado de Aprendiz** instancia o cajado de duas mãos com cristal superior.
   - Equipar **Adaga de Osso** instancia a adaga curta e ágil.
   - Equipar **Arco de Caça** posiciona o arco na mão esquerda/costas.
   - Desequipar a arma remove o modelo e deixa as mãos livres.
2. Alteração de Armadura no Torso:
   - Equipar **Túnica de Couro Cru** altera a textura do corpo para couro marrom costurado.
   - Equipar **Peitoral de Ferro Fundido** altera a textura para placas de aço brilhante com ombreiras reforçadas.

---

### Story 4.3: Integração de Atributos & Spawn do Personagem
- **Como** motor de jogo,
- **Quero** instanciar o personagem no mundo com as estatísticas exatas da raça escolhida na criação,
- **Para que** um Orc realmente tenha mais vida e um Elfo realmente corra mais rápido desde o primeiro segundo de jogo.
