---
tags: [revisao, qa]
projeto: "Datas_Mine!"
alvo: "commit 1608a8b (protótipo de texto)"
revisor: qa-reviewer
data: 2026-11-18
veredito: "corrigir antes (todos os achados corrigidos)"
---

# Revisão QA — protótipo de texto (2026-11-18)

Feita pelo `qa-reviewer` via `/revisar`. Relacionados: [[Arquitetura]] · [[GDD]] · [[Caso 1 - A Merenda de Vila Serena]]

**O que estava bom:** a regra de dependência foi respeitada (o núcleo não usa Node, Input nem FileAccess), o estado é imutável e os 22 testes passavam.

| Gravidade | Achado | Correção |
|---|---|---|
| ALTA | Ocultar um nome de prova não tinha volta, e o caso ficava impossível | Comando `revelar` + teste |
| MÉDIA | O `limpar` por nó não fechava a conta do GDD (Exposição 10 no caminho ideal) | `limpar` passa a custar 10. Caminho ideal = 85, Exposição 0 (teste) |
| MÉDIA | O `connect` entrava de graça em nó privado depois de sair | Os nós privados trancam ao sair (teste) |
| MÉDIA | `crack` repetido cobrava de novo | Erro `minigame_em_andamento` (teste) |
| MÉDIA | Textos fixos no console (decisão 0003) | Movidos para `console.json` |
| MÉDIA | Faltavam testes para várias regras | +20 testes (agora 42) |
| BAIXA | O "R" do "R$" era removido de qualquer termo | Só para termos do tipo valor |
| BAIXA | O host diferenciava maiúsculas | Normalizado |
| BAIXA | `nomes_prova` valia por documento | Passou a valer por fato (derivado das respostas) |
| BAIXA | `ocultar` repetido não avisava | Erro `ja_oculto` |
| BAIXA | O validador deixava furos | Valida custos, exposição, feedback, regras e porta de acesso. `regras_editoriais` passou a ser usado |
| BAIXA | O lockdown disparava ao atingir exatamente 100 | Só ao passar de 100 |
| BAIXA | `executar` sem caso iniciado e `caso()` mutável | Proteção `sem_caso` + cópia |
| BAIXA | Não dava para reler o memorando | Comando `memorando` |

**Lição para o cérebro:** a revisão de um agente independente achou um bug que trava o jogo e que os testes do próprio autor não cobriam (um estado sem saída). Vale para o `/retro`: incluir testes de "sempre dá para desfazer" e de "o caso sempre pode ser concluído".
