# Datas_Mine! — projeto Godot

Godot 4.7 + GDScript + Orchestrator 2.5 (visual scripting), renderizador Compatibility. Arquitetura em `../02 - Projetos/Arquitetura.md`.

```
nucleo/            regras puras (sem Node): estado, comandos, invasão, ruído, dossiê, editorial
app/               autoload Jogo (+ log de playtest), sessão, conteúdo (carregar e validar JSON), parser, telemetria
ui/                interface ÉterOS: Desktop, janela arrastável, 7 apps, tema, PonteJogo (para os grafos)
prototipo_texto/   console jogável no terminal
conteudo/          casos (JSON) e textos PT-BR (console.json, interface.json)
addons/orchestrator/  plugin de visual scripting (só binários Windows)
testes/            executor próprio + testes (núcleo, app, conteúdo, telemetria, UI)
```

## Comandos (PowerShell, dentro de `game/`)
```powershell
$godot = "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe"
$editor = "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64.exe"
```

Jogar com interface (código do jogador opcional, para o log de playtest):
```powershell
& $editor --path . -- caso1 P01
```

Jogar no terminal (protótipo de texto):
```powershell
& $godot --headless --path . -s res://prototipo_texto/console.gd -- caso1 P01
```

Rodar os testes (use o script: com o Orchestrator, o Godot dá segfault ao fechar e o código de saída não é confiável — issue #1864):
```powershell
powershell -ExecutionPolicy Bypass -File testes/rodar.ps1
```

Abrir no editor:
```powershell
& $editor --path . -e
```

Captura de tela automática (confere o visual num estado do jogo):
```powershell
& $editor --path . -- caso1 anonimo --comandos "scan;probe gab-educacao-03" --abrir rede,arquivos --captura C:/caminho/tela.png
```

Logs de playtest: `%APPDATA%\Godot\app_userdata\Datas_Mine!\playtests\`.
