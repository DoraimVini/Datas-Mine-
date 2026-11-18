# Base dos testes: asserções simples que registram falhas (decisão 0007).
extends RefCounted

var falhas: Array = []
var _teste_atual := ""


func _falhar(msg: String) -> void:
	falhas.append("%s: %s" % [_teste_atual, msg])


func afirmar(condicao: bool, msg: String = "condição falsa") -> void:
	if not condicao:
		_falhar(msg)


func igual(obtido, esperado, msg: String = "") -> void:
	if typeof(obtido) != typeof(esperado) or obtido != esperado:
		_falhar("%s esperado <%s>, obtido <%s>" % [msg, str(esperado), str(obtido)])


## Verifica se algum evento tem o tipo (e o código de erro, se informado).
func tem_evento(eventos: Array, tipo: String, codigo: String = "") -> bool:
	for e in eventos:
		if e["tipo"] == tipo and (codigo == "" or e.get("codigo", "") == codigo):
			return true
	return false
