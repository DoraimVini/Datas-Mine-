# Datas_Mine! — projeto Godot

Godot 4.7 + GDScript, renderizador Compatibility. Arquitetura em `../02 - Projetos/Arquitetura.md`.

```
nucleo/          regras puras (sem Node): estado, comandos, invasão, ruído, dossiê, editorial
app/             conteúdo (carregar e validar JSON), sessão, autoload Jogo (ponte com a interface)
conteudo/        casos (JSON) e textos de interface em PT-BR
prototipo_texto/ console jogável no terminal (sem interface gráfica)
testes/          executor próprio + testes do núcleo e do conteúdo
ui/              (futuro) cenas Control + grafos .torch do Orchestrator
```

## Comandos (no PowerShell, dentro de `game/`)
Defina o executável uma vez por terminal:
```powershell
$godot = "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe"
```

Jogar o protótipo de texto:
```powershell
& $godot --headless --path . -s res://prototipo_texto/console.gd
```

Rodar os testes:
```powershell
& $godot --headless --path . -s res://testes/executar.gd
```

Abrir no editor:
```powershell
& "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64.exe" --path . -e
```
