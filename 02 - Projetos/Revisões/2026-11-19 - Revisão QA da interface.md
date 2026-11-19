---
tags: [revisao, qa]
projeto: "Datas_Mine!"
alvo: "interface ÉterOS (ADR 0008), antes do commit"
revisor: qa-reviewer
data: 2026-11-19
veredito: "corrigir antes (todos os achados corrigidos)"
---

# Revisão QA — interface ÉterOS (2026-11-19)

Relacionados: [[0008 - Interface - SO fictício com janelas arrastáveis]] · [[Arquitetura]]

| Gravidade | Achado | Correção |
|---|---|---|
| ALTA | O Godot dá segfault (exit 139) ao fechar com o Orchestrator: o código de saída dos testes não é confiável | Bug do plugin ([#1864](https://github.com/CraterCrash/godot-orchestrator/issues/1864), aberto). Criado `testes/rodar.ps1`, que lê "N testes, M falhas". `.gamedev.json` atualizado |
| MÉDIA | Os valores das flags (`--comandos x`) viravam caso/jogador | `app/argumentos.gd` (pula o valor das flags), usado no Jogo, no Desktop e no console + testes |
| MÉDIA | O Chat quebrava sem caso carregado | Guarda em `ao_evento` + teste |
| MÉDIA | A UI lia `jogo.sessao.*` por referência viva | `Jogo.estado()`/`caso()` devolvem cópias (atualizadas 1× por comando) + teste de que alterar a cópia não muda o jogo |
| MÉDIA | O Dossiê recalculava "completo" (regra duplicada) | `Jogo.fato_completo()` delega ao núcleo |
| BAIXA | A UI escolhia a porta do crack | Um botão de crack por porta, depois de sondar: o jogador escolhe |
| BAIXA | O Manual da GUI omitia o custo de erro | `app/textos.gd` compartilhado com o console |
| BAIXA | O Chat dependia da posição das linhas no `console.json` | `interface.json → chat.resultado_linhas` |
| BAIXA | Dica de sondagem errada para nós públicos ou com PIN | Texto condicional |
| BAIXA | `_extras_log` vazava entre casos | Limpo em `iniciar_caso` |
| BAIXA | As notificações cobriam o Caderno | Nova posição + o Caderno parou de crescer (largura mínima do texto com quebra) |
| BAIXA | O Logger contava `push_warning` como falha | Avisos ignorados; rótulo "ERRO" |
| BAIXA | `queue_free` nos testes deixava apps vivos | `free()` imediato |
| — | Faltavam testes (parser, log, Desktop, Rede, Pendrive, Chat) | +10 testes (63 no total) |

**Achado extra durante a correção:** um arquivo de teste com erro de sintaxe fazia o executor abortar e o Godot **travar para sempre**. Agora: arquivo que não compila = falha; executor que aborta = sai com falha. Isso foi verificado com arquivos quebrados de propósito.

**Lição para o cérebro (próximo `/retro`):** um executor de testes precisa de testes próprios ("um teste quebrado é reportado?"). Duas vezes ele escondeu problemas: erros de script não contavam, e um arquivo quebrado travava o processo.
