# Plano Diretor de Evolução Contínua: As Crônicas de Aethelgard

Este documento estabelece o roadmap de longo prazo para a evolução do MMORPG, estruturado no modelo clássico de **Crônicas / Expansões**, garantindo crescimento orgânico, modular e sustentável.

---

## 🗺️ Visão Panorâmica das Crônicas (Ciclo de Vida do Jogo)

```
[Crônica 0: Fundação]  --->  [Crônica 1: Alvorecer]  --->  [Crônica 2: O Continente]  --->  [Crônica 3: Era dos Clãs]  --->  [Crônica 4: Conquista]
   (Arquitetura)               (Ilha Nv. 1-20)               (Dion & Giran Nv. 20-45)        (Economia & Guerras)         (Cercos de Castelos)
```

---

## 🏛️ Detalhamento das Fases de Evolução

### 🔹 Crônica 0: A Fundação Técnica (Sprints 1 a 3 - CONCLUÍDA ✅)
- **Foco:** Validação de arquitetura cliente-servidor autoritativo e mecânicas centrais de Lineage II.
- **Entregas:**
  - Câmera híbrida 1ª / 3ª pessoa contínua via scroll do mouse.
  - Fórmulas canônicas de dano (P.Atk, M.Atk, Soulshots, Crit rate e CP).
  - Inventário com 24 slots e controle de peso clássico por CON/STR.
  - Drops 3D com rotação no chão e coleta via tecla `E`.
  - Vila de Highstone (Monólito de Aetherstone, Forja e Paliçada).
  - Partículas de Soulshot (`GPUParticles3D`) e Números de Dano Flutuantes 3D.
  - Hotbar de atalhos (1 a 8) com Cast Bar central.
  - Cripta Antiga com Esqueletos Guerreiros agressivos (Nv. 10).
  - Curva de XP de 20 níveis com efeito de Level Up (Pilar Dourado).
  - Servidor Headless Dedicado via ENet (`--server`).

---

### 🔹 Crônica 1: O Despertar das Raças (Sprints 4 a 5 - EM ANDAMENTO 🔄)
- **Foco:** Identidade dos heróis, visual individual e conclusão do conteúdo da Ilha do Alvorecer.
- **Marcos:**
  1. **Sprint 4 (Atual):**
     - Tela de Criação e Seleção das 5 Raças (Humano, Elfo da Luz, Elfo Negro, Orc e Anão).
     - Sistema de Equipamento Visual Modular (*Paperdoll*): armas 3D anexadas fisicamente na mão e armaduras alterando o visual do corpo.
     - Persistência e spawn do personagem com seus atributos raciais nativos.
  2. **Sprint 5:**
     - Raid Boss Valthor, o Cavaleiro Caído (Nv. 20) nas profundezas da Cripta.
     - Sistema de Áudio Espacial e Músicas Temáticas medievais.
     - NPCs de Loja e Armazém (Warehouse) na Vila de Highstone.

---

### 🔹 Crônica 2: A Chegada ao Continente (Sprints 6 a 8)
- **Foco:** Expansão territorial, primeira grande metrópole comercial e profissões de classe.
- **Marcos:**
  1. **Sistema de Barco / Rota Marítima:**
     - Transição da Ilha do Alvorecer para o continente principal através do Porto de Highstone.
  2. **Metrópole de Giran:**
     - Grande cidade fortificada com praça de comércio livre, feira de jogadores (*Private Stores: Vender / Comprar / Craft*).
  3. **Primeira Mudança de Classe (Class Transfer - Nível 20):**
     - Quests épicas de graduação: Cavaleiro, Gladiador, Mago, Oráculo, Assassino, etc.
     - Introdução dos equipamentos de **Grau D (D-Grade)**.

---

### 🔹 Crônica 3: A Era dos Clãs e Economia Viva (Sprints 9 a 11)
- **Foco:** Vida social, guildas, forja por anões e controle territorial.
- **Marcos:**
  1. **Sistema de Clãs Completo:**
     - Criação de clãs, níveis de guilda (1 a 5), brasões personalizados (Clan Crests) e skills passivas de clã.
     - Guerras de Clã declaradas (PvP aberto entre guildas rivais sem penalidade de PK).
  2. **Economia Orgânica e Sistema de Spoil:**
     - Anões coletando receitas e partes raras de monstros (*Spoil / Sweep*).
     - Forja de armas raras por anões com assinaturas do criador no item.
  3. **Sistema de Encantamento com Risco (+1 a +16):**
     - Pergaminhos de refino com brilho azul (+4 a +8) e vermelho pulsante (+16).
     - Risco de cristalização em caso de falha.

---

### 🔹 Crônica 4: O Cerco de Castelos & Deploy em Nuvem (Sprints 12+)
- **Foco:** Conflito em larga escala e infraestrutura de produção em servidores dedicados.
- **Marcos:**
  1. **Cerco de Castelos (Castle Sieges):**
     - O Castelo de Dion e o Castelo de Giran disputados quinzenalmente aos fins de semana.
     - Golens de cerco quebrando portões, tomada da sala do trono e controle das taxas de impostos de toda a província.
  2. **Deploy do Servidor em Nuvem:**
     - Instância do servidor rodando 24/7 em Linux (Docker / VPS).
     - Banco de dados PostgreSQL persistindo contas, inventários e membros de clãs.
     - Launcher do cliente com auto-update.

---

## 📋 Matriz de Priorização Técnica
A cada Sprint, o agente Tech Lead e a Squad seguirão o princípio:
1. **Dados primeiro:** Atualizar tabelas JSON em `data/`.
2. **Servidor primeiro:** Regra validada no servidor antes de refletir na tela.
3. **Feedback visual imediato:** Todo sistema deve ter resposta clara no HUD e som/partícula no mundo 3D.
4. **Commits atômicos no Git:** Toda funcionalidade é testada por QA e commitada antes de passar para a próxima.
