---
tags: [playtest, kit]
projeto: "Datas_Mine!"
versao: 1
---

# Kit de playtest 1/3 — Roteiro do facilitador

Kit: **1 Roteiro** · [[2 - Ficha de observação]] · [[3 - Perguntas pós-jogo]]. Meta do marco Protótipo ([[GDD]]): **5 a 7 sessões às cegas**, com pessoas que não conhecem o GDD.

> **Regra de ouro:** você observa, não ensina. Cada vez que você explica algo, perde o dado de "o jogo ensinou isso?" (princípio do playtest silencioso, veja `Gêneros/Jogo de dedução e investigação.md` no cérebro).

## Antes (5 min)
- [ ] Feche o gabarito (`Casos/Caso 1...`) e o `caso1.json`. A pessoa não pode ver.
- [ ] Abra o PowerShell na pasta `game/` e rode o jogo com o **código do jogador** (P01, P02...):
  ```powershell
  & "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://prototipo_texto/console.gd -- caso1 P01
  ```
- [ ] Deixe papel e caneta ao lado da pessoa (anotar faz parte do jogo).
- [ ] Copie a [[2 - Ficha de observação]] para `Playtests/AAAA-MM-DD - P01.md`.
- [ ] Marque o horário de início.

## O que dizer (leia igual para todo mundo)
> "Este é um protótipo de um jogo em texto. Você é um hacker que vai investigar um caso. Tudo o que você precisa está no jogo; digite `help` quando quiser. Pense em voz alta: fale o que está tentando fazer e o que espera que aconteça. Não existe resposta errada: se travar, é o jogo que precisa melhorar, não você. Vou ficar só observando e não posso ajudar durante a partida. Pode começar."

## Durante
- **Não ajude.** Se a pessoa perguntar algo, responda: *"O que você acha que deveria fazer?"* ou *"O que o jogo te diz?"*.
- **Exceção:** se ela travar por **mais de 5 minutos** sem nenhum progresso, dê **uma** dica neutra (*"Já leu todos os documentos que encontrou?"*) e **anote na ficha** o momento e a dica.
- Anote **falas em voz alta** marcantes (literalmente, entre aspas).
- Anote expressões: frustração, surpresa, o momento de "aha!".
- Se ela quiser parar, deixe. Anote onde parou e por quê.
- **Tempo máximo:** 40 min. Passou disso, encerre com gentileza e anote.

## Depois (10 min)
1. O jogo salva o registro sozinho ao terminar ou ao digitar `sair`. O caminho aparece no fim da tela, em `...\app_userdata\Datas_Mine!\playtests\`.
2. Faça as [[3 - Perguntas pós-jogo]], **na ordem e sem comentar** as respostas.
3. Só **depois** das perguntas, se ela quiser, explique o que não ficou claro.
4. Agradeça.

## Depois da sessão (sozinho)
- [ ] Preencha a seção "Do registro automático" da ficha com as métricas do JSON (ou peça ao Claude: *"analisa o log do P01"*).
- [ ] Ao fim de **todas** as sessões: peça ao Claude um consolidado, depois rode `/retro` para levar as lições ao cérebro.

## Quem convidar
- Pessoas que **não** viram o GDD nem ouviram você explicar o jogo.
- Misture perfis: quem joga quebra-cabeça e quem não joga, quem já usou terminal e quem nunca usou.
- Evite quem vai elogiar só para agradar (amigos muito próximos). Se forem eles, reforce que o objetivo é achar problemas.
