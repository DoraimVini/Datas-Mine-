---
tags: [gdd]
projeto: "Datas_Mine!"
genero: "Simulador de hacker"
versao: 0.3
marco: conceito
atualizado: "2026-11-18"
---

# GDD — Datas_Mine!

Playbook do gênero: `../Gêneros/Simulador de hacker.md` (no cérebro). Decisão de conceito: [[0001 - Conceito central - campanha de casos para a imprensa]]. Plano técnico (rascunho): [[Plano técnico (rascunho)]].

## Visão em uma frase
Um hacktivista começa com invasões pequenas e discretas e escala, caso a caso, até provar e entregar à imprensa um esquema massivo de corrupção, sem expor inocentes e sem ser pego antes da publicação.

> **O título:** "Datas? Mine!" ("Dados? Meus!") é o grito do hacktivista. Os dados pertencem às pessoas, não aos poderosos.

## Inspirações (estrutura, nunca conteúdo)
- **Casos reais de denúncia (informante + jornalista):** o que importa não é o volume de dados, mas **provar, confirmar e publicar com responsabilidade**. Isso inclui o contato seguro, o critério editorial e o preço pessoal. Tudo no jogo é **fictício**: nenhuma pessoa, órgão ou empresa real aparece pelo nome ou pela imagem.
- **Papers, Please:** uma ação simples e clara (conferir um documento contra regras), **regras que crescem a cada caso** e escolhas morais com consequência. Usamos só os princípios de design, nada do conteúdo, visual ou nomes.

## Pilares
1. **Entender antes de agir (quebra-cabeça metódico).** Invadir, ler e deduzir. Sem relógio em tempo real: a tensão vem do planejamento.
2. **Do pequeno ao gigante (progressão).** Cada caso é maior, mais protegido e mais perigoso que o anterior, e cada um entrega as pistas do próximo.
3. **Os documentos contam a história (mistério).** O escândalo se revela em camadas, só pelo que você encontra e liga.
4. **Verdade com responsabilidade (dilema).** Uma prova forte, inocentes protegidos e a sua própria exposição puxam para lados diferentes.

## Público e plataforma
- **PC**, de **1 a 2 horas**, com **5 casos**, de 12 a 20 minutos cada, e um final.
- Para fãs de quebra-cabeça lógico e narrativa ambiental, inclusive quem nunca usou um terminal.

## Loop principal
Cada caso tem três fases, sempre na mesma ordem:

1. **🔓 Invadir:** atravessar a rede do alvo e encontrar documentos, gastando o **orçamento de ruído** do caso.
2. **🧩 Montar o dossiê:** no quadro de evidências, **preencher as lacunas dos fatos** com termos coletados nos documentos, para formar **fatos comprovados**, e ocultar nomes de inocentes.
3. **📰 Entregar:** enviar à jornalista. Ela aplica o **checklist editorial** do caso (as "regras", anunciadas por um memorando da redação), publica ou devolve com um pedido, e a publicação abre o caso seguinte.

- **30 s:** inspecionar um nó, usar uma ferramenta, ler um arquivo, coletar um termo ou preencher uma lacuna.
- **5 min:** completar uma fase de um caso.
- **1 h:** escalar de um vereador de cidade pequena até o esquema nacional.

