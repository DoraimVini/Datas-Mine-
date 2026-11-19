---
tags: [guia, orchestrator, visual-scripting]
projeto: "Datas_Mine!"
criado: 2026-11-19
status: pronto para o 1º app (Caderno)
---

# Guia — Trocando GDScript por grafos (Orchestrator)

Relacionados: [[0005 - Visual scripting híbrido com Orchestrator]] · [[0008 - Interface - SO fictício com janelas arrastáveis]] · [[Arquitetura]]

## A ideia
Cada app da interface (`game/ui/apps/`) é uma cena com um script de **cola em GDScript** (`app_*.gd`). O jogo já funciona com eles. Você troca **um app por vez** por um grafo `.torch` e compara com a versão que já funcionava.

**A regra de ouro do grafo** (a mesma da cola): ele só faz três coisas.
1. **Lê** o estado: `Jogo.estado()` (um Dictionary).
2. **Pede** ações: `Jogo.executar({ "tipo": ..., ... })`.
3. **Reage** quando o estado muda: o sinal `estado_mudou` da **PonteJogo**.

Regra de jogo (custo, se pode ou não pode) **nunca** vai no grafo: isso é do núcleo.

## Antes de começar (uma vez)
1. Abra o editor:
   ```powershell
   & "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\werne\OneDrive\Área de Trabalho\vini\obisidian_vaults\GAME_DEV_AI\GAME_DEV_AI\Game_dev_IA\Datas_Mine!\game" -e
   ```
2. Confira que aparece a aba **Orchestrator** no topo, ao lado de 2D, 3D e Script. O plugin já está em `game/addons/orchestrator` (só os binários do Windows).
3. Rode o jogo (F5) uma vez com a versão em GDScript, para ver como o Caderno deve ficar.

## App 1: Caderno (o mais simples)
**O que ele faz:** sempre que o estado muda, limpa a lista e adiciona um item por termo coletado. Mostra "vazio" quando não há termos.
**A cena** (`ui/apps/Caderno.tscn`) já tem tudo: `Caderno` (VBoxContainer) → `Vazio` (Label), `Lista` (ItemList) e `PonteJogo` (Node).

### Passo a passo
1. Abra `res://ui/apps/Caderno.tscn`.
2. **Troque o script do nó raiz:** selecione `Caderno` → botão direito → **Detach Script** (desanexar o `app_caderno.gd`) → botão direito → **Attach Script** → linguagem **OScript**, nome `caderno.torch` (**formato .torch**, o de texto, nunca `.os`) → Create.
3. No grafo, crie uma **função** chamada `atualizar` (painel esquerdo → Functions → +).
4. Monte o corpo de `atualizar`:
   1. **Get Scene Node** → `Lista` → chame `clear()`.
   2. Pegue o autoload **Jogo** (categoria **Autoloads**) → chame `estado()` → do Dictionary, pegue a chave `"caderno"` (categoria **Dictionaries**, nó de leitura por chave).
   3. **For each** sobre essa Array. Para cada termo:
      - de `Jogo` → `sessao` → `caso` → `["termos"][termo]["rotulo"]`, pegue o rótulo. *Atalho para a 1ª versão:* adicione o id do termo mesmo (`add_item(termo)`) e troque pelo rótulo depois;
      - **Get Scene Node** → `Lista` → `add_item(texto)`.
   4. **Get Scene Node** → `Vazio` → defina `visible` como "a Array está vazia" (`is_empty()`).
5. **Ligue o sinal** (sem grafo): selecione o nó **PonteJogo** na árvore da cena → aba **Nó → Sinais** → duplo clique em `estado_mudou` → escolha o nó `Caderno` → método `atualizar` → Connect.
6. Salve (Ctrl+S) e rode (F5). Abra o Caderno, leia um documento e clique num termo: ele deve aparecer na lista.

### Como conferir
- **Igual ao GDScript?** Compare com a versão antiga: `git stash` ou abra outra cópia.
- **Testes:** os testes automáticos de UI do Caderno (`test_caderno_lista_os_termos`) usam a cena. Se o grafo estiver certo, continuam passando:
  ```powershell
  & "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path game -s res://testes/executar.gd
  ```
- **Arquivo:** o `caderno.torch` é texto. Rode `git diff` e veja o grafo versionado.

### Se travar
- Não achou um nó? Use a **busca** do painel de ações do Orchestrator (clique com o botão direito no grafo) e digite parte do nome (`autoload`, `scene node`, `for each`).
- Peça ao Claude: *"lê o caderno.torch e me diz o que falta"*. Como o `.torch` é texto, eu consigo ler o grafo.
- Se algo **não der** para fazer em grafo, anote aqui embaixo. Esse app volta para GDScript sem prejuízo.

## Próximos apps (ordem sugerida)
| # | App | Novidade que ensina |
|---|---|---|
| 1 | Caderno | ler estado, laço, preencher lista |
| 2 | Chat | reagir ao sinal `evento` (com dados), texto formatado |
| 3 | Pendrive | botões que chamam `Jogo.executar` (ocultar/revelar) |
| 4 | Arquivos | clique em link (`meta_clicked`) vira `coletar` |
| 5 | Dossiê | menus montados dinamicamente |
| 6 | Rede | formulários (login, PIN) e muitos botões |

Antes de cada app: adicione um nó `PonteJogo` (script `res://ui/ponte_jogo.gd`) à cena, como no Caderno.

## Diário da troca
> Anote aqui o que funcionou ou não no Orchestrator. Isso vira lição para o cérebro no `/retro`.

- (nada ainda)
