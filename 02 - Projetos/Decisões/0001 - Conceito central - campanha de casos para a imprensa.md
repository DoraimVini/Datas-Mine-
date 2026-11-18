---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0001"
status: aceita
data: "2026-11-18"
area: design
---

# 0001 — Conceito central: campanha de casos para a imprensa

## Contexto
O Datas_Mine! precisava de uma estrutura central. O usuário quer um jogo **simples, mas muito divertido**, com sensação de quebra-cabeça metódico, progressão e mistério, para PC, com 1 a 2 horas. Ao longo da conversa surgiram três referências: invasão de redes (v0.1 do [[GDD]]), *Papers, Please* (regras simples que crescem e dilemas morais) e casos reais de denúncia entre informante e jornalista (provar, confirmar e publicar com responsabilidade).

## Opções consideradas
1. **Invasão de redes por capítulos (v0.1):** quebra-cabeça forte, mas sem um objetivo final marcante nem dilema moral.
2. **Infiltrado na mesa da Panóptica, com ciclo de dias e noites:** muito próxima do *Papers, Please*. Tem bom dilema, mas impõe uma rotina repetitiva e se distancia da fantasia de hacker.
3. **Campanha de casos que escalam, com entrega à imprensa:** começa com invasões pequenas e discretas e cresce até um esquema massivo de corrupção. Cada caso segue o ciclo invadir → montar o dossiê → entregar. As regras editoriais crescem a cada caso.

## Decisão
**Opção 3.** São 5 casos, de um vereador de cidade pequena até o esquema que liga empresas, um órgão de vigilância e um ministro. Cada caso tem três fases (invadir, dossiê, entrega). A Exposição acumula ao longo da campanha. Há 4 finais, definidos pela força do caso, pelos inocentes protegidos e pela Exposição. Tudo é fictício: nenhuma pessoa ou instituição real.

## Consequências
- ✅ Um objetivo claro desde o início ("entregar o esquema"), com progressão sentida em cada caso.
- ✅ As "regras que crescem" (o checklist editorial) dão profundidade sem exigir mecânicas novas a cada caso.
- ✅ Uma única base de dados de documentos alimenta as três fases, o que simplifica a implementação e os testes.
- ⚠️ São três fases para construir (rede, quadro, entrega). O protótipo precisa provar que o **caso 1 inteiro** é divertido antes de expandir.
- ⚠️ É preciso cuidado para a fase do dossiê não virar burocracia: poucos documentos por caso e resposta imediata.
- ❌ A rotina de dias na mesa sai do escopo.

## Revisar quando
No fim do protótipo (caso 1 jogável): se o quadro de evidências ou a entrega não forem divertidos, reabrir esta decisão.