## A campanha: 5 casos que escalam
| # | Alvo (fictício) | Escândalo | Rede | Jornalista | Regra editorial nova |
|---|---|---|---|---|---|
| 1 | Vereador de cidade pequena | Merenda escolar superfaturada | 3 nós, quase sem defesa | Blogueira local | **Um documento que prove** o fato |
| 2 | Construtora Vértice | Licitação combinada; aparece um pagamento à "Panóptica" | 5 nós, com firewall | Jornal regional | **Confirmação:** cada fato precisa de 2 documentos independentes |
| 3 | Panóptica S.A. (dados) | Venda ilegal de dados pessoais | 7 nós, com logs que denunciam você | Repórter investigativa nacional | **Proteger inocentes:** ocultar nomes de cidadãos comuns |
| 4 | Órgão do governo (fictício) | **Projeto Espelho:** vigilância em massa sem mandado, alimentada pela Panóptica | 8 nós, com proxies e honeypots | A mesma repórter, agora com um jurídico | **Autenticidade:** datas, assinaturas e metadados precisam bater |
| 5 | O esquema | Rede de propinas que liga o vereador, a Vértice, a Panóptica, o órgão e um ministro | 10 nós, combinando tudo | Consórcio de jornais | **Todas as regras juntas** + "quem autorizou?" |

**Como os casos se encadeiam:** os documentos de um caso contêm a pista do próximo (um nome, um contrato, um IP). O jogador **sente** o escândalo crescer.

## Mecânicas
| Mecânica | Descrição | Pilar | Status |
|---|---|---|---|
| **Mapa da rede** | Grafo de nós (servidores, estações, câmeras, proxy, honeypot), revelados com a varredura | 1 | proposta |
| **Orçamento de ruído (por caso)** | Cada ação consome ruído. Se estourar, vem o lockdown: você sai e a rede reinicia, **sem game over**, mas a **Exposição** sobe | 1 | proposta |
| **Exposição (campanha inteira)** | Mede o quanto o sistema sabe sobre você. **Acumula entre os casos.** Ser discreto nos casos pequenos dá margem para os grandes. Sobe com lockdowns, logs não apagados e honeypots. Desce com `limpar rastros` (custa ruído) | 2, 4 | proposta |
| **Ferramentas** | `scan`, `probe`, `crack` (minigame lógico curto, sem tempo), `read` (sem custo), `download`. Ganhas por caso: `limpar rastros`, `spoof`, `script` | 1, 2 | proposta |
| **Pistas nos arquivos** | Senhas e usuários encontrados em arquivos permitem entrar sem `crack` e com pouco ruído. **Um nome de nó lido num documento permite sondar ou conectar direto, sem `scan`** (o jogador descobriu isso sozinho no playtest 1) | 1, 3 | testada ✅ |
| **Aviso de rastros** | Ao sair de uma rede sem `limpar`, o jogo avisa quantos nós ficaram com rastros e a Exposição prevista. A decisão continua com o jogador | 4 | proposta (playtest 1) |
| **Tutorial contextual** | No primeiro uso de cada ferramenta ou comando (`preencher`, `ocultar`...), aparece uma dica curta | — | proposta (playtest 1) |
| **Coleta de termos** | Ao ler um documento, você clica em nomes, valores, datas, empresas e códigos para guardá-los no **caderno de termos**. Só termos coletados podem preencher lacunas | 1, 3 | proposta |
| **Quadro de evidências (lacunas)** | Cada fato do caso aparece como uma frase com lacunas, no estilo *Golden Idol*. Ex.: "`[quem]` pagou `[quanto]` à `[empresa]` em `[quando]`". Você preenche com termos do caderno. Um fato só fica **comprovado** quando todas as lacunas estão certas **e** há documentos que o sustentam. Errar não custa ruído nem Exposição: o fato só não fecha. Casos 4 e 5 têm **sub-fatos** intermediários (quem é quem, linha do tempo) que servem de andaime | 1, 3 | proposta |
| **Ocultar nomes** | Antes de entregar, cobrir os nomes de pessoas comuns. Esquecer um expõe um inocente. Cobrir um nome que era prova enfraquece o caso | 4 | proposta |
| **Memorando da redação** | No começo de cada caso, a regra editorial nova chega **sozinha**, como um memorando curto, sem diálogo nem evento por cima, para não se perder. O memorando fica sempre acessível num painel de regras | 1, 4 | proposta |
| **Checklist editorial** | A jornalista confere o dossiê contra as regras acumuladas do caso, que crescem como no *Papers, Please*. Ela devolve com um pedido claro, apontando **qual regra falhou** ("preciso de uma confirmação do pagamento") | 1, 4 | proposta |
| **Feedback parcial** | Caso 1: a jornalista só diz se o fato está certo ou errado. **A partir do caso 2**, ela diz **quantos campos estão errados** ("2 lacunas não batem"), sem dizer quais. Isso evita a frustração do tudo ou nada sem entregar a resposta. O limite de envios por fato fica para o protótipo decidir | 1 | proposta |
| **Voltar à rede** | Se o dossiê for devolvido, você pode voltar à rede para buscar o que falta. **Ao sair, os nós privados trancam de novo**: voltar exige login ou crack outra vez (ruído), e sair com rastros custa Exposição | 1, 4 | implementada no protótipo |
| **Revelar** | Desfaz um "ocultar": o jogador pode ter coberto uma prova por engano. Ocultar uma resposta do próprio fato (quem ele acusa) tira a força de prova daquele documento **para aquele fato** | 4 | implementada no protótipo |

