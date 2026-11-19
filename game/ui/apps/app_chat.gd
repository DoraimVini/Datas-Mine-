# App "Chat": conversa com a jornalista. Mostra a mensagem inicial, o memorando fixado e
# as respostas às entregas (pareceres) e o resultado do caso.
extends "res://ui/apps/app_base.gd"

const Mensagens := preload("res://ui/mensagens.gd")

var _memorando: Label
var _log: RichTextLabel


func montar() -> void:
	_memorando = rotulo_ui("", Tema.ALERTA, true)
	add_child(_memorando)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_log)
	jogo.caso_iniciado.connect(func(_id): _boas_vindas())
	if not caso().is_empty():
		_boas_vindas()


func _boas_vindas() -> void:
	_log.clear()
	_memorando.text = str(ti["chat"]["memorando"]).format({"regra": caso()["memorando"]})
	for l in caso()["intro"]:
		_fala(caso()["jornalista"]["nome"], l, Tema.ACENTO_2)


func _fala(quem: String, texto: String, cor: Color) -> void:
	_log.append_text("[color=#%s][b]%s:[/b][/color] %s\n" % [cor.to_html(false), quem, texto.replace("[", "[lb]")])


func ao_evento(e: Dictionary) -> void:
	if caso().is_empty():
		return
	var nome: String = caso()["jornalista"]["nome"]
	match e["tipo"]:
		"parecer_recusado":
			for l in Mensagens.linhas_parecer(e["parecer"], t):
				_fala(nome, l, Tema.PERIGO)
			_fala(nome, t["eventos"]["parecer_recusado"], Tema.PERIGO)
		"caso_concluido":
			for l in Mensagens.linhas_parecer(e["parecer"], t):
				_fala(nome, l, Tema.OK)
			var r: Dictionary = e["resultado"]
			_log.append_text("\n[color=#%s][b]%s[/b][/color]\n" % [Tema.ACENTO.to_html(false), str(ti["chat"]["resultado"]).format({"manchete": caso()["resultado"]["manchete"]})])
			for linha in ti["chat"]["resultado_linhas"]:
				_log.append_text("  " + str(linha).format(r).replace("[", "[lb]") + "\n")
