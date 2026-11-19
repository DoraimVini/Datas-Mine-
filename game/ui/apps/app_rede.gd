# App "Mapa da Rede": nós conhecidos e ações de invasão (scan, sondar, conectar, login, crack, PIN,
# limpar, desconectar). Só monta comandos e mostra o estado; as regras ficam no núcleo.
extends "res://ui/apps/app_base.gd"

var _local: Label
var _lista: VBoxContainer
var _login: PanelContainer
var _login_titulo: Label
var _usuario: LineEdit
var _senha: LineEdit
var _pin: PanelContainer
var _pin_titulo: Label
var _pin_enunciado: Label
var _pin_codigo: LineEdit
var _no_login := ""


func montar() -> void:
	var r: Dictionary = ti["rede"]
	var barra := HBoxContainer.new()
	barra.add_child(botao(r["scan"], func(): executar({"tipo": "scan"})))
	barra.add_child(botao(r["limpar"], func(): executar({"tipo": "limpar"})))
	barra.add_child(botao(r["disconnect"], func(): executar({"tipo": "disconnect"})))
	add_child(barra)

	_local = rotulo_ui("", Tema.ACENTO)
	add_child(_local)

	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 8)
	rolagem.add_child(_lista)
	add_child(rolagem)

	# Formulário de login (aparece ao clicar em "Login…").
	_login = PanelContainer.new()
	_login.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, Tema.ACENTO_2, 1, 4, 8))
	var vl := VBoxContainer.new()
	_login_titulo = rotulo_ui("", Tema.ACENTO_2)
	_usuario = LineEdit.new()
	_usuario.placeholder_text = r["usuario"]
	_senha = LineEdit.new()
	_senha.placeholder_text = r["senha"]
	_senha.secret = true
	_senha.text_submitted.connect(func(_t): _enviar_login())
	var bl := HBoxContainer.new()
	bl.add_child(botao(r["entrar"], _enviar_login))
	bl.add_child(botao(r["cancelar"], func(): _login.visible = false))
	for n in [_login_titulo, _usuario, _senha, bl]:
		vl.add_child(n)
	_login.add_child(vl)
	_login.visible = false
	add_child(_login)

	# Quebra-cabeça do PIN (aparece quando há um crack em andamento).
	_pin = PanelContainer.new()
	_pin.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, Tema.ALERTA, 1, 4, 8))
	var vp := VBoxContainer.new()
	_pin_titulo = rotulo_ui("", Tema.ALERTA)
	_pin_enunciado = rotulo_ui("", Tema.TEXTO, true)
	_pin_codigo = LineEdit.new()
	_pin_codigo.placeholder_text = r["pin_codigo"]
	_pin_codigo.text_submitted.connect(func(_t): _enviar_pin())
	for n in [_pin_titulo, _pin_enunciado, _pin_codigo, botao(r["pin_enviar"], _enviar_pin)]:
		vp.add_child(n)
	_pin.add_child(vp)
	add_child(_pin)


func _enviar_login() -> void:
	executar({"tipo": "login", "no": _no_login, "usuario": _usuario.text, "senha": _senha.text})


func _enviar_pin() -> void:
	executar({"tipo": "pin", "codigo": _pin_codigo.text})
	_pin_codigo.text = ""


func ao_evento(e: Dictionary) -> void:
	if e["tipo"] in ["login_ok", "conectado"] or (e["tipo"] == "erro" and e["codigo"] == "ja_desbloqueado"):
		_login.visible = false
		_senha.text = ""


func _abrir_login(id: String) -> void:
	_no_login = id
	_login_titulo.text = str(ti["rede"]["login_titulo"]).format({"host": host(id)})
	_login.visible = true
	_usuario.grab_focus()


func atualizar() -> void:
	var e := estado()
	if e.is_empty():
		return
	var r: Dictionary = ti["rede"]
	_local.text = (str(ti["hud"]["conectado"]).format({"host": host(e["no_atual"])})) if e["conectado"] else ti["hud"]["desconectado"]

	limpar_filhos(_lista)
	var algum := false
	for id in caso()["nos"]:
		var n: Dictionary = e["nos"][id]
		var por_nome: bool = not n["revelado"] and id in e["nomes_conhecidos"]
		if not n["revelado"] and not por_nome:
			continue
		algum = true
		_lista.add_child(_linha_no(id, n, por_nome, e))
	if not algum:
		_lista.add_child(rotulo_ui(r["nenhum_no"], Tema.TEXTO_FRACO))

	var mg: Dictionary = e["minigame"]
	_pin.visible = not mg.is_empty()
	if _pin.visible:
		var acesso: Dictionary = caso()["nos"][mg["no"]]["acesso"]
		_pin_titulo.text = str(r["pin_titulo"]).format({"titulo": acesso["titulo"]})
		_pin_enunciado.text = "\n".join(acesso["enunciado"])


func _linha_no(id: String, n: Dictionary, por_nome: bool, e: Dictionary) -> Control:
	var r: Dictionary = ti["rede"]
	var dados: Dictionary = caso()["nos"][id]
	var cx := PanelContainer.new()
	var aqui: bool = e["conectado"] and e["no_atual"] == id
	cx.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, Tema.ACENTO if aqui else Tema.BORDA, 1, 4, 8))
	var v := VBoxContainer.new()
	cx.add_child(v)

	var situacao: String = r["estado"]["por_nome"] if por_nome else (
		r["estado"]["publico"] if dados["publico"] else (r["estado"]["aberto"] if n["desbloqueado"] else r["estado"]["fechado"]))
	var cabecalho := "%s %s   (%s)" % ["●" if aqui else "○", dados["host"], situacao]
	if aqui:
		cabecalho += "   ← " + r["voce_esta_aqui"]
	if n["rastro"]:
		cabecalho += "   ⚠ " + r["rastro"]
	v.add_child(rotulo_ui(cabecalho, Tema.ACENTO if aqui else Tema.TEXTO))
	v.add_child(rotulo_ui(dados["descricao"], Tema.TEXTO_FRACO))

	if n["sondado"]:
		for p in dados["portas"]:
			v.add_child(rotulo_ui("  " + str(r["porta"]).format({"numero": int(p["numero"]), "servico": p["servico"], "estado": p["estado"]}), Tema.TEXTO_FRACO))
		var acesso: Dictionary = dados["acesso"]
		var chave: String = "acesso_" + str(acesso["tipo"])
		v.add_child(rotulo_ui("  " + str(r[chave]).format({"porta": int(acesso.get("porta", 0))}), Tema.ACENTO_2))
	else:
		v.add_child(rotulo_ui("  " + r["nao_sondado"], Tema.TEXTO_FRACO))

	var acoes := HBoxContainer.new()
	acoes.add_child(botao(r["sondar"], func(): executar({"tipo": "probe", "no": dados["host"]})))
	acoes.add_child(botao(r["conectar"], func(): executar({"tipo": "connect", "no": dados["host"]})))
	acoes.add_child(botao(r["login"], _abrir_login.bind(id)))
	# Crack: o JOGADOR escolhe a porta, entre as que conhece (sondou). O núcleo decide se há trava ali.
	if n["sondado"]:
		for p in dados["portas"]:
			var numero := int(p["numero"])
			acoes.add_child(botao(str(r["crack"]).format({"porta": numero}), func(): executar({"tipo": "crack", "no": dados["host"], "porta": numero})))
	v.add_child(acoes)
	if not n["sondado"]:
		v.add_child(rotulo_ui(r["crack_dica"], Tema.TEXTO_FRACO))
	return cx
