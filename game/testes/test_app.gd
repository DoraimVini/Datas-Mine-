# Testes da camada de aplicação: sessão e validador de conteúdo.
extends "res://testes/base_teste.gd"

const Sessao := preload("res://app/sessao.gd")
const Conteudo := preload("res://app/conteudo.gd")


func test_sessao_sem_caso_nao_quebra() -> void:
	var s := Sessao.new()
	afirmar(tem_evento(s.executar({"tipo": "scan"}), "erro", "sem_caso"))


func test_sessao_executa_e_guarda_historico() -> void:
	var s := Sessao.new()
	igual(s.iniciar("caso1"), [])
	afirmar(tem_evento(s.executar({"tipo": "scan"}), "varredura"))
	igual(s.historico.size(), 1)
	igual(s.estado["ruido"], 10)


func test_validador_pega_custo_ausente() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["custos"].erase("limpar")
	afirmar(Conteudo.validar_caso(caso).any(func(e): return "custos" in e))


func test_validador_pega_feedback_invalido() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["feedback"] = "talvez"
	afirmar(Conteudo.validar_caso(caso).any(func(e): return "feedback" in e))


func test_validador_pega_porta_de_acesso_inexistente() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["nos"]["n3"]["acesso"]["porta"] = 9999
	afirmar(Conteudo.validar_caso(caso).any(func(e): return "9999" in e))


func test_validador_pega_regra_editorial_desconhecida() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["regras_editoriais"].append("regra_inventada")
	afirmar(Conteudo.validar_caso(caso).any(func(e): return "regra_inventada" in e))