## Finais (definidos ao fim do caso 5)
Três medidas acumuladas na campanha:
- **Força do caso:** quantos fatos foram comprovados e publicados, somando todos os casos.
- **Inocentes protegidos:** quantos nomes foram ocultados corretamente, contra os que foram expostos.
- **Exposição:** se você foi identificado antes ou depois da publicação final.

| Final | Condição (aproximada) |
|---|---|
| **A verdade vem à tona:** o esquema cai e você desaparece a tempo | Caso forte + inocentes protegidos + Exposição abaixo do limite |
| **Vitória amarga:** o esquema cai, mas inocentes foram expostos | Caso forte + muitos nomes expostos |
| **Desmentido:** a matéria sai fraca, a Panóptica desmente e a história morre | Poucos fatos comprovados |
| **Preso antes da manchete** | Exposição no máximo antes do caso 5 ser publicado |

## Interação: híbrido com progressão ✅
Decidido em [[0002 - Interação híbrida com progressão]].
- **Caso 1:** só o desktop, com apps de botões: mapa da rede, leitor de arquivos, quadro de evidências e chat com a jornalista.
- **Casos 2 e 3:** o **terminal** é destravado. Ele faz as mesmas ações com menos ruído e permite `script`.
- O quadro de evidências e o chat continuam no mouse.
- **Regra de arquitetura:** cada botão executa um comando por baixo. É uma única camada de lógica, chamada pela GUI ou pelo terminal.

## Balanceamento inicial (para ajustar no protótipo)
| Ação | Ruído (base) | Com melhoria |
|---|---|---|
| `scan` | 10 | 6 |
| `probe` | 5 | 3 |
| `crack` | 25 | 15 |
| Entrar com uma pista | 5 | 5 |
| Senha errada | 15 | 15 |
| `read` | 0 | 0 |
| `download` | 15 | 10 |
| `limpar rastros` (por nó) | 10 | 6 |

**Regras de limite:** o lockdown só acontece quando o ruído **passa** do orçamento (chegar exatamente a 100 é permitido). A ação que estouraria o orçamento não acontece.

**Exemplo, caso 1** (orçamento de 100, rede de 3 nós; caminho testado): `scan` (10) + `probe` (5) + `login` (5) + `probe` pelo nome lido (5) + `crack` (25) + `download` (15) = **65**. Limpar os dois nós invadidos (2 × 10) fecha em **85 com Exposição 0**. Cada `limpar` é uma escolha por nó: economizar ruído ou apagar rastros.

## Estética
- Desktop retrô-futurista, tipografia monoespaçada no terminal, paleta escura.
- O quadro de evidências tem visual de "parede de investigação" digital: cartões e linhas.
- Cada jornalista tem uma voz própria no chat (a blogueira é informal, o consórcio é formal).
- Feedback de ruído: o medidor treme e a tela ganha interferência acima de 70%.

