---
tags: [retro]
projeto: "Datas_Mine!"
marco: "prototipo (parcial)"
data: "2026-11-18"
---

# Retro — Datas_Mine! — protótipo (parcial)

Relacionados: [[GDD]] · [[Arquitetura]] · [[2026-11-18 - Caso 1 em texto (Vini)]] · [[2026-11-18 - Revisão QA do protótipo de texto]]

> **Por que "parcial":** o critério do marco no GDD exige de 5 a 7 playtests às cegas. Até agora só houve um, feito pelo próprio designer. O marco continua em `prototipo`.

## O que planejamos vs. o que entregamos
| Planejado (GDD, marco Protótipo) | Entregue |
|---|---|
| Caso 1 inteiro com formas simples, só no desktop | Caso 1 inteiro em **texto** (console Godot), ainda sem a interface do desktop |
| Rede de 3 nós, ferramentas, ruído, pista de senha, coleta, fatos com lacunas, memorando + checklist | ✅ Tudo, mais aviso de rastros, `revelar`, lockdown e validação de conteúdo |
| De 5 a 7 playtests silenciosos | ⏳ 1 playtest (o designer, no chat) |

**Também entregue:** as decisões 0001 a 0007, a arquitetura arc42 + C4, o harness instalado e 42 testes automatizados.

## O que funcionou
- **Revisão independente (QA)** ⭐, apontada pelo usuário: o `qa-reviewer`, um agente diferente do autor, achou um **estado sem saída** (ocultar uma prova sem poder desfazer) que os 22 testes do autor não cobriam, e mais 13 problemas.
- O playtest em texto no chat validou a diversão ("me fez anotar pistas e nomes") **antes** de qualquer código.
- O protótipo de texto **não foi descartado**: o núcleo dele é o núcleo do jogo final.

## O que não funcionou
- **A rota técnica mudou três vezes:** sem engine (TypeScript) → Godot → Godot com visual scripting. O plano TypeScript foi escrito e depois substituído. A causa: as restrições do PC (GPU sem Vulkan, 8 GB de RAM) só foram vistas **depois** de propor a tecnologia.

## Surpresas
- O jogador sondou um nó pelo nome lido num e-mail, e isso virou regra (ler economiza ruído).
- Um lockdown "por acaso" no teste mostrou que o orçamento de 100 tem tensão real.

## Lições
| Lição | Vale para | Destino |
|---|---|---|
| Inspecionar o hardware e as restrições do ambiente **antes** de escolher engine ou linguagem | todos | `Aprendizados/Processo.md` |
| Revisão por um agente independente pega bugs que os testes do autor não pegam. Sempre rodar `/revisar` antes de playtest ou commit grande | todos | `Aprendizados/Trabalhar com IA.md` |
| Validar a mecânica em texto ou no chat antes do código. Se o protótipo de texto usar o núcleo real, ele não se perde | todos | `Aprendizados/Processo.md` |
| Testar sempre que dá para **desfazer** ações destrutivas e que o caso **sempre pode ser concluído** | gênero: dedução | `Gêneros/Jogo de dedução e investigação.md` (armadilha) |
| Ler com atenção deve economizar recursos (sondar pelo nome lido, pista de senha) | gênero: hacker | `Gêneros/Simulador de hacker.md` |
| Iscas precisam ser plausíveis e ficar perto da resposta. O PIN do tutorial pode ser fácil | este projeto | já está no playtest e no caso 1 (A1/A2) |

## Próximo marco
Continuar o **Protótipo** até o critério:
1. Ajustes do playtest: iscas mais fortes (A1) e tutorial contextual (A7).
2. **De 5 a 7 playtests às cegas** com o console.
3. Depois: interface do desktop (Orchestrator) → vertical slice.
