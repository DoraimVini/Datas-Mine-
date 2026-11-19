# Testes da interface: as cenas carregam, os apps só geram comandos e refletem o estado.
# Usa o autoload Jogo real. Nós são liberados com free() (imediato): com queue_free, todos os testes
# rodam no mesmo frame e apps antigos continuariam vivos reagindo aos sinais dos testes seguintes.
extends "res://testes/base_teste.gd"

const APPS := ["Rede", "Arquivos", "Caderno", "Dossie", "Pendrive", "Chat", "Ajuda"]


func _jogo() -> Node:
	return arvore.root.get_node("Jogo")


func _montar(cena: String) -> Control:
	var no: Control = load(cena).instantiate()
	arvore.root.add_child(no)
	return no


func _soltar(no: Node) -> void:
	no.get_parent().remove_child(no)
	no.free()


func _novo_jogo() -> Node:
	var j := _jogo()
	j.iniciar_caso("caso1")
	return j


func _no_gabinete(j: Node) -> void:
	for c in [{"tipo": "scan"}, {"tipo": "probe", "no": "gab-educacao-03"},
			{"tipo": "login", "no": "gab-educacao-03", "usuario": "lucia.prado", "senha": "pipoca2019"}]:
		j.executar(c)


func _botao_com_texto(raiz: Node, texto: String) -> Button:
	for b in raiz.find_children("*", "Button", true, false):
		if b.text == texto:
			return b
	return null


func test_todos_os_apps_carregam() -> void:
	_novo_jogo()
	for nome in APPS:
		var app := _montar("res://ui/apps/%s.tscn" % nome)
		afirmar(app.is_inside_tree(), "%s não entrou na árvore" % nome)
		_soltar(app)


func test_clicar_num_termo_coleta() -> void:
	var j := _novo_jogo()
	j.executar({"tipo": "read", "doc": "doc1"})
	var app := _montar("res://ui/apps/Arquivos.tscn")
	app._ao_clicar_termo("antonio_souza")
	afirmar("antonio_souza" in j.estado()["caderno"], "clique no termo deveria coletar")
	_soltar(app)


func test_caderno_lista_os_termos() -> void:
	var j := _novo_jogo()
	j.executar({"tipo": "read", "doc": "doc1"})
	j.executar({"tipo": "coletar", "termo": "Nutri Bem Ltda"})
	var app := _montar("res://ui/apps/Caderno.tscn")
	igual(app.get_node("Lista").item_count, 1)
	afirmar(not app.get_node("Vazio").visible, "aviso de vazio deveria sumir")
	_soltar(app)


func test_menu_da_lacuna_so_tem_termos_do_caderno() -> void:
	var j := _novo_jogo()
	j.executar({"tipo": "read", "doc": "doc1"})
	j.executar({"tipo": "coletar", "termo": "Antônio Souza"})
	j.executar({"tipo": "coletar", "termo": "Nutri Bem Ltda"})
	var app := _montar("res://ui/apps/Dossie.tscn")
	var menu: OptionButton = app._menu_lacuna("fato1", "quem", j.estado())
	igual(menu.item_count, 3, "opção vazia + 2 termos:")
	menu.item_selected.emit(1)
	igual(j.estado()["fatos"]["fato1"]["quem"], "antonio_souza")
	menu.free()
	_soltar(app)


func test_janela_fica_dentro_da_area() -> void:
	var area := Control.new()
	area.size = Vector2(800, 600)
	arvore.root.add_child(area)
	var jan: Control = load("res://ui/janela/Janela.tscn").instantiate()
	area.add_child(jan)
	jan.configurar("teste", "Teste", Control.new(), "_", "x", Vector2(300, 200))
	jan.mover_para(Vector2(5000, -50))
	igual(jan.position, Vector2(500, 0))
	_soltar(area)


func test_alterar_a_copia_do_estado_nao_muda_o_jogo() -> void:
	var j := _novo_jogo()
	j.estado()["ruido"] = 99
	igual(j.sessao.estado["ruido"], 0, "a UI recebe uma cópia:")


func test_login_e_pin_pela_interface() -> void:
	var j := _novo_jogo()
	var app := _montar("res://ui/apps/Rede.tscn")
	j.executar({"tipo": "scan"})
	j.executar({"tipo": "probe", "no": "gab-educacao-03"})
	app._abrir_login("n2")
	afirmar(app._login.visible, "formulário de login deveria abrir")
	app._usuario.text = "lucia.prado"
	app._senha.text = "pipoca2019"
	app._enviar_login()
	igual(j.estado()["no_atual"], "n2")
	afirmar(not app._login.visible, "formulário deveria fechar após o login")
	j.executar({"tipo": "scan"})
	j.executar({"tipo": "probe", "no": "srv-contratos"})
	var crack := _botao_com_texto(app, str(j.textos_interface["rede"]["crack"]).format({"porta": 445}))
	afirmar(crack != null, "botão de crack da porta 445 deveria aparecer após sondar")
	crack.pressed.emit()
	afirmar(app._pin.visible, "painel do PIN deveria aparecer")
	app._pin_codigo.text = "291"
	app._enviar_pin()
	igual(j.estado()["no_atual"], "n3")
	afirmar(not app._pin.visible, "painel do PIN deveria sumir")
	_soltar(app)


func test_pendrive_oculta_e_revela() -> void:
	var j := _novo_jogo()
	_no_gabinete(j)
	j.executar({"tipo": "download", "doc": "doc4"})
	var app := _montar("res://ui/apps/Pendrive.tscn")
	app._lista.item_selected.emit(0)
	var p: Dictionary = j.textos_interface["pendrive"]
	var ocultar := _botao_com_texto(app, p["ocultar"])
	afirmar(ocultar != null, "deveria haver botão Ocultar para as pessoas do doc4")
	ocultar.pressed.emit()
	igual(j.estado()["ocultos"].get("doc4", []).size(), 1)
	_botao_com_texto(app, p["revelar"]).pressed.emit()
	igual(j.estado()["ocultos"].get("doc4", []).size(), 0)
	_soltar(app)


func test_chat_mostra_parecer_e_sobrevive_sem_caso() -> void:
	var j := _novo_jogo()
	var app := _montar("res://ui/apps/Chat.tscn")
	j.executar({"tipo": "disconnect"})
	j.executar({"tipo": "entregar"})  # erro (fatos incompletos): o Chat não deve quebrar
	app.ao_evento({"tipo": "parecer_recusado", "parecer": {"fatos": [{"fato": "fato1", "status": "incorreto"}], "inocentes_protegidos": 0, "inocentes_total": 0}})
	afirmar(app._log.get_parsed_text().contains("fato1"), "o parecer deveria aparecer no chat")
	_soltar(app)


func test_desktop_abre_minimiza_fecha_e_reabre() -> void:
	_novo_jogo()
	var d := _montar("res://ui/Desktop.tscn")
	afirmar(d.janela("chat") != null and d.janela("rede") != null, "Chat e Rede abrem no início")
	d.abrir_app("caderno")
	var jan: Control = d.janela("caderno")
	afirmar(jan.visible)
	d._minimizar(jan)
	afirmar(not jan.visible and d._botoes_tarefa.has("caderno"), "minimizar esconde e mantém na barra")
	d._fechar(jan)
	afirmar(not d._botoes_tarefa.has("caderno"), "fechar tira da barra")
	d.abrir_app("caderno")
	afirmar(jan.visible and d.janela("caderno") == jan, "reabrir reaproveita a mesma janela")
	_soltar(d)
