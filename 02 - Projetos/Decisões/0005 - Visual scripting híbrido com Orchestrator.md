---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0005"
status: aceita
data: "2026-11-18"
area: tecnica
---

# 0005 — Visual scripting híbrido: núcleo em GDScript + apresentação em Orchestrator

## Contexto
O usuário quer **programar com visual scripting** (nós e fios). O Godot 4 **não tem visual scripting nativo**: o VisualScript foi removido na versão 4.0 (veja `../Conhecimento/Engines - linguagens e visual scripting.md` no cérebro). A [[Arquitetura]] exige um **núcleo de regras puro e testado** ([[0004 - Engine e linguagem - Godot 4.7 com GDScript]]).

A opção madura no Godot 4.7 é o **Orchestrator** (CraterCrash):
- plugin GDExtension, licença Apache-2.0;
- v2.5 estável para Godot 4.7 (jul/2026), com desenvolvimento ativo (último push em 17/11/2026);
- cerca de 1,6 mil estrelas no GitHub.

## Opções consideradas
1. **Híbrido:** as regras em GDScript (testadas, escritas com a IA). Interface, telas, efeitos e fluxo em grafos do Orchestrator. É o modelo da indústria (C++ para os sistemas, Blueprints para a combinação).
2. **Tudo em visual:** máxima programação visual, mas sem testes automatizados das regras, diffs de git ruins, dependência total de um plugin de terceiros e pouca ajuda da IA para editar grafos.
3. **Trocar de ferramenta:** Unity Visual Scripting (pesada para 8 GB de RAM) ou GDevelop (planilhas de eventos, não nós).

## Decisão
**Opção 1, híbrido.**
| Parte | Como | Quem faz |
|---|---|---|
| **Núcleo** (`res://nucleo/`): ruído, exposição, invasão, caderno, dossiê, editorial, campanha, comandos | **GDScript** puro, com testes | Claude (`game-programmer`), com revisão do usuário |
| **Autoload `Jogo`** (executor de comandos, eventos como sinais, save, conteúdo) | **GDScript** | Claude |
| **Apresentação** (`res://ui/`): apps do desktop, botões, animações, sons, transições de tela, reação aos eventos | **Orchestrator** (grafos visuais) | **Usuário**, guiado passo a passo |
| **Fronteira** | O grafo visual só chama `Jogo.executar(comando)` e escuta os sinais de `Jogo`. **Regras nunca ficam no grafo** | Os dois |

## Consequências
- ✅ O usuário programa visualmente o que é mais visível no jogo (interface e feedback) e aprende nós e fios na prática.
- ✅ As regras continuam testadas, versionáveis e fáceis de revisar. Um bug de regra não fica escondido num grafo.
- ✅ A fronteira clara (comandos para dentro, sinais para fora) evita que os dois mundos se misturem.
- ⚠️ **Dependência de terceiros:** fixar a versão do Orchestrator (2.5.x para o Godot 4.7). Atualizar o Godot exige atualizar o plugin junto (é GDExtension e depende da ABI da engine).
- ✅ **Git:** o Orchestrator salva em dois formatos: **`.torch` (texto)** e `.os` (binário), confirmado no código-fonte da v2.5 (`format_defs.h`). **Regra do projeto: sempre `.torch`.** Assim o git mostra o diff e Claude consegue ler os grafos.
- ⚠️ **IA:** Claude consegue ler e explicar grafos, mas a edição visual é do usuário. Claude ensina o que montar, nó a nó.
- ⚠️ Desempenho: grafos são interpretados e mais lentos que GDScript. Irrelevante para a interface deste jogo.

## Revisar quando
Se o Orchestrator for abandonado ou ficar incompatível com o Godot, a apresentação pode migrar para GDScript sem tocar no núcleo. Também revisar se o usuário quiser levar mais coisas para o visual.
