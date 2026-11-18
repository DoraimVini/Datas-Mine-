---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0003"
status: aceita
data: "2026-11-18"
area: producao
---

# 0003 — Idioma do jogo: português do Brasil (PT-BR)

## Contexto
O [[GDD]] deixava em aberto o idioma do jogo. O Datas_Mine! é um jogo **cheio de texto**: documentos, e-mails, chat, memorandos, termos e fatos com lacunas. A decisão afeta o formato dos dados, a interface e o escopo.

## Opções consideradas
1. **Só PT-BR:** escrita mais rápida e natural, com o tom e o contexto brasileiros (vereador, merenda, licitação). Por outro lado, alcança um público menor.
2. **Só inglês:** público maior, mas a escrita fica mais lenta e o contexto brasileiro se perde.
3. **PT-BR + inglês desde o início:** os dois públicos, mas dobra o trabalho de texto e complica a mecânica de lacunas (os termos precisam bater nos dois idiomas).

## Decisão
**Só PT-BR** no lançamento. Mesmo assim, **todos os textos ficam em arquivos de dados**, nunca fixos no código. Com isso, uma tradução futura não exige refatoração.

## Consequências
- ✅ O tom e o contexto brasileiros viram identidade do jogo.
- ✅ Texto em arquivos de dados desde o primeiro dia (veja o documento de arquitetura, "Conceitos transversais: textos").
- ⚠️ Os termos de lacuna devem ter um **id** separado do texto exibido (`termo.id = "valor_contrato_merenda"`, `termo.rotulo = "R$ 480 mil"`). Isso permite traduzir sem quebrar a lógica dos fatos.
- ⚠️ Atenção às fontes e à codificação: UTF-8 em tudo, e a fonte precisa ter acentos (ç, ã, é).
- ❌ Um público internacional fica para depois do lançamento.

## Revisar quando
Depois do lançamento no itch.io, se houver demanda de jogadores de fora do Brasil.
