# Guia do Desenvolvedor & Jogador: Godot Engine 4

Este documento serve como referência rápida para qualquer desenvolvedor ou jogador baixar, abrir e executar o **Project Chronicles: Aethelgard** em qualquer computador.

---

## 🎮 O que é o Godot?

O **Godot Engine** é um motor de jogos 3D/2D gratuito, de código aberto e extremamente leve (cerca de 80 MB, comparado a 50 GB da Unreal Engine). 

Ele é responsável por:
1. Renderizar o mundo 3D, a iluminação Forward+, as sombras e os efeitos visuais.
2. Processar a física, as colisões da câmera híbrida e o movimento dos personagens.
3. Executar os scripts de regras de combate (GDScript) e carregar as tabelas de dados JSON.
4. Rodar o **Servidor Dedicado Headless** (sem interface gráfica) para multiplayer online.

---

## 📥 Como Baixar e Instalar

### No macOS (MacBook / iMac)
1. Acesse o site oficial: [godotengine.org/download](https://godotengine.org/download)
2. Baixe a versão **Godot Engine 4.x (Standard)** para macOS.
3. Descompacte o arquivo `.zip` baixado para obter o aplicativo `Godot.app`.
4. Mova o `Godot.app` para a sua pasta **Aplicativos** (Applications).
5. *Dica de Segurança do Mac:* Se aparecer aviso de "desenvolvedor não verificado" na primeira abertura:
   - Clique com o botão direito no ícone do Godot e selecione **Abrir** (Open) ➔ clique em **Abrir**.

### No Windows ou Linux
1. Baixe a versão para Windows ou Linux do mesmo link acima.
2. Descompacte e execute o arquivo `.exe` (ou binário no Linux). Não necessita de instalador complexo.

---

## 📂 Como Importar e Abrir o Projeto

1. Abra o **Godot Engine**.
2. Na janela do Gerenciador de Projetos (Project Manager), clique no botão **"Import" (Importar)** no topo direito.
3. Clique em **"Browse" (Navegar)** e selecione o arquivo:
   ```text
   project.godot
   ```
   localizado na raiz da pasta do jogo (`medieval-rpg/`).
4. Clique em **"Import & Edit" (Importar e Editar)**. O editor 3D do Godot abrirá com o projeto carregado.

---

## ▶️ Como Jogar (Modo Cliente)

Para iniciar o jogo diretamente do editor:
- Pressione a tecla **F5** (ou clique no botão **Play ▶️** no canto superior direito do editor).

### 🕹️ Controles do Jogo:
| Comando / Ação | Tecla / Controle |
| :--- | :--- |
| **Movimento** | Teclas `W`, `A`, `S`, `D` |
| **Pular** | Barra de Espaço (`Space`) |
| **Câmera Híbrida 1ª / 3ª Pessoa** | `Scroll do Mouse` (Aproxima até 1ª pessoa ou afasta até 3ª pessoa) |
| **Girar Câmera** | Movimento do Mouse (com botão direito ou modo livre) |
| **Alternar Cursor Livre** | Tecla `Esc` ou `Alt` |
| **Travar Alvo (Target Lock)** | Tecla `Tab` (mira no monstro mais próximo) |
| **Ataque Físico Básico** | `Clique com Botão Esquerdo` do mouse ou Tecla `1` na Hotbar |
| **Ligar/Desligar Soulshots** | Tecla `F1` ou Tecla `6` na Hotbar |
| **Habilidades de Combate** | Tecla `2` (Golpe Poderoso), `3` (Flecha Ígnea), `4` (Cura Menor) |
| **Usar Poção de Vida** | Tecla `5` na Hotbar ou pelo Inventário |
| **Abrir / Fechar Inventário** | Tecla `I` (mostra os 24 slots, peso e itens equipáveis) |
| **Falar com NPCs / Coletar Loot** | Tecla `F` (Diálogo com Sentinela) / Tecla `E` (Pegar itens no chão) |

---

## 🌐 Como Rodar o Servidor Dedicado Headless (Multiplayer)

Para rodar o servidor em uma máquina remota ou em segundo plano sem interface gráfica:

```bash
# No macOS
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /caminho/do/projeto/medieval-rpg --server

# No Linux
./godot.x86_64 --headless --path /caminho/do/projeto/medieval-rpg --server
```

O servidor iniciará escutando na porta **7777 (UDP)** pronto para conexões simultâneas de clientes.
