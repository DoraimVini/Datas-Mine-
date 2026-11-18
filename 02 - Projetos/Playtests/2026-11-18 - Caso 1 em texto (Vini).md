---
tags: [playtest]
projeto: "Datas_Mine!"
caso: 1
formato: texto no chat (Claude como computador e jornalista)
jogador: Vini (o próprio designer, então não é um teste "às cegas")
data: 2026-11-18
---

# Playtest — Caso 1 "A Merenda de Vila Serena" (versão em texto)

Conteúdo testado: [[Caso 1 - A Merenda de Vila Serena]]. Relacionado: [[GDD]] · [[Exercício - Caso 1 A Merenda de Vila Serena]]

## Resultado
| Métrica | Valor |
|---|---|
| Fatos comprovados | 2 / 2 |
| Inocentes protegidos | 1 / 1 (Joana Alves no doc5) |
| Ruído final | 70 / 100 (o caminho ideal previsto era 75) |
| Exposição | 10 (não usou `limpar`) |
| Erros | 0 senhas erradas · 0 PINs errados · 0 fatos recusados |

## O que o jogador disse
- **Gostou.** O jogo **fez anotar pistas e nomes**: a coleta e a leitura atenta funcionaram como o centro da diversão.
- **O PIN foi fácil.**
- **As iscas não confundiram.**

## O que o designer observou
1. **Coletou quase tudo** (17 termos, incluindo os inúteis: Edson, Pipoca, Bianca, Carlos). O caderno funcionou como um "bloco de anotações" do jogador, e isso é bom. Mas coletar um termo por vez é repetitivo no texto.
2. **Primeira tentativa de login num nó inexistente** ("Intranet · Acesso interno"), com a senha `Pipoca.2019`. A pista da senha foi entendida na hora, mas não o formato exato, nem que antes era preciso o `scan`.
3. **`probe srv-contratos` pelo nome lido no doc3**, sem `scan` (economizou 10). Aceitei na hora → **vira regra**: um nome lido num documento permite sondar direto.
4. **Não usou `limpar`.** A Exposição só apareceu na entrega, então o custo foi invisível durante a jogada.
5. **Termos digitados com pequenas diferenças** (`480.000,00` sem o `R$`, `NUTRIBEM`, `CUNHADO`). Na interface, escolher num menu resolve isso.
6. **Baixou só o doc5**, que provava os dois fatos. Esse documento único deixou o fato 2 fácil demais, porque o parentesco veio de um documento não entregue.
7. A ajuda do `preencher` precisou ser pedida: faltou um tutorial do comando.

## Ajustes propostos
| # | Ajuste | Por quê |
|---|---|---|
| A1 | **Iscas mais fortes:** iscas na mesma frase ou na mesma linha da resposta, e com sentido plausível (por exemplo, um segundo pagamento "complementar" à Nutri Bem com outra data) | As iscas não confundiram |
| A2 | **PIN do caso 1 continua fácil** (é tutorial). Dificuldade crescente nos casos 2 a 5, com regras de minigame novas | O PIN foi fácil |
| A3 | **Regra:** sondar ou conectar pelo nome de um nó lido num documento, sem `scan` | O jogador fez isso naturalmente, e isso recompensa a leitura |
| A4 | **Aviso ao sair sem `limpar`:** "Rastros em N nós. Sair mesmo assim?" Ou mostrar a Exposição prevista no HUD | O custo estava invisível |
| A5 | **Fato 2 exige o documento do parentesco** (doc3) a partir do caso 2, com a regra de confirmação | Hoje um único documento resolve tudo |
| A6 | **Interface:** coletar com um clique e preencher lacunas com um menu do caderno | A coleta texto a texto é repetitiva, e a digitação gera variações |
| A7 | **Tutorial contextual** do primeiro uso de cada comando (`preencher`, `ocultar`) | A ajuda precisou ser pedida |

## Limitações deste teste
O jogador é o próprio designer e conhecia o GDD (o conceito, as lacunas e as iscas). Os playtests "às cegas", de 5 a 7 pessoas, continuam necessários no protótipo.
