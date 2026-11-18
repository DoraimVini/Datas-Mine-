---
tags: [exercicio, design, caso1, inbox]
projeto: "Datas_Mine!"
criado: 2026-11-18
status: feito (conteúdo em "02 - Projetos/Casos", playtest em "02 - Projetos/Playtests")
---

# Exercício — Caso 1: "A Merenda de Vila Serena"

Objetivo: escrever o **conteúdo completo do caso 1** e testar se a mecânica é divertida **antes da interface**. O resultado vira o JSON do protótipo e a base do formato de conteúdo (decisão 0006, pendente). Ligado ao [[GDD]] e à [[Arquitetura]].

> **Dois jeitos de testar** (passo 7): no **papel** (cartões e fichas) ou no **protótipo de texto** (o núcleo em GDScript jogado por comandos, sem interface). Os passos 1 a 6 são iguais nos dois, porque o conteúdo precisa existir de qualquer jeito.

## 1. Premissa (dê seu toque)
O vereador **Souza**, da cidade fictícia de Vila Serena, aprovou um contrato de merenda escolar com a **Nutri Bem Ltda**. As crianças reclamam que a comida piorou, mas o valor do contrato subiu. A blogueira local **Marta** quer provas.

## 2. Rede (3 nós)
```
[Site da Prefeitura] ──── [PC do Gabinete] ──── [Servidor de Contratos]
     (público)              (precisa senha)        (precisa crack)
```
Para cada nó, anote: as portas, o custo para entrar e os arquivos que ele guarda.

## 3. Documentos (5 ou 6, de até 5 linhas cada)
| # | Onde fica | Documento | Função |
|---|---|---|---|
| 1 | Site da Prefeitura | Notícia: "Vila Serena renova a merenda com nova parceira" | Apresenta os nomes (Souza, Nutri Bem) |
| 2 | Site da Prefeitura | Lista de servidores do gabinete | Traz um **nome de usuário** |
| 3 | PC do Gabinete | E-mail da assessora com um lembrete de senha ("o nome do meu gato + o ano") | **Pista de senha**, que evita o crack |
| 4 | PC do Gabinete | Planilha de pagamentos | Traz o **valor** e a **data** |
| 5 | Servidor de Contratos | Contrato oficial | Confirma a **empresa** e o **valor** |
| 6 | Qualquer um | **Despista**: uma empresa parecida ("Nutri Bom") ou um valor antigo | Testa a leitura atenta |

Inclua também o **nome de um cidadão comum** (por exemplo, um pai que reclamou). Ele é o inocente a ocultar.

## 4. Fatos com lacunas (1 ou 2)
> Fato 1: "`[quem]` aprovou o pagamento de `[quanto]` à `[empresa]` em `[quando]`."

Confira duas coisas:
- Cada resposta aparece em algum documento.
- Existe pelo menos um termo "isca" plausível e errado.

## 5. Regra do memorando
> Caso 1: "Todo fato precisa de **um documento que o prove**."

## 6. Conta do ruído
Escreva o custo de cada ação (tabela do GDD) e calcule o **caminho ideal**. Ele deve gastar entre 70 e 80 dos 100 pontos.

## 7. Playtest
**No papel:** os cartões ficam virados até a pessoa usar a ferramenta certa, as fichas de ruído saem a cada ação (1 ficha = 5 pontos) e os termos vão para post-its. No fim, você responde como a Marta.

**No protótipo de texto:** a pessoa joga digitando comandos (`scan`, `read doc3`, `coletar R$ 480 mil`, `preencher fato1 quanto ...`, `entregar`), e o jogo responde em texto.

**Observe em silêncio e anote:**
- [ ] Onde travou?
- [ ] Tentou chutar?
- [ ] Achou a pista da senha sozinha?
- [ ] Caiu na isca?
- [ ] Lembrou de ocultar o inocente?
- [ ] Quis jogar mais?

## Dica
Documentos **curtos e com personalidade**. Um e-mail passivo-agressivo da assessora vale mais que um parágrafo técnico.
