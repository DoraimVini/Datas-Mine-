# Testes de unidade e de cenário do núcleo, usando o conteúdo real do caso 1.
extends "res://testes/base_teste.gd"

const Conteudo := preload("res://app/conteudo.gd")
const Estado := preload("res://nucleo/estado.gd")
const Comandos := preload("res://nucleo/comandos.gd")
const Util := preload("res://nucleo/util.gd")
const Editorial := preload("res://nucleo/editorial.gd")

var caso := Conteudo.carregar_caso("caso1")


## Aplica uma sequência de comandos e devolve {estado, eventos (do último comando)}.
func rodar(cmds: Array, estado: Dictionary = {}) -> Dictionary:
	var e: Dictionary = estado if not estado.is_empty() else Estado.novo(caso)
	var ultimos := []
	for c in cmds:
		var r := Comandos.aplicar(e, caso, c)
		e = r["estado"]
		ultimos = r["eventos"]
	return {"estado": e, "eventos": ultimos}


# Caminho até ficar logado no gabinete (custo 10 + 5 + 5 = 20).
var ATE_GABINETE := [
	{"tipo": "scan"},
	{"tipo": "probe", "no": "gab-educacao-03"},
	{"tipo": "login", "no": "gab-educacao-03", "usuario": "lucia.prado", "senha": "pipoca2019"},
]


# --- util ---

func test_normalizar_remove_acentos_e_simbolos() -> void:
	igual(Util.normalizar("Antônio Souza"), "antoniosouza")
	igual(Util.normalizar("R$ 480.000,00"), "r48000000")


func test_achar_termo_aceita_valor_sem_cifrao() -> void:
	igual(Util.achar_termo(caso, ["valor_480k"], "480.000,00"), "valor_480k")
	igual(Util.achar_termo(caso, ["nutri_bem"], "NUTRI BEM LTDA"), "nutri_bem")
	igual(Util.achar_termo(caso, ["nutri_bem"], "Nutri Bom"), "")


# --- pureza ---

func test_aplicar_nao_altera_o_estado_original() -> void:
	var original := Estado.novo(caso)
	var copia := original.duplicate(true)
	Comandos.aplicar(original, caso, {"tipo": "scan"})
	igual(original, copia, "o estado original mudou:")


# --- invasão ---

func test_scan_revela_vizinhos_e_custa_10() -> void:
	var r := rodar([{"tipo": "scan"}])
	afirmar(r["estado"]["nos"]["n2"]["revelado"], "n2 deveria ser revelado")
	igual(r["estado"]["ruido"], 10)


func test_login_no_inexistente_nao_custa_nada() -> void:
	var r := rodar([{"tipo": "login", "no": "Intranet", "usuario": "lucia.prado", "senha": "x"}])
	afirmar(tem_evento(r["eventos"], "erro", "no_desconhecido"))
	igual(r["estado"]["ruido"], 0)


func test_senha_errada_custa_15_e_nao_entra() -> void:
	var r := rodar([{"tipo": "scan"}, {"tipo": "login", "no": "gab-educacao-03", "usuario": "lucia.prado", "senha": "Pipoca.2019"}])
	afirmar(tem_evento(r["eventos"], "senha_errada"))
	igual(r["estado"]["ruido"], 25)
	igual(r["estado"]["no_atual"], "n1")


func test_login_certo_entra_e_deixa_rastro() -> void:
	var r := rodar(ATE_GABINETE)
	igual(r["estado"]["no_atual"], "n2")
	afirmar(r["estado"]["nos"]["n2"]["rastro"], "login deveria deixar rastro")
	igual(r["estado"]["ruido"], 20)


func test_nome_lido_permite_sondar_sem_scan() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append({"tipo": "probe", "no": "srv-contratos"})
	var sem_ler := rodar(cmds)
	afirmar(tem_evento(sem_ler["eventos"], "erro", "no_desconhecido"), "sem ler o doc3, srv-contratos é desconhecido")
	cmds.insert(3, {"tipo": "read", "doc": "doc3"})
	var lendo := rodar(cmds)
	afirmar(tem_evento(lendo["eventos"], "sondagem"), "depois de ler o doc3, deveria sondar")
	igual(lendo["estado"]["ruido"], 25)


func test_crack_e_pin() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "scan"}, {"tipo": "crack", "no": "srv-contratos", "porta": 445}, {"tipo": "pin", "codigo": "123"}])
	var errado := rodar(cmds)
	afirmar(tem_evento(errado["eventos"], "pin_errado"))
	igual(errado["estado"]["ruido"], 20 + 10 + 25 + 15)
	cmds.append({"tipo": "pin", "codigo": "291"})
	var certo := rodar(cmds)
	afirmar(tem_evento(certo["eventos"], "pin_ok"))
	igual(certo["estado"]["no_atual"], "n3")


