# Roda a suíte de testes e devolve um código de saída CONFIÁVEL.
# Por quê: com o Orchestrator carregado, o Godot dá segfault AO FECHAR no Windows
# (bug aberto: github.com/CraterCrash/godot-orchestrator/issues/1864), e o código de saída vira 139
# mesmo com tudo passando. Então o resultado é lido da linha final "N testes, M falhas".
# Uso (de qualquer pasta):  powershell -ExecutionPolicy Bypass -File game/testes/rodar.ps1
$ErrorActionPreference = "Continue"  # o Godot escreve erros no stderr; não pode abortar o script
$godot = if ($env:GODOT_CONSOLE) { $env:GODOT_CONSOLE } else { "C:\Users\werne\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe" }
$projeto = Split-Path -Parent $PSScriptRoot

$saida = & $godot --headless --path $projeto -s res://testes/executar.gd 2>&1 | ForEach-Object { "$_" }
$saida | Where-Object { $_ -notmatch "^\s+ok\s" } | Write-Output

$linha = $saida | Where-Object { $_ -match "^(\d+) testes, (\d+) falhas$" } | Select-Object -Last 1
if (-not $linha) {
    Write-Output "RESULTADO: a suíte não terminou (sem a linha final de resumo)."
    exit 2
}
$null = $linha -match "^(\d+) testes, (\d+) falhas$"
if ([int]$Matches[2] -eq 0) { Write-Output "RESULTADO: OK"; exit 0 }
Write-Output "RESULTADO: FALHA"
exit 1
