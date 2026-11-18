---
tags: [caso, conteudo, spoiler]
projeto: "Datas_Mine!"
caso: 1
versao: 0.1
status: testado (1 playtest)
atualizado: 2026-11-18
---

# Caso 1 — A Merenda de Vila Serena (conteúdo completo, com gabarito)

> ⚠️ **Spoiler:** este é o gabarito. Não mostre a quem for jogar o playtest.
> É a fonte para o JSON do protótipo e para a decisão 0006 (formato do conteúdo). Playtest: [[2026-11-18 - Caso 1 em texto (Vini)]].

## Premissa
O Secretário de Educação **Antônio Souza**, de Vila Serena (cidade fictícia), pagou R$ 480 mil sem licitação à **Nutri Bem Ltda**, empresa do cunhado dele. A merenda piorou. A blogueira **Marta** ("Vila Serena em Pauta") quer provas.

**Regra do memorando (caso 1):** todo fato precisa de um documento que o prove. **Feedback:** só certo ou errado.

## Custos e limites
- Orçamento de ruído: 100.
- `scan` 10 · `probe` 5 · `login` certo 5 · senha errada 15 · `crack` 25 (+15 a cada PIN errado) · `read`/`coletar`/`ls`/`connect`/`disconnect` 0 · `download` 15 · `limpar` 10 (por nó).
- Exposição: +10 ao sair com rastros em qualquer nó · +20 em lockdown (só quando o ruído **passa** de 100).
- Ao sair, os nós privados trancam de novo (voltar exige login ou crack).

## Rede
| Id | Nó | Acesso | Revelado por | Arquivos |
|---|---|---|---|---|
| n1 | `portal.vilaserena.gov` | público (80, 443) | início | doc1, doc2 |
| n2 | `gab-educacao-03` | porta 22: `lucia.prado` / `pipoca2019` (ou crack) | `scan` em n1 | doc3, doc4 |
| n3 | `srv-contratos` | porta 445: PIN **291** (crack) | `scan` em n2 **ou** pelo nome lido no doc3 | doc5, doc6 |

**PIN (regras):** 3 dígitos distintos, soma 12, o primeiro é o dobro do último, o do meio é ímpar → solução única: 291.

## Documentos
| Id | Nó | Documento | Termos coletáveis | Papel |
|---|---|---|---|---|
| doc1 | n1 | Notícia "Merenda renovada" | Antônio Souza, Nutri Bem Ltda | apresenta os nomes |
| doc2 | n1 | Servidores do mês (março) | Lúcia Prado, 2019, Pipoca, Edson Farias | pista da senha + formato `nome.sobrenome` |
| doc3 | n2 | E-mail "RE: RE: ligação urgente" (Lúcia → Souza) | Rogério, cunhado, Paulo, srv-contratos | parentesco + caminho para o n3 · isca: Paulo/irmão |
| doc4 | n2 | Planilha de pagamentos 2025–2026 | 10/01/2025, Nutri Bom Alimentos, R$ 96.000,00, **14/02/2026, R$ 120.000,00 (adiantamento estornado à própria Nutri Bem)**, 14/03/2026, Nutri Bem Ltda, R$ 480.000,00, **Lúcia Prado (conferiu)**, Bianca Reis | prova do fato 1 · iscas fortes na mesma tabela · inocente: Bianca |
| doc5 | n3 | Contrato 027/2026 | Nutri Bem Ltda, Rogério Souza Lima, R$ 480.000,00, **02/03/2026 (assinatura)**, 14/03/2026, Antônio Souza, Joana Alves | prova dos fatos 1 e 2 · isca: data de assinatura × data do pagamento · inocente: Joana |
| doc6 | n3 | Protocolo da ouvidoria 0412/2026 | Carlos Menezes | contexto emocional · inocente: Carlos |

## Fatos
| Fato | Frase | Resposta | Iscas | Prova |
|---|---|---|---|---|
| fato1 | "[quem] autorizou o pagamento de [quanto] à [empresa] em [quando]." | Antônio Souza · R$ 480.000,00 · Nutri Bem Ltda · 14/03/2026 | Lúcia Prado (conferiu, não autorizou), R$ 96.000,00, **R$ 120.000,00 (estornado)**, Nutri Bom Alimentos, 10/01/2025, **14/02/2026**, **02/03/2026 (assinatura)** | doc5 ou doc4 |
| fato2 | "A [empresa] tem como sócio [sócio], [parentesco] de [quem]." | Nutri Bem Ltda · Rogério Souza Lima · cunhado · Antônio Souza | Paulo, irmão | doc5 (+ doc3 reforça) |

**Ocultar:** Joana Alves (doc5), Bianca Reis (doc4), Carlos Menezes (doc6). Ocultar uma **resposta do próprio fato** num documento tira a prova daquele documento para aquele fato (por exemplo, ocultar Rogério no doc5 derruba o fato 2, mas não o fato 1). `revelar` desfaz.

## Caminho ideal (testado automaticamente: `test_cenario_vitoria_caminho_ideal`)
`scan` n1 (10) → `probe` n2 (5) → `login` (5) → `read` doc3 → `limpar` n2 (10) → `probe srv-contratos` pelo nome (5) → `crack` + PIN (25) → `download` doc5 (15) → `limpar` n3 (10) = **85, Exposição 0**. Sem nenhum `limpar` = 65, com Exposição 10.

## Ajustes do playtest
- ✅ A1, iscas mais fortes: um adiantamento **estornado** de R$ 120 mil à própria Nutri Bem, na mesma planilha do pagamento real; a data de **assinatura** do contrato (02/03) contra a data do **pagamento** (14/03); Lúcia **conferiu** os lançamentos, mas quem **autorizou** foi Souza. Tudo testado (`test_iscas_novas_sao_recusadas`).
- ✅ A4, aviso ao sair sem `limpar`.
- ✅ A7, tutorial: `help` / `help <comando>` + dicas de primeiro uso.
