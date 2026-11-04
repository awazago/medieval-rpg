# GDD 03 - Sistemas de Jogo e Mecânicas Centrais

## 1. Sistema de Câmera Híbrida (1ª Pessoa & 3ª Pessoa Livre)
A câmera é um dos pilares de imersão do jogo:
- **Modo 1ª Pessoa (Zoom Máximo Para Frente):**
  - A malha do modelo do jogador é ocultada na visão local (ou exibe apenas mãos/armas estilo imersivo).
  - Controle de rotação via mouse sem cursor fixo (mouselook).
  - Ideal para exploração em masmorras claustrofóbicas, arqueirismo e apreciação visual do cenário.
- **Modo 3ª Pessoa Orbital (Zoom Out com o Scroll do Mouse):**
  - Conforme o jogador rola a roda do mouse para trás (`Scroll Down`), a câmera se afasta em um braço elástico (SpringArm / Collision Check).
  - O modelo do personagem reaparece completamente, exibindo armaduras, capas, armas e a silhueta clássica do herói.
  - O cursor do mouse pode ser liberado (segurando tecla ou via toggle) para selecionar alvos, clicar no chão para andar ou interagir com NPCs e inventário.
- **Colisão de Câmera:** A câmera não atravessa paredes nem terreno; se houver um obstáculo atrás, ela ajusta dinamicamente a distância para manter o personagem visível.

---

## 2. Sistema de Combate e Alvo (Target System)
- **Target Lock:** Seleção de alvos por clique do mouse ou pela tecla `Tab`.
- **Ataque Automático:** Ao clicar duas vezes ou acionar o botão de ataque, o personagem se aproxima até a distância efetiva e executa ataques automáticos ritmados com sua velocidade (Atk.Spd).
- **Barra de Conjuração (Cast Bar):** Habilidades mágicas e especiais possuem tempo de cast, custo de MP e cooldown. Interrupções podem ocorrer se o conjurador receber dano pesado.
- **Consumíveis de Impacto (*Pedras de Alma / Soulshots*):**
  - Itens clássicos que duplicam o poder do próximo ataque físico ou mágico quando ativados, criando um custo econômico estratégico por golpe desferido.

---

## 3. Progressão de Nível e Equipamentos por Graus (Grades)
Seguindo o formato clássico que dá prestígio ao avanço de nível:
- **Graus de Equipamento:**
  - **No-Grade:** Níveis 1 ao 19 (Equipamentos rústicos de aventureiro inicial).
  - **D-Grade:** Níveis 20 ao 39 (Primeira evolução de classe).
  - **C-Grade:** Níveis 40 ao 51 (Armas reforçadas, armaduras completas com bônus de conjunto).
  - **B-Grade / A-Grade / S-Grade:** Níveis superiores (Itens lendários, drops de chefes mundiais e crafted por anões).
- **Sistema de Encantamento (+1 a +16):**
  - Uso de pergaminhos de encantamento (Scroll: Enchant Weapon / Armor).
  - Encantamentos seguros até +3.
  - A partir de +4, risco de quebra do item (transformando em cristais), gerando valor e raridade real no mercado do jogo.

---

## 4. Guildas (Clãs) e Cidades
- **Cidades (Peace Zones):**
  - Zonas neutras sem PvP aberto.
  - Abrigam NPCs de Armazém (Warehouse), Ferreiros, Mestres de Guilda, Lojas e Portais de Teleporte.
  - Jogadores podem abrir suas próprias lojas privadas (Private Store: Sell / Buy / Craft) no centro das vilas.
- **Sistema de Clãs:**
  - Níveis de clã (1 a 5 no início) evoluídos através de doação de SP/Adena e missões de clã.
  - Emblema próprio (Clan Crest) sobre o nome do jogador e na capa.
  - Habilidades passivas de clã (aumento de vida, defesa e ataque para todos os membros).
  - Preparado para Cerco de Castelos (Sieges) e controle de taxas comerciais territoriais.
