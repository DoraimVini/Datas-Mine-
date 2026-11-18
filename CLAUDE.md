# Datas_Mine!

Projeto do segundo cérebro `Game_dev_IA`. As regras gerais vêm do `CLAUDE.md` da pasta-mãe (carregado automaticamente). Aqui ficam só as regras **deste** projeto.

- **Conceito:** jogo sobre roubo de dados, um simulador de hacker.
- **Gênero:** Simulador de hacker, playbook em `../Gêneros/Simulador de hacker.md`
- **Repositório:** https://github.com/DoraimVini/Datas-Mine-
- **Configuração do projeto:** `.gamedev.json` (gênero, caminhos, marco atual)
- **GDD:** `02 - Projetos/GDD.md` (v0.1, marco "conceito"; atualize com `/gdd`)
- **Arquitetura:** `02 - Projetos/Arquitetura.md` (arc42 + C4). **Regra de dependência:** o núcleo de regras é puro e não importa UI, render, input nem disco
- **Idioma do jogo:** PT-BR, com todo texto visível em arquivos de dados (decisão 0003)
- **Decisões:** `02 - Projetos/Decisões/` (`NNNN - título.md`)
- **Retros:** `02 - Projetos/Retros/`
- **Código:** projeto Godot em `game/` (ainda não criado)

## Regras específicas
- **Godot 4.7 + GDScript, renderizador Compatibility** (decisão 0004). Este PC tem uma GPU sem Vulkan: nunca mude para Forward+/Mobile.
- **Núcleo puro:** os scripts em `res://nucleo/` não usam `Node`, `get_tree()`, `Input` nem `FileAccess`. Veja a seção 5.4 da arquitetura.
- Estilo de GDScript: siga o guia oficial (`snake_case` para funções e variáveis, `PascalCase` para classes, tipagem estática sempre que possível). Os nomes de domínio ficam em português (`ruido`, `dossie`, `fato`).
- Executável do Godot 4.7.2: `C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe` (use a versão `_console` na linha de comando e nos testes, com `--headless`).
- Documentação offline do Godot 4.7: `C:\Users\werne\GameDevDocs\godot\html\` (busque com Grep antes de pesquisar na web).
- Este repositório também é um cofre do Obsidian: mantenha a estrutura de pastas (`00 - Inbox`, `01 - Notas`, `02 - Projetos`, `03 - Recursos`, `99 - Arquivo`).
