---
tags: [genero, pesquisa, norte]
projeto: "Datas_Mine!"
criado: 2026-11-18
---

# Enquadramento de gênero — Datas_Mine!

Ligado ao [[GDD]]. Playbooks no cérebro: `../Gêneros/Simulador de hacker.md`, `../Gêneros/Jogo de dedução e investigação.md` e `../Gêneros/Jogo de inspeção de documentos.md`.

## Onde o jogo se encaixa
O Datas_Mine! é um **híbrido de três gêneros**, e cada fase do caso pertence a um deles:

| Fase do caso | Gênero | Linhagem / referência | O que pegamos |
|---|---|---|---|
| 🔓 Invadir | **Simulador de hacker** | Fantasia cinematográfica (*Uplink*, *Hacknet*) | Interface diegética, sensação de elite, progressão de ferramentas |
| 🧩 Dossiê | **Dedução / investigação** | *Golden Idol*, *Obra Dinn*, *Her Story* | Resposta estruturada, verificação contra o chute, o "aha!" |
| 📰 Entrega | **Inspeção de documentos** | *Papers, Please* | Regras que crescem, dilemas sem resposta certa |

**Categoria mais ampla:** *thinky game* / puzzle narrativo. Tags prováveis de loja: Hacking, Puzzle, Detective, Investigation, Narrative, Simulation, Mystery.

**Diferencial:** quase nenhum jogo de hacker termina em **jornalismo** (provar, confirmar e proteger inocentes). E quase nenhum jogo de dedução tem **risco acumulado** (a Exposição). Essa combinação é a identidade do jogo.

## O norte: práticas que o GDD deve seguir

### Invadir (hacker)
- [ ] Simular a **sensação**, não a realidade. Comandos plausíveis, sem exigir conhecimento técnico.
- [ ] Ensinar **uma ferramenta por vez**, uma por caso.
- [ ] Interface densa e legível, com hierarquia clara do que importa agora.
- [ ] Feedback sensorial: teclas, texto rolando, medidor de ruído pulsando.
- [ ] Sistemas consistentes: arquivos e permissões com regras coerentes, para o jogador poder experimentar.

### Dossiê (dedução)
- [ ] Trocar a "ligação livre de documentos" por **fatos com lacunas** no estilo *Golden Idol*. Exemplo: "`[Vereador Souza]` pagou `[R$ 480 mil]` à `[Nutri Bem Ltda]` em `[março]`", preenchido com termos **coletados** dos documentos.
- [ ] **Contra o chute:** a jornalista só confirma quando **todos os campos de um fato** estão certos, ou dá um feedback parcial ("há campos errados") a partir do caso 2.
- [ ] **Andaimes** nos casos 4 e 5: sub-fatos intermediários (quem é quem, a linha do tempo) antes do fato principal.
- [ ] **Pistas mínimas** por caso, mais 1 ou 2 despistas com propósito.
- [ ] Vários caminhos para provar o mesmo fato (dois documentos diferentes que confirmam a mesma coisa).

### Entrega (inspeção)
- [ ] **Uma regra editorial nova por caso**, anunciada **sozinha** (sem diálogo por cima), como um "memorando da redação".
- [ ] Mostrar **o que** falhou no checklist, nunca só "recusado".
- [ ] Dilemas sem resposta certa: um nome que é prova **e** inocente ao mesmo tempo; um fato forte que exige voltar à rede com Exposição alta.
- [ ] Tom sério, com respiros de humor (a comunicação corporativa da Panóptica, a blogueira informal).

### Processo
- [ ] **Protótipo da mecânica antes do tema:** o caso 1 com formas simples, só o desktop.
- [ ] **Playtest em silêncio:** de 5 a 7 pessoas no caso 1, observando onde travam.
- [ ] Os documentos e as regras vêm de **dados** (JSON), para ajustar sem mexer em código.
- [ ] Escopo técnico simples de propósito: pouca arte, sem dublagem.

## Mudanças no GDD: aplicadas na v0.3 ✅ (2026-11-18)
1. **O quadro de evidências passa a funcionar com lacunas**, em vez de ligações livres. Isso resolve o risco de "burocracia" e o problema do chute de uma vez.
2. **Feedback parcial da jornalista** a partir do caso 2 ("2 campos estão errados").
3. **Memorando da redação** como forma de anunciar as regras novas.
4. **Meta de playtest** no marco do protótipo: de 5 a 7 sessões silenciosas.
