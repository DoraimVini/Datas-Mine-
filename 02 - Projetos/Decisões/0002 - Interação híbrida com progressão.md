---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0002"
status: aceita
data: "2026-11-18"
area: design
---

# 0002 — Interação: híbrido com progressão (desktop → terminal)

## Contexto
O usuário não tinha definido como o jogador interage com o jogo. O [[GDD]] v0.2 pede três fases por caso (invadir, montar o dossiê, entregar). Também pede acessibilidade para quem nunca usou um terminal e uma sensação de progressão "do pequeno ao gigante". Depende de [[0001 - Conceito central - campanha de casos para a imprensa]].

## Opções consideradas
1. **Só terminal:** sensação autêntica de hacker e de domínio. Por outro lado, a barreira de entrada é alta, exige muito tutorial e o quadro de evidências fica estranho em texto puro.
2. **Só desktop com mouse:** acessível e visual, mas perde a fantasia de hacker e não tem uma progressão visível.
3. **Híbrido com progressão:** você começa no desktop, com apps de botões (mapa da rede, leitor de arquivos, quadro de evidências, chat com a jornalista). Ao longo dos casos destrava o **terminal**, que faz as mesmas ações com menos ruído e permite combiná-las (`script`).

## Decisão
**Opção 3.**
- O terminal é destravado no **caso 2 ou 3**.
- O quadro de evidências e o chat continuam no mouse, porque são naturalmente visuais.
- **Regra de arquitetura: cada botão de app executa um comando por baixo.** Existe uma única camada de lógica (comandos), e a interface gráfica e o terminal são só duas formas de chamá-la.

## Consequências
- ✅ O jogo é acessível no caso 1 e o domínio cresce até o caso 5. A própria interface mostra a progressão.
- ✅ Uma única camada de comandos facilita os testes (cada comando é uma função pura sobre o estado) e evita duplicar regras.
- ✅ O terminal vira uma recompensa (menos ruído, `script`), e não uma obrigação.
- ⚠️ São duas interfaces para construir. Mitigação: o protótipo (caso 1) usa **só o desktop**, e o terminal entra no vertical slice.
- ⚠️ O ruído menor no terminal precisa ser balanceado para que a GUI continue viável para quem preferir ficar nela.

## Revisar quando
Nos playtests do vertical slice: se os jogadores ignorarem o terminal, ou acharem a GUI lenta demais depois de conhecê-lo.
