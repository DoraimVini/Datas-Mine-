# App "Dossiê": fatos com lacunas. Cada lacuna é um menu com os termos do caderno.
# Escolher um termo vira "preencher"; escolher a opção vazia vira "limpar_lacuna".
extends "res://ui/apps/app_base.gd"

var _fatos: VBoxContainer
var _aviso: Label
var _reconstruir_pendente := false


func montar() -> void:
	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_fatos = VBoxContainer.new()
	_fatos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fatos.add_theme_constant_override("separation", 10)
	rolagem.add_child(_fatos)
	add_child(rolagem)
	var rodape := HBoxContainer.new()
	rodape.add_child(botao(ti["dossie"]["entregar"], func(): executar({"tipo": "entregar"})))
	_aviso = rotulo_ui("", Tema.ALERTA)
	rodape.add_child(_aviso)
	add_child(rodape)


## O menu que disparou a mudança ainda está emitindo o sinal: reconstruímos no próximo frame.
func atualizar() -> void:
	if not _reconstruir_pendente:
		_reconstruir_pendente = true
		_reconstruir.call_deferred()


func _reconstruir() -> void:
	_reconstruir_pendente = false
	var e := estado()
	if e.is_empty():
		return
	var d: Dictionary = ti["dossie"]
	_aviso.text = d["aviso_conectado"] if e["conectado"] else ""
	limpar_filhos(_fatos)
	var re := RegEx.create_from_string("\\{([a-z_]+)\\}")
	for fato in caso()["fatos"]:
		var cx := PanelContainer.new()
		cx.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, Tema.BORDA, 1, 4, 8))
		var v := VBoxContainer.new()
		cx.add_child(v)
		var fluxo := HFlowContainer.new()
		var frase: String = caso()["fatos"][fato]["frase"]
		var ultimo := 0
		for m in re.search_all(frase):
			var antes := frase.substr(ultimo, m.get_start() - ultimo).strip_edges()
			if antes != "":
				fluxo.add_child(rotulo_ui(antes))
			fluxo.add_child(_menu_lacuna(fato, m.get_string(1), e))
			ultimo = m.get_end()
		var depois := frase.substr(ultimo).strip_edges()
		if depois != "":
			fluxo.add_child(rotulo_ui(depois))
		v.add_child(rotulo_ui(fato.to_upper(), Tema.TEXTO_FRACO))
		v.add_child(fluxo)
		var completo: bool = jogo.fato_completo(fato)  # a regra mora no núcleo
		v.add_child(rotulo_ui(d["completo"] if completo else d["incompleto"], Tema.OK if completo else Tema.TEXTO_FRACO))
		_fatos.add_child(cx)


func _menu_lacuna(fato: String, lacuna: String, e: Dictionary) -> OptionButton:
	var ob := OptionButton.new()
	ob.focus_mode = Control.FOCUS_NONE
	var nome_lacuna: String = ti["dossie"]["nomes_lacunas"].get(lacuna, lacuna)
	ob.add_item(str(ti["dossie"]["lacuna_vazia"]).format({"lacuna": nome_lacuna}))
	ob.set_item_metadata(0, "")
	var atual: String = e["fatos"][fato].get(lacuna, "")
	for termo in e["caderno"]:
		ob.add_item(rotulo(termo))
		ob.set_item_metadata(ob.item_count - 1, termo)
		if termo == atual:
			ob.select(ob.item_count - 1)
	ob.item_selected.connect(func(i: int):
		var termo: String = ob.get_item_metadata(i)
		if termo == "":
			executar({"tipo": "limpar_lacuna", "fato": fato, "lacuna": lacuna})
		else:
			executar({"tipo": "preencher", "fato": fato, "lacuna": lacuna, "termo": rotulo(termo)}))
	return ob
