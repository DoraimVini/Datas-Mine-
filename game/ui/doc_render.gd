# Transforma o texto de um documento em BBCode: termos [entre colchetes] viram links clicáveis
# (meta = id do termo), nomes ocultos viram ████. Apresentação pura.
extends RefCounted

const Tema := preload("res://ui/tema/tema.gd")


static func _escapar(s: String) -> String:
	return s.replace("[", "[lb]")


static func bbcode(doc_id: String, caso: Dictionary, coletados: Array, ocultos: Array = [], tarja := "████████") -> String:
	var doc: Dictionary = caso["documentos"][doc_id]
	var por_rotulo := {}
	for id in doc["termos"]:
		por_rotulo[caso["termos"][id]["rotulo"]] = id
	var re := RegEx.create_from_string("\\[([^\\]]+)\\]")
	var saida := []
	for linha in doc["texto"]:
		var out := ""
		var ultimo := 0
		for m in re.search_all(linha):
			out += _escapar(linha.substr(ultimo, m.get_start() - ultimo))
			var texto := m.get_string(1)
			var id: String = por_rotulo.get(texto, "")
			if id == "":
				out += _escapar(m.get_string())
			elif id in ocultos:
				out += "[bgcolor=#%s][color=#%s]%s[/color][/bgcolor]" % [Tema.TEXTO.to_html(false), Tema.TEXTO.to_html(false), tarja]
			else:
				var cor := Tema.OK if id in coletados else Tema.ACENTO_2
				out += "[url=%s][color=#%s]%s[/color][/url]" % [id, cor.to_html(false), _escapar(texto)]
			ultimo = m.get_end()
		out += _escapar(linha.substr(ultimo))
		saida.append(out)
	return "\n".join(saida)