func test_read_exige_estar_no_no_do_documento() -> void:
	var r := rodar([{"tipo": "read", "doc": "doc5"}])
	afirmar(tem_evento(r["eventos"], "erro", "doc_inacessivel"))


func test_estouro_de_ruido_dispara_lockdown_e_cancela_a_acao() -> void:
	var e := Estado.novo(caso)
	e["ruido"] = 95
	var r := Comandos.aplicar(e, caso, {"tipo": "scan"})
	afirmar(tem_evento(r["eventos"], "lockdown"))
	igual(r["estado"]["ruido"], 0)
	igual(r["estado"]["exposicao"], 20)
	afirmar(not r["estado"]["conectado"], "lockdown deveria desconectar")
	afirmar(not r["estado"]["nos"]["n2"]["revelado"], "a ação que estourou não deveria acontecer")


func test_sair_com_rastros_avisa_antes_e_cobra_exposicao() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append({"tipo": "disconnect"})
	var aviso := rodar(cmds)
	afirmar(tem_evento(aviso["eventos"], "aviso_rastros"), "primeiro disconnect deveria só avisar")
	afirmar(aviso["estado"]["conectado"])
	cmds.append({"tipo": "disconnect"})
	var saiu := rodar(cmds)
	afirmar(not saiu["estado"]["conectado"])
	igual(saiu["estado"]["exposicao"], 10)


func test_limpar_evita_exposicao() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "limpar"}, {"tipo": "disconnect"}])
	var r := rodar(cmds)
	afirmar(not r["estado"]["conectado"], "sem rastros, sai direto")
	igual(r["estado"]["exposicao"], 0)
	igual(r["estado"]["ruido"], 30)


# --- dossiê ---

func test_coletar_exige_documento_lido() -> void:
	var r := rodar([{"tipo": "coletar", "termo": "Antônio Souza"}])
	afirmar(tem_evento(r["eventos"], "erro", "termo_nao_encontrado"))
	r = rodar([{"tipo": "read", "doc": "doc1"}, {"tipo": "coletar", "termo": "antonio souza"}])
	igual(r["estado"]["caderno"], ["antonio_souza"])


func test_preencher_exige_termo_no_caderno() -> void:
	var r := rodar([{"tipo": "preencher", "fato": "fato1", "lacuna": "quem", "termo": "Antônio Souza"}])
	afirmar(tem_evento(r["eventos"], "erro", "termo_fora_do_caderno"))


# --- cenários completos ---

func _caminho_vitoria() -> Array:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([
		{"tipo": "read", "doc": "doc3"}, {"tipo": "coletar", "termo": "cunhado"},
		{"tipo": "limpar"},
		{"tipo": "probe", "no": "srv-contratos"},
		{"tipo": "crack", "no": "srv-contratos", "porta": 445}, {"tipo": "pin", "codigo": "291"},
		{"tipo": "read", "doc": "doc5"},
		{"tipo": "coletar", "termo": "Antônio Souza"}, {"tipo": "coletar", "termo": "R$ 480.000,00"},
		{"tipo": "coletar", "termo": "Nutri Bem Ltda"}, {"tipo": "coletar", "termo": "14/03/2026"},
		{"tipo": "coletar", "termo": "Rogério Souza Lima"},
		{"tipo": "download", "doc": "doc5"},
		{"tipo": "limpar"},
		{"tipo": "disconnect"},
		{"tipo": "preencher", "fato": "fato1", "lacuna": "quem", "termo": "Antônio Souza"},
		{"tipo": "preencher", "fato": "fato1", "lacuna": "quanto", "termo": "R$ 480.000,00"},
		{"tipo": "preencher", "fato": "fato1", "lacuna": "empresa", "termo": "Nutri Bem Ltda"},
		{"tipo": "preencher", "fato": "fato1", "lacuna": "quando", "termo": "14/03/2026"},
		{"tipo": "preencher", "fato": "fato2", "lacuna": "empresa", "termo": "Nutri Bem Ltda"},
		{"tipo": "preencher", "fato": "fato2", "lacuna": "sócio", "termo": "Rogério Souza Lima"},
		{"tipo": "preencher", "fato": "fato2", "lacuna": "parentesco", "termo": "cunhado"},
		{"tipo": "preencher", "fato": "fato2", "lacuna": "quem", "termo": "Antônio Souza"},
		{"tipo": "ocultar", "doc": "doc5", "nome": "Joana Alves"},
	])
	return cmds


