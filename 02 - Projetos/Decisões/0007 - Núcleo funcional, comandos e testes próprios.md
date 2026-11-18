---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0007"
status: aceita
data: "2026-11-18"
area: tecnica
---

# 0007 — Núcleo funcional com comandos + executor de testes próprio

## Contexto
A [[Arquitetura]] (seção 4) define o coração do jogo: `(Estado, Comando) → (Estado', Eventos)`. Faltava registrar como isso fica no código e qual framework de testes usar. Este é o momento do setup do protótipo de texto.

## Opções consideradas
**Estado:**
1. Dictionary puro (fácil de serializar para o save, de copiar com `duplicate(true)` e de inspecionar).
2. Classes `Resource` tipadas (melhor autocompletar, mas exigem mais código e são mais difíceis de copiar).

**Testes:**
1. **GUT** ou **gdUnit4**: completos, mas são addons de terceiros e precisam ser baixados e mantidos.
2. **Executor próprio** (cerca de 80 linhas): sem dependências, roda com `godot --headless -s`, é suficiente para funções puras.

## Decisão
- **Estado = Dictionary.** `nucleo/comandos.gd → aplicar(estado, caso, comando)` copia o estado (`duplicate(true)`), aplica o comando com os sistemas e devolve `{estado, eventos}`. O original nunca é alterado.
- **Comando = Dictionary** `{tipo, ...argumentos}`. **Evento = Dictionary** `{tipo, ...dados}`. Erros também são eventos (`tipo: "erro"`, `codigo`), sem mudar o estado.
- **Sistemas** em `nucleo/` com funções `static` e `preload` (sem `class_name`, para funcionar no modo `-s` sem importação).
- **Testes:** executor próprio em `testes/executar.gd` + `testes/base_teste.gd`. Arquivos `testes/test_*.gd`. Comando:
  `godot --headless --path game -s res://testes/executar.gd`
- Se os testes crescerem e precisarem de recursos de framework (mocks, cenas), migrar para o GUT.

## Consequências
- ✅ Zero dependências. Os testes rodam em segundos, sem janela.
- ✅ O estado em Dictionary vira o save quase de graça (JSON).
- ⚠️ Dictionary não tem tipagem: erros de chave só aparecem em runtime. Mitigação: testes cobrindo cada comando.
- ⚠️ O executor próprio é simples: sem relatórios bonitos e sem isolamento de cenas.
