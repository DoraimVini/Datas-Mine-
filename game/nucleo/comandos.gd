# O coração do jogo: (Estado, Comando) -> (Estado', Eventos).
# Função pura: o estado recebido nunca é alterado; uma cópia profunda é modificada e devolvida.
# É a ÚNICA forma de mudar o estado (decisões 0002 e 0007).
extends RefCounted

const Util := preload("res://nucleo/util.gd")
const Invasao := preload("res://nucleo/invasao.gd")
const Dossie := preload("res://nucleo/dossie.gd")
const Editorial := preload("res://nucleo/editorial.gd")

static func aplicar(estado: Dictionary, caso: Dictionary, cmd: Dictionary) -> Dictionary:
	var novo: Dictionary = estado.duplicate(true)
	var eventos := []
	var tipo: String = cmd.get("tipo", "")

	if novo["concluido"] and tipo != "read":
		eventos.append(Util.erro("caso_ja_concluido"))
		return {"estado": novo, "eventos": eventos}

	# O aviso de rastros só vale para um "disconnect" logo em seguida.
	if tipo != "disconnect":
		novo["aviso_rastros"] = false

	match tipo:
		"scan": Invasao.scan(novo, caso, cmd, eventos)
		"probe": Invasao.probe(novo, caso, cmd, eventos)
		"connect": Invasao.connect_no(novo, caso, cmd, eventos)
		"login": Invasao.login(novo, caso, cmd, eventos)
		"crack": Invasao.crack(novo, caso, cmd, eventos)
		"pin": Invasao.pin(novo, caso, cmd, eventos)
		"ls": Invasao.ls(novo, caso, cmd, eventos)
		"read": Invasao.read(novo, caso, cmd, eventos)
		"download": Invasao.download(novo, caso, cmd, eventos)
		"limpar": Invasao.limpar(novo, caso, cmd, eventos)
		"disconnect": Invasao.disconnect_rede(novo, caso, cmd, eventos)
		"coletar": Dossie.coletar(novo, caso, cmd, eventos)
		"preencher": Dossie.preencher(novo, caso, cmd, eventos)
		"limpar_lacuna": Dossie.limpar_lacuna(novo, caso, cmd, eventos)
		"ocultar": Dossie.ocultar(novo, caso, cmd, eventos)
		"revelar": Dossie.revelar(novo, caso, cmd, eventos)
		"entregar": Editorial.entregar(novo, caso, cmd, eventos)
		_: eventos.append(Util.erro("comando_desconhecido", {"comando": tipo}))

	return {"estado": novo, "eventos": eventos}