func test_cenario_vitoria_caminho_ideal() -> void:
	var cmds := _caminho_vitoria()
	cmds.append({"tipo": "entregar"})
	var r := rodar(cmds)
	afirmar(tem_evento(r["eventos"], "caso_concluido"), "o caminho ideal deveria concluir o caso: %s" % str(r["eventos"]))
	igual(r["estado"]["resultado"].get("forca"), 2)
	igual(r["estado"]["resultado"].get("inocentes_protegidos"), 1)
	igual(r["estado"]["ruido"], 85, "caminho ideal (65 + limpar 10 + limpar 10):")
	igual(r["estado"]["exposicao"], 0, "limpar os dois nós deveria zerar a Exposição:")


func test_entregar_conectado_e_bloqueado() -> void:
	var r := rodar([{"tipo": "entregar"}])
	afirmar(tem_evento(r["eventos"], "erro", "entregar_conectado"))


func test_isca_e_recusada_e_ocultar_prova_enfraquece() -> void:
	var cmds := _caminho_vitoria()
	var com_isca := cmds.duplicate()
	# Trocar a empresa certa pela isca exige coletá-la: o doc4 não foi lido no caminho, então a troca é pelo
	# parentesco "irmão" do doc3, que foi lido.
	com_isca.append_array([{"tipo": "coletar", "termo": "irmão"}, {"tipo": "preencher", "fato": "fato2", "lacuna": "parentesco", "termo": "irmão"}, {"tipo": "entregar"}])
	var r := rodar(com_isca)
	afirmar(tem_evento(r["eventos"], "parecer_recusado"), "a isca deveria ser recusada")

	var prova_oculta := cmds.duplicate()
	prova_oculta.append_array([{"tipo": "ocultar", "doc": "doc5", "nome": "Antônio Souza"}, {"tipo": "entregar"}])
	r = rodar(prova_oculta)
	afirmar(tem_evento(r["eventos"], "parecer_recusado"), "ocultar um nome de prova deveria deixar o fato sem prova")

	# ALTA da revisão: o jogador precisa conseguir desfazer e concluir o caso.
	prova_oculta.append_array([{"tipo": "revelar", "doc": "doc5", "nome": "Antônio Souza"}, {"tipo": "entregar"}])
	r = rodar(prova_oculta)
	afirmar(tem_evento(r["eventos"], "caso_concluido"), "depois de revelar, o caso deveria concluir")


# --- correções da revisão do qa-reviewer ---

func _estado_vitoria_antes_de_entregar() -> Dictionary:
	return rodar(_caminho_vitoria())["estado"]


func test_nomes_de_prova_valem_por_fato() -> void:
	var e := _estado_vitoria_antes_de_entregar()
	e["ocultos"]["doc5"].append("rogerio_souza_lima")
	var parecer := Editorial.avaliar(e, caso)
	igual(parecer["fatos"][0]["status"], "confirmado", "fato1 não cita Rogério:")
	igual(parecer["fatos"][1]["status"], "sem_prova", "fato2 acusa Rogério:")


func test_inocentes_contam_em_todos_os_documentos_do_pendrive() -> void:
	var e := _estado_vitoria_antes_de_entregar()
	e["pendrive"] = ["doc4", "doc5", "doc6"]
	var parecer := Editorial.avaliar(e, caso)
	igual(parecer["inocentes_total"], 3)
	igual(parecer["inocentes_protegidos"], 1)


func test_feedback_parcial_conta_campos_errados() -> void:
	var parcial: Dictionary = caso.duplicate(true)
	parcial["feedback"] = "parcial"
	var e := _estado_vitoria_antes_de_entregar()
	e["fatos"]["fato1"]["quanto"] = "valor_96k"
	e["fatos"]["fato1"]["quando"] = "data_2025"
	var parecer := Editorial.avaliar(e, parcial)
	igual(parecer["fatos"][0].get("campos_errados"), 2)
	afirmar(not Editorial.avaliar(e, caso)["fatos"][0].has("campos_errados"), "feedback binário não conta campos")


func test_ruido_exatamente_no_orcamento_e_permitido() -> void:
	var e := Estado.novo(caso)
	e["ruido"] = 90
	var r := Comandos.aplicar(e, caso, {"tipo": "scan"})
	afirmar(not tem_evento(r["eventos"], "lockdown"), "chegar a 100 não é estourar")
	igual(r["estado"]["ruido"], 100)


