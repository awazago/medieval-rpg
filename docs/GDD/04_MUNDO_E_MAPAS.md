# GDD 04 - Mapa Inicial e Zonas de Expansão

## 1. Princípio de Mapa Inicial Controlado
Para garantir foco de desenvolvimento e validação técnica rápida do cliente e servidor, começamos com uma área inicial autossuficiente e rica em conteúdo dos níveis 1 ao 20.

---

## 2. A Zona Inicial: *A Ilha do Alvorecer (Dawn Isle)*

### Centro Urbano: Aldeia de Pedra Alta (Highstone Village)
- **Status:** Zona de Paz (No-PvP, regeneração acelerada de HP/MP ao sentar).
- **Pontos de Interesse:**
  1. **Templo Central dos Dois Deuses:** Onde os novos jogadores despertam e recebem suas primeiras bênçãos e missões de raça.
  2. **Forja do Mestre Anão Torvald:** Onde armas No-Grade e D-Grade podem ser reparadas e refinadas.
  3. **Porto e Armazém Geral:** Ponto de troca de itens e futura rota de barco para o continente principal.
  4. **Posto dos Sentinelas:** Quadro de avisos com caçadas de monstros (bounties diários).

### Zonas Selvagens da Ilha (Zonas de Caça / Grinding Zones)
1. **Campina dos Sussurros (Níveis 1 - 5):**
   - Inimigos: Raposas selvagens, Lobos jovens, Goblins batedores.
   - Recursos: Madeira comum, ervas medicinais, peles básicas.
2. **Ruínas do Antigo Santuário (Níveis 6 - 12):**
   - Inimigos: Esqueletos guerreiros, Orcs saqueadores, Aranhas gigantes venenosas.
   - Recursos: Ossos de ferro, pergaminhos menores de buff, pedras de mana puras.
3. **Pântano Sombrio & Cripta Esquecida (Níveis 13 - 20):**
   - Inimigos: Golens de pedra, Espectros andarilhos, Minotauros carniceiros.
   - **Mini-Boss de Zona:** *Valthor, o Cavaleiro Caído* (Nível 20 - requer grupo de 3 a 5 jogadores para derrotar; dropa peças de conjunto D-Grade raras).

---

## 3. Arquitetura de Expansão do Mundo
- **Mundo em Grade (Grid / Chunk Streaming):**
  - O mundo do jogo é dividido em setores modulares (ex: 500m x 500m).
  - O servidor só sincroniza entidades dentro do raio de visão do jogador (Interest Management / Spatial Partitioning).
  - Novas regiões continentais (Dion, Giran, Aden) poderão ser plugadas como novos mapas ou setores conectados por estradas ou teleporters sem quebrar o código existente.
