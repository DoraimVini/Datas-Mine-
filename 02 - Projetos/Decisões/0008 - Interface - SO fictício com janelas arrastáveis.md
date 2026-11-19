---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0008"
status: aceita
data: "2026-11-19"
area: tecnica
---

# 0008 — Interface: SO fictício com janelas arrastáveis, apps como cenas trocáveis

## Contexto
O protótipo de texto validou o núcleo. Agora o caso 1 precisa ser jogável com interface ([[0002 - Interação híbrida com progressão]]), com a lógica de interface em grafos ([[0005 - Visual scripting híbrido com Orchestrator]]). O usuário escolheu um **SO fictício próprio**, **janelas arrastáveis**, **cola em GDScript primeiro, com troca gradual por grafos** e **o caso 1 inteiro** na primeira entrega.

## Opções consideradas
1. **Nós `Window` do Godot** (subjanelas embutidas): arrastar e fechar vêm prontos, mas o tema e o comportamento são mais difíceis de controlar, e há diferenças entre plataformas.
2. **Janelas próprias com `Control`** (PanelContainer + barra de título): controle total do visual, testável sem janela do sistema, simples de entender.
3. **Painéis fixos com abas:** mais simples, mas o usuário preferiu janelas.

## Decisão
**Opção 2.**
- O SO se chama **ÉterOS** (nome em `interface.json`).
- **Estrutura:** `ui/Desktop.tscn` (ícones, barra de tarefas com o HUD de ruído, Exposição e conexão, notificações) + `ui/janela/Janela.tscn` (arrastável, fica dentro da área do desktop, minimiza e fecha) + 7 apps em `ui/apps/` (Rede, Arquivos, Caderno, Dossiê, Pendrive, Chat, Manual).
- **Cada app é uma cena com um script de cola** (`app_*.gd`, base `app_base.gd`) que só lê `Jogo.estado()`, chama `Jogo.executar()` e reage aos sinais. É esse script que vira `.torch`, seguindo o [[Guia - Trocando GDScript por grafos]].
- **PonteJogo:** um nó auxiliar que repassa os sinais do autoload para a cena, para os grafos ligarem sinais pelo editor.
- **Textos:** rótulos da interface em `conteudo/textos/interface.json`. Mensagens de eventos, erros e o manual vêm do `console.json`, a fonte única do console e da interface.
- **Tema** em código (`ui/tema/tema.gd`, cores como tokens) e fonte de sistema monoespaçada. Sem assets baixados.
- **Telemetria:** o autoload `Jogo` registra comandos e eventos e salva o log ao fechar a janela, com o mesmo formato do console e `interface: gui`.
- **O parser de comandos** passou para `app/parser.gd`, compartilhado pelo console, pelo modo de captura e pelo futuro app Terminal.

## Consequências
- ✅ O jogo é jogável com o mouse, e a regra de dependência é preservada (a UI não tem regras).
- ✅ Os apps são trocáveis um a um por grafos, sem quebrar o jogo.
- ✅ Há um modo de captura (`--captura`) para conferir o visual automaticamente.
- ⚠️ Janelas próprias exigem cuidar de foco, limites e minimizar à mão (testado no básico).
- ⚠️ **Bug conhecido do Orchestrator no Windows:** o Godot dá *segfault ao fechar* (código de saída 139) com o plugin carregado, no editor, no jogo e no build ([issue #1864](https://github.com/CraterCrash/godot-orchestrator/issues/1864), ainda aberta, causa no godot-cpp). O jogo e os testes rodam até o fim, e o log de playtest é salvo antes. Os **testes passam pelo `game/testes/rodar.ps1`**, que lê a linha "N testes, M falhas" em vez de confiar no código de saída. Reavaliar quando sair uma versão 2.5.x com a correção.
- ⚠️ Só os binários do Orchestrator para Windows foram versionados (13 MB). Exportar para Linux ou Web exige adicionar os binários dessas plataformas.
- ⚠️ As cenas dos apps são montadas em grande parte por código (`montar()`). Na troca por grafos, é útil passar os nós fixos para a cena, como foi feito no Caderno.

## Revisar quando
Se as janelas próprias derem problemas de usabilidade nos playtests, ou se a troca por grafos mostrar que a cola em GDScript não se traduz bem.
