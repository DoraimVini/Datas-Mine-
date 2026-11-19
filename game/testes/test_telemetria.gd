# Testes das métricas de playtest.
extends "res://testes/base_teste.gd"

const Sessao := preload("res://app/sessao.gd")
const Telemetria := preload("res://app/telemetria.gd")


func _jogar(cmds: Array) -> Dictionary:
	var s := Sessao.new()
	s.iniciar("caso1")
	var registros := []
	var tempo := 0.0
	for c in cmds:
		tempo += 1.0
		registros.append({"t": tempo, "comando": c, "eventos": s.executar(c)})
	return Telemetria.metricas(s.caso, registros, s.estado, {"consultas": {"help": 2}})


func test_conta_erros_e_iscas() -> void:
	var m := _jogar([
		{"tipo": "scan"},
		{"tipo": "login", "no": "gab-educacao-03", "usuario": "lucia.prado", "senha": "errada"},
		{"tipo": "login", "no": "gab-educacao-03", "usuario": "lucia.prado", "senha": "pipoca2019"},
		{"tipo": "read", "doc": "doc4"},
		{"tipo": "coletar", "termo": "R$ 120.000,00"},
		{"tipo": "preencher", "fato": "fato1", "lacuna": "quanto", "termo": "R$ 120.000,00"},
		{"tipo": "read", "doc": "doc9"},
	])
	igual(m["contagem"]["senhas_erradas"], 1)
	igual(m["iscas_tentadas"].size(), 1)
	igual(m["iscas_tentadas"][0]["termo"], "valor_120k")
	igual(m["erros_por_codigo"].get("doc_inacessivel"), 1)
	igual(m["comandos"], 7)
	igual(m["duracao_s"], 7)
	igual(m["consultas"], {"help": 2}, "extras são mesclados:")
	afirmar(not m["concluido"])


func test_partida_vazia_nao_quebra() -> void:
	var s := Sessao.new()
	s.iniciar("caso1")
	var m := Telemetria.metricas(s.caso, [], s.estado)
	igual(m["comandos"], 0)
	igual(m["tempo_ate_conclusao_s"], -1)
