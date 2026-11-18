# Testes de conteúdo: o caso carrega, é válido e tem solução (Arquitetura 8.3).
extends "res://testes/base_teste.gd"

const Conteudo := preload("res://app/conteudo.gd")


func test_caso1_carrega_e_e_valido() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	afirmar(not caso.is_empty(), "caso1.json não carregou")
	var erros := Conteudo.validar_caso(caso)
	igual(erros, [], "erros de validação:")


func test_validador_pega_resposta_impossivel() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["termos"]["fantasma"] = {"rotulo": "Fulano Fantasma", "tipo": "pessoa"}
	caso["fatos"]["fato1"]["respostas"]["quem"] = "fantasma"
	var erros := Conteudo.validar_caso(caso)
	afirmar(erros.any(func(e): return "impossível" in e), "deveria acusar resposta que não aparece em documento")


func test_validador_pega_termo_sem_marcacao_no_texto() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["documentos"]["doc1"]["texto"] = ["texto sem marcações"]
	var erros := Conteudo.validar_caso(caso)
	afirmar(erros.any(func(e): return "não marca" in e), "deveria acusar termo não marcado")


func test_textos_do_console_carregam() -> void:
	var textos := Conteudo.carregar_json("res://conteudo/textos/console.json")
	afirmar(textos.has("erros") and textos.has("eventos"), "console.json sem 'erros'/'eventos'")
