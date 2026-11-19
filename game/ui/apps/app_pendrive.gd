# App "Pendrive": documentos baixados (as provas). Mostra o texto com os nomes ocultos tarjados
# e deixa ocultar/revelar cada pessoa citada. Dá para ler offline.
extends "res://ui/apps/app_base.gd"

const DocRender := preload("res://ui/doc_render.gd")

var _lista: ItemList
var _leitor: RichTextLabel
var _pessoas: VBoxContainer
var _vazio: Label
var _doc := ""


func montar() -> void:
	var p: Dictionary = ti["pendrive"]
	_vazio = rotulo_ui(p["vazio"], Tema.TEXTO_FRACO, true)
	add_child(_vazio)
	var corpo := HSplitContainer.new()
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(corpo)
	_lista = ItemList.new()
	_lista.custom_minimum_size = Vector2(200, 0)
	_lista.item_selected.connect(func(i: int):
		_doc = str(_lista.get_item_metadata(i))
		executar({"tipo": "read", "doc": _doc}))
	corpo.add_child(_lista)
	var dir := VBoxContainer.new()
	dir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_leitor = RichTextLabel.new()
	_leitor.bbcode_enabled = true
	_leitor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_leitor.meta_clicked.connect(func(meta): executar({"tipo": "coletar", "termo": rotulo(str(meta))}))
	dir.add_child(_leitor)
	dir.add_child(rotulo_ui(p["pessoas"], Tema.TEXTO_FRACO))
	_pessoas = VBoxContainer.new()
	dir.add_child(_pessoas)
	corpo.add_child(dir)


func atualizar() -> void:
	var e := estado()
	if e.is_empty():
		return
	var p: Dictionary = ti["pendrive"]
	_vazio.visible = e["pendrive"].is_empty()
	_lista.clear()
	for d in e["pendrive"]:
		var i := _lista.add_item("%s  %s" % [d, caso()["documentos"][d]["arquivo"]])
		_lista.set_item_metadata(i, d)
		if d == _doc:
			_lista.select(i)
	limpar_filhos(_pessoas)
	if _doc == "" or not _doc in e["pendrive"]:
		_leitor.text = ""
		return
	var ocultos: Array = e["ocultos"].get(_doc, [])
	_leitor.text = DocRender.bbcode(_doc, caso(), e["caderno"], ocultos, p["oculto"])
	for termo in caso()["documentos"][_doc]["termos"]:
		if caso()["termos"][termo]["tipo"] != "pessoa":
			continue
		var linha := HBoxContainer.new()
		var oculto: bool = termo in ocultos
		var nome := rotulo_ui(rotulo(termo), Tema.TEXTO_FRACO if oculto else Tema.TEXTO)
		nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		linha.add_child(nome)
		var acao := "revelar" if oculto else "ocultar"
		linha.add_child(botao(p[acao], func(): executar({"tipo": acao, "doc": _doc, "nome": rotulo(termo)})))
		_pessoas.add_child(linha)
