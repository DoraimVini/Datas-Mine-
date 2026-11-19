# Formatações de texto compartilhadas entre o console e a interface (uma fonte só).
extends RefCounted


## Texto do custo de ruído de um comando do manual: "5 (erro: 15)", "15 se errar"...
## Os números vêm do caso (dados), nunca fixos no texto.
static func custo_do_comando(entrada_manual: Dictionary, custos: Dictionary) -> String:
	var txt := str(int(custos[entrada_manual["custo"]]))
	if entrada_manual.has("custo_rotulo"):
		txt += " " + str(entrada_manual["custo_rotulo"])
	if entrada_manual.has("custo_erro"):
		txt += " (erro: %d)" % int(custos[entrada_manual["custo_erro"]])
	return txt
