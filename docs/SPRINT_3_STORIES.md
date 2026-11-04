# Sprint 3: Cripta dos Esqueletos, Sistema de Níveis/XP & Servidor Dedicado Headless

## Meta da Sprint
Expandir o jogo com a primeira masmorra de desafio (Cripta Antiga com Esqueletos Guerreiros agressivos), implementar a curva de progressão de níveis (Level Up com ganho de XP/SP e bônus de atributos) e consolidar o Servidor Dedicado Headless para múltiplos jogadores simultâneos via ENet.

---

### Story 3.1: Ruínas da Cripta Antiga & Esqueletos Guerreiros Agressivos
- **Como** jogador aventureiro,
- **Quero** explorar as Ruínas da Cripta Antiga ao norte da vila e enfrentar Esqueletos Guerreiros de nível 10 agressivos,
- **Para que** haja perigo real de combate, necessidade de usar habilidades/Soulshots e desafio que justifique formar grupos.

#### Critérios de Aceite:
1. Cenário 3D da Cripta Antiga com pilares de pedra quebrados, lápides antigas, tochas de fogo espectral e névoa subterrânea.
2. Esqueleto Guerreiro (Nível 10, agressivo com raio de percepção de 14 metros):
   - Persegue o jogador automaticamente quando este entra no raio de aggro.
   - Aplica ataques físicos pesados com espada enferrujada.
   - Dropa itens No-Grade valiosos (`short_sword`, `iron_breastplate` e `spiritshot_none`).

---

### Story 3.2: Sistema de Níveis, Curva de XP & Efeito Visual de Level Up
- **Como** jogador,
- **Quero** receber Pontos de Experiência (XP) e Pontos de Habilidade (SP) ao derrotar monstros e ver uma celebração visual clássica ao subir de nível,
- **Para que** meu personagem fique progressivamente mais forte com aumento de vida, mana e atributos.

#### Critérios de Aceite:
1. Curva de XP progressiva baseada em tabela (Níveis 1 ao 20 para a Ilha do Alvorecer).
2. Barra de XP no rodapé do HUD exibindo porcentagem de avanço para o próximo nível (ex: `XP: 45.2%`).
3. Ao atingir 100% de XP:
   - Nível é incrementado (`Level + 1`).
   - Vida, Mana e CP máximos aumentam e são restaurados para 100%.
   - Efeito visual de *Level Up*: coluna de luz dourada ascendente e partículas de comemoração com mensagem no chat: `"[NÍVEL SUPERIOR!] Parabéns, você alcançou o nível X!"`.

---

### Story 3.3: Servidor Dedicado Headless & Sincronização Multiplayer
- **Como** operador de jogo ou jogador host,
- **Quero** rodar o servidor em modo Headless (sem interface gráfica e sem placa de vídeo) aceitando múltiplos clientes simultâneos,
- **Para que** o jogo funcione em servidores na nuvem (VPS/Linux/Mac) com validação autoritativa de jogadores e monstros.

#### Critérios de Aceite:
1. Suporte a argumento de linha de comando `--server` para iniciar o servidor headless diretamente na porta 7777 via ENet.
2. Menu de Conexão Rápida no Cliente (Botões: *"Criar Servidor Local"*, *"Entrar como Cliente"* e *"Iniciar Singleplayer"*).
3. Servidor sincroniza posições, rotação, estados de vida e mortes de monstros para todos os clientes conectados.