## Escopo
### Dentro
5 casos + final, 3 fases por caso, cerca de 8 ferramentas, 2 tipos de minigame de `crack`, quadro de evidências, ocultar nomes, 4 finais, save por caso.

### Fora (por enquanto)
Rotina de dias no trabalho, relógio em tempo real, dinheiro, redes procedurais, multiplayer, dublagem, pessoas ou instituições reais.

## Marcos
| Marco | Critério de pronto | Status |
|---|---|---|
| Conceito | GDD v0.2 aprovado; decisões de conceito ✅, interação ✅ e linguagem registradas | ⏳ |
| Protótipo | **Caso 1 inteiro com formas simples, só no desktop:** rede de 3 nós, `scan`/`probe`/`crack`/`read`/`download`, ruído, 1 pista de senha, coleta de termos, quadro com 1 ou 2 fatos com lacunas, memorando + entrega com checklist de 1 regra. **Validado com 5 a 7 playtests silenciosos** (observar sem explicar; anotar onde travam, que pistas ficam obscuras ou óbvias demais, e se dá para chutar) | |
| Vertical slice | Casos 1 e 2 com arte, som e tutorial; a regra de confirmação funcionando | |
| Alpha | 5 casos jogáveis | |
| Beta | Ocultar nomes, autenticidade, 4 finais, textos completos | |
| Lançamento | Build de PC no itch.io | |

## Perguntas em aberto
1. ~~Interação~~: decidida (0002).
2. ~~Idioma~~: decidido, PT-BR com textos em arquivos de dados ([[0003 - Idioma do jogo - PT-BR]]).
3. **O hacktivista:** tem nome e história (por que começou?) ou é anônimo?
4. **Contatos:** as jornalistas são personagens com arco próprio? (Ex.: a repórter do caso 3 aparece fichada no Projeto Espelho.)
5. ~~Linguagem ou engine~~: decidida, Godot 4.7 + GDScript ([[0004 - Engine e linguagem - Godot 4.7 com GDScript]]).

## Histórico
- 2026-11-18: **Revisão do protótipo (qa-reviewer).** Decisões aplicadas: `limpar` por nó custa 10; os nós privados trancam ao sair; o lockdown só acontece ao passar do orçamento; entra o comando `revelar`; os nomes de prova passam a valer por fato.
- 2026-11-18: **Primeiro playtest** do caso 1, em texto ([[2026-11-18 - Caso 1 em texto (Vini)]]). Diversão confirmada: "fez anotar pistas e nomes". O PIN e as iscas ficaram fáceis demais. Entram a regra do nome lido, o aviso de rastros e o tutorial contextual. Conteúdo em [[Caso 1 - A Merenda de Vila Serena]].
- 2026-11-18: **v0.3.** Aplicadas as propostas de [[Enquadramento de gênero]]: o quadro de evidências passa a usar **fatos com lacunas** e um caderno de termos; entra o **feedback parcial** da jornalista a partir do caso 2; as regras novas chegam por um **memorando da redação**; o protótipo passa a exigir **5 a 7 playtests silenciosos**.
- 2026-11-18: interação definida como híbrido com progressão ([[0002 - Interação híbrida com progressão]]).
- 2026-11-18: **v0.2.** O conceito vira uma campanha de 5 casos que escalam, com entrega à imprensa. Entram inspirações de casos de denúncia (prova, confirmação e proteção de inocentes) e do *Papers, Please* (regras editoriais que crescem). Entram a Exposição acumulada, o quadro de evidências, o ocultar nomes e 4 finais. A rotina de dias na mesa foi descartada. Ver [[0001 - Conceito central - campanha de casos para a imprensa]].
- 2026-11-18: v0.1 criada via `/gdd` (hacktivista; quebra-cabeça + progressão + mistério; PC, 1 a 2 h; redes com orçamento de ruído).