func test_crack_repetido_nao_cobra_de_novo() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "scan"}, {"tipo": "crack", "no": "srv-contratos", "porta": 445}, {"tipo": "crack", "no": "srv-contratos", "porta": 445}])
	var r := rodar(cmds)
	afirmar(tem_evento(r["eventos"], "erro", "minigame_em_andamento"))
	igual(r["estado"]["ruido"], 55)


func test_pin_errado_pode_causar_lockdown() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "scan"}, {"tipo": "crack", "no": "srv-contratos", "porta": 445}])
	var e: Dictionary = rodar(cmds)["estado"]
	e["ruido"] = 90
	var r := Comandos.aplicar(e, caso, {"tipo": "pin", "codigo": "111"})
	afirmar(tem_evento(r["eventos"], "lockdown"))
	afirmar(r["estado"]["minigame"].is_empty(), "lockdown encerra o quebra-cabeça")


func test_sair_tranca_nos_privados_de_novo() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "limpar"}, {"tipo": "disconnect"}, {"tipo": "connect", "no": "gab-educacao-03"}])
	var r := rodar(cmds)
	afirmar(tem_evento(r["eventos"], "erro", "no_bloqueado"), "voltar ao gabinete deveria exigir login de novo")
	cmds.append_array([
		{"tipo": "connect", "no": "portal.vilaserena.gov"},
		{"tipo": "login", "no": "gab-educacao-03", "usuario": "lucia.prado", "senha": "pipoca2019"},
	])
	r = rodar(cmds)
	igual(r["estado"]["no_atual"], "n2")
	igual(r["estado"]["ruido"], 30 + 5, "o novo login custa ruído:")


func test_aviso_de_rastros_vale_so_para_o_disconnect_seguinte() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "disconnect"}, {"tipo": "ls"}, {"tipo": "disconnect"}])
	var r := rodar(cmds)
	afirmar(tem_evento(r["eventos"], "aviso_rastros"), "outro comando no meio zera o aviso")
	afirmar(r["estado"]["conectado"])


func test_limpar_lacuna() -> void:
	var e := _estado_vitoria_antes_de_entregar()
	var r := Comandos.aplicar(e, caso, {"tipo": "limpar_lacuna", "fato": "fato1", "lacuna": "quem"})
	igual(r["estado"]["fatos"]["fato1"]["quem"], "")
	r = Comandos.aplicar(r["estado"], caso, {"tipo": "entregar"})
	afirmar(tem_evento(r["eventos"], "erro", "fatos_incompletos"))


func test_ocultar_repetido_e_revelar_sem_ocultar_dao_erro() -> void:
	var e := _estado_vitoria_antes_de_entregar()
	var r := Comandos.aplicar(e, caso, {"tipo": "ocultar", "doc": "doc5", "nome": "Joana Alves"})
	afirmar(tem_evento(r["eventos"], "erro", "ja_oculto"))
	r = Comandos.aplicar(e, caso, {"tipo": "revelar", "doc": "doc5", "nome": "Antônio Souza"})
	afirmar(tem_evento(r["eventos"], "erro", "nao_oculto"))


func test_caso_concluido_bloqueia_novos_comandos() -> void:
	var cmds := _caminho_vitoria()
	cmds.append_array([{"tipo": "entregar"}, {"tipo": "scan"}])
	var r := rodar(cmds)
	afirmar(tem_evento(r["eventos"], "erro", "caso_ja_concluido"))


func test_download_repetido_e_read_do_pendrive_desconectado() -> void:
	var cmds := ATE_GABINETE.duplicate()
	cmds.append_array([{"tipo": "download", "doc": "doc4"}, {"tipo": "download", "doc": "doc4"}])
	var r := rodar(cmds)
	afirmar(tem_evento(r["eventos"], "erro", "ja_baixado"))
	cmds.append_array([{"tipo": "disconnect"}, {"tipo": "disconnect"}, {"tipo": "read", "doc": "doc4"}])
	r = rodar(cmds)
	afirmar(tem_evento(r["eventos"], "documento"), "documento do pendrive pode ser lido offline")


func test_host_sem_diferenciar_maiusculas() -> void:
	var r := rodar([{"tipo": "scan"}, {"tipo": "probe", "no": "GAB-EDUCACAO-03"}])
	afirmar(tem_evento(r["eventos"], "sondagem"))


func test_r_do_cifrao_so_vale_para_valores() -> void:
	igual(Util.achar_termo(caso, ["rogerio"], "ogério"), "")
	igual(Util.achar_termo(caso, ["rogerio"], "Rogério"), "rogerio")
