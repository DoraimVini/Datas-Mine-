---
tags: [plano, rascunho, tecnico]
status: rascunho
criado: 2026-11-18
---

# Plano técnico (rascunho): sem engine, TypeScript + Canvas

> [!warning] Rascunho, não é decisão
> Proposta guardada para retomar depois que o GDD existir. A linguagem será decidida com `/decisao`. Comparação de opções em `../Conhecimento/Jogo sem engine.md` (no cérebro).

## Ideia de protótipo (simulador de hacker)
Desktop falso com terminal desenhado no Canvas, em estilo CRT.

**Loop do contrato:**
1. Um e-mail traz o contrato: "roube `clientes.db` do servidor da MegaCorp".
2. Comandos: `help`, `scan`, `connect <ip>`, `probe`, `crack <porta>` (minigame), `ls`, `download <arquivo>`, `disconnect`.
3. Um **medidor de rastreamento** sobe enquanto você está conectado e a cada ação.
4. Para vencer, você baixa o arquivo e desconecta antes de 100%.

**Minigame do `crack`:** digitar blocos hexadecimais antes do tempo acabar. Cada erro faz o rastreamento subir.

A rede tem 3 nós. Um deles é um proxy que deixa o rastreamento mais lento, o que cria uma decisão estratégica.

## Estrutura proposta
```
game/
├── index.html · package.json (devDeps: typescript, vite, vitest) · tsconfig.json
├── src/engine/   loop · input · renderer · scenes · audio · save · debug   ← mini-motor próprio
├── src/game/     scenes/ · terminal/ · commands/ · network/ · trace.ts · contract.ts
└── tests/        parser, trace, contrato, rede
```

## Decisões técnicas propostas
- Tudo desenhado no Canvas, até o texto do terminal.
- Lógica pura (terminal, comandos, rede, rastreamento) separada do render, com testes no Vitest.
- Comandos no padrão Command, um arquivo por comando.
- Cenas numa pilha, como máquina de estados.
- Vite só como servidor de desenvolvimento e para o build.
- Adicionar `game/node_modules` e `game/dist` ao `userIgnoreFilters` do Obsidian.

## Verificação proposta
`npm test` · `npx tsc --noEmit` · jogar os caminhos de vitória e de derrota · F3 mostrando ~60 FPS · `npm run build`.
