# Orçamento de ruído e lockdown.
extends RefCounted


## Tenta gastar o custo `chave` (de caso.custos; o validador garante que todas existem).
## Se o gasto PASSAR do orçamento, dispara o lockdown e devolve false: a ação que causou
## o estouro NÃO acontece. Chegar exatamente ao orçamento é permitido.
static func gastar(estado: Dictionary, caso: Dictionary, chave: String, eventos: Array) -> bool:
	var custo: int = caso["custos"][chave]
	if custo == 0:
		return true
	if estado["ruido"] + custo > caso["orcamento_ruido"]:
		lockdown(estado, caso, eventos)
		return false
	estado["ruido"] += custo
	eventos.append({"tipo": "ruido", "custo": custo, "total": estado["ruido"], "orcamento": caso["orcamento_ruido"]})
	return true


## A rede detecta a invasão: desconecta, reinicia a rede do caso e aumenta a Exposição.
## O caderno, os documentos lidos e o pendrive são mantidos.
static func lockdown(estado: Dictionary, caso: Dictionary, eventos: Array) -> void:
	var ganho: int = caso["exposicao"]["lockdown"]
	estado["exposicao"] += ganho
	estado["ruido"] = 0
	estado["conectado"] = false
	estado["no_atual"] = ""
	estado["minigame"] = {}
	estado["aviso_rastros"] = false
	for id in estado["nos"]:
		var no: Dictionary = estado["nos"][id]
		no["revelado"] = id == caso["no_inicial"]
		no["sondado"] = false
		no["desbloqueado"] = caso["nos"][id]["publico"]
		no["rastro"] = false
	eventos.append({"tipo": "lockdown", "exposicao_ganha": ganho, "exposicao": estado["exposicao"]})
