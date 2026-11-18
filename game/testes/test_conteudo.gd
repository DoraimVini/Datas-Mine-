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


# Todo comando que o console aceita precisa ter manual (o /help dentro do jogo).
const COMANDOS_DO_CONSOLE := [
	"scan", "probe", "connect", "login", "crack", "pin", "ls", "read", "download", "limpar", "disconnect",
	"coletar", "caderno", "fatos", "preencher", "limpar-lacuna", "ocultar", "revelar",
	"pendrive", "memorando", "entregar", "rede", "help", "sair",
]


func test_manual_cobre_todos_os_comandos() -> void:
	var m: Dictionary = Conteudo.carregar_json("res://conteudo/textos/console.json")["manual"]
	var caso := Conteudo.carregar_caso("caso1")
	var nos_grupos := []
	for g in m["grupos"]:
		nos_grupos.append_array(g["comandos"])
	for c in COMANDOS_DO_CONSOLE:
		afirmar(m["comandos"].has(c), "comando sem manual: %s" % c)
		afirmar(c in nos_grupos, "comando fora dos grupos do help: %s" % c)
		var entrada: Dictionary = m["comandos"].get(c, {})
		for k in ["uso", "resumo", "explicacao", "exemplo"]:
			afirmar(entrada.has(k), "manual de %s sem '%s'" % [c, k])
		for k in ["custo", "custo_erro"]:
			if entrada.has(k):
				afirmar(caso["custos"].has(entrada[k]), "manual de %s cita custo inexistente '%s'" % [c, entrada[k]])


func test_iscas_do_fato1_estao_perto_da_resposta() -> void:
	# A1 do playtest: as iscas precisam estar no MESMO documento que a resposta, para obrigar a ler com atenção.
	var caso := Conteudo.carregar_caso("caso1")
	var doc4: Array = caso["documentos"]["doc4"]["termos"]
	for isca in ["valor_120k", "data_adiantamento"]:
		afirmar(isca in caso["fatos"]["fato1"]["iscas"], "isca %s não registrada no fato1" % isca)
		afirmar(isca in doc4, "isca %s deveria estar no doc4, junto do pagamento real" % isca)
	afirmar("data_assinatura" in caso["documentos"]["doc5"]["termos"], "data de assinatura deveria estar no contrato")


func test_validador_pega_isca_que_e_resposta() -> void:
	var caso := Conteudo.carregar_caso("caso1")
	caso["fatos"]["fato1"]["iscas"].append("antonio_souza")
	afirmar(Conteudo.validar_caso(caso).any(func(e): return "também uma resposta" in e))
