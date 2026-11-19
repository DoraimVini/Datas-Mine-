# App "Arquivos": lista os arquivos do nó atual e mostra o documento lido.
# Termos destacados são clicáveis e viram o comando "coletar".
extends "res://ui/apps/app_base.gd"

const DocRender := preload("res://ui/doc_render.gd")

var _local: Label
var _lista: ItemList
var _leitor: RichTextLabel
var _baixar: Button
var _status: Label
var _doc_aberto := ""


func montar() -> void:
	var a: Dictionary = ti["arquivos"]
	var corpo := HSplitContainer.new()
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(corpo)

	var esq := VBoxContainer.new()
	esq.custom_minimum_size = Vector2(230, 0)
	_local = rotulo_ui("", Tema.ACENTO, true)
	_lista = ItemList.new()
	_lista.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_lista.item_selected.connect(_ao_escolher)
	esq.add_child(_local)
	esq.add_child(_lista)
	corpo.add_child(esq)

	var dir := VBoxContainer.new()
	dir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_leitor = RichTextLabel.new()
	_leitor.bbcode_enabled = true
	_leitor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_leitor.meta_clicked.connect(_ao_clicar_termo)
	_leitor.meta_underlined = true
	_leitor.text = a["escolha"]
	var linha := HBoxContainer.new()
	_baixar = botao(a["baixar"], func(): executar({"tipo": "download", "doc": _doc_aberto}))
	_status = rotulo_ui("", Tema.OK)
	linha.add_child(_baixar)
	linha.add_child(_status)
	dir.add_child(_leitor)
	dir.add_child(linha)
	dir.add_child(rotulo_ui(a["dica_termos"], Tema.TEXTO_FRACO, true))
	corpo.add_child(dir)


## Clique num termo do texto: só pede ao núcleo para coletar (ele decide se pode).
func _ao_clicar_termo(meta) -> void:
	executar({"tipo": "coletar", "termo": rotulo(str(meta))})


func _ao_escolher(i: int) -> void:
	executar({"tipo": "read", "doc": str(_lista.get_item_metadata(i))})


func ao_evento(e: Dictionary) -> void:
	if e["tipo"] == "documento":
		_doc_aberto = e["doc"]
		_mostrar_doc()


func _mostrar_doc() -> void:
	if _doc_aberto == "":
		return
	_leitor.text = DocRender.bbcode(_doc_aberto, caso(), estado()["caderno"], [], ti["pendrive"]["oculto"])


func atualizar() -> void:
	var e := estado()
	if e.is_empty():
		return
	var a: Dictionary = ti["arquivos"]
	_lista.clear()
	if not e["conectado"]:
		_local.text = a["offline"]
	else:
		var no: Dictionary = caso()["nos"][e["no_atual"]]
		_local.text = "%s:%s" % [no["host"], no["pasta"]]
		if no["arquivos"].is_empty():
			_local.text += "\n" + a["vazio"]
		for d in no["arquivos"]:
			var doc: Dictionary = caso()["documentos"][d]
			var i := _lista.add_item("%s  %s" % [doc["arquivo"], doc["tamanho"]])
			_lista.set_item_metadata(i, d)
			if d == _doc_aberto:
				_lista.select(i)
	_baixar.visible = _doc_aberto != "" and not _doc_aberto in e["pendrive"]
	_status.text = a["baixado"] if _doc_aberto in e["pendrive"] else ""
	_mostrar_doc()
