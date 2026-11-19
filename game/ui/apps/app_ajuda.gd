# App "Manual": o mesmo manual do /help do console, navegável.
extends "res://ui/apps/app_base.gd"

const Textos := preload("res://app/textos.gd")

var _lista: ItemList
var _detalhe: RichTextLabel


func montar() -> void:
	add_child(rotulo_ui(ti["ajuda"]["intro"], Tema.TEXTO_FRACO, true))
	var corpo := HSplitContainer.new()
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(corpo)
	_lista = ItemList.new()
	_lista.custom_minimum_size = Vector2(200, 0)
	corpo.add_child(_lista)
	_detalhe = RichTextLabel.new()
	_detalhe.bbcode_enabled = true
	_detalhe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corpo.add_child(_detalhe)
	var m: Dictionary = t["manual"]
	for g in m["grupos"]:
		var cab := _lista.add_item(g["titulo"])
		_lista.set_item_selectable(cab, false)
		_lista.set_item_custom_fg_color(cab, Tema.ACENTO)
		for nome in g["comandos"]:
			var i := _lista.add_item("  " + nome)
			_lista.set_item_metadata(i, nome)
	_lista.item_selected.connect(_mostrar)


func _mostrar(i: int) -> void:
	var m: Dictionary = t["manual"]
	var c: Dictionary = m["comandos"][_lista.get_item_metadata(i)]
	var txt := "[b]%s[/b]\n%s\n\n%s\n" % [c["uso"].replace("[", "[lb]"), c["resumo"], str(m["detalhe_uso"]).format({"uso": c["uso"]}).replace("[", "[lb]")]
	if c.has("custo"):
		txt += str(m["detalhe_custo"]).format({"valor": Textos.custo_do_comando(c, caso()["custos"])}) + "\n"
	for l in c["explicacao"]:
		txt += "• %s\n" % l.replace("[", "[lb]")
	txt += "\n" + str(m["detalhe_exemplo"]).format({"exemplo": c["exemplo"]}).replace("[", "[lb]")
	_detalhe.text = txt
