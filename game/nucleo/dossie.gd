# Fase "Montar o dossiê": caderno de termos, fatos com lacunas e ocultação de nomes.
extends RefCounted

const Util := preload("res://nucleo/util.gd")


## Termos que o jogador pode coletar: os de todos os documentos já lidos.
static func termos_disponiveis(estado: Dictionary, caso: Dictionary) -> Array:
	var ids := []
	for doc in estado["lidos"]:
		for t in caso["documentos"][doc]["termos"]:
			if not t in ids:
				ids.append(t)
	return ids


static func coletar(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	var id := Util.achar_termo(caso, termos_disponiveis(estado, caso), cmd.get("termo", ""))
	if id == "":
		eventos.append(Util.erro("termo_nao_encontrado", {"termo": cmd.get("termo", "")}))
		return
	if id in estado["caderno"]:
		eventos.append(Util.erro("ja_coletado", {"termo": id}))
		return
	estado["caderno"].append(id)
	var origem := ""
	for doc in estado["lidos"]:
		if id in caso["documentos"][doc]["termos"]:
			origem = doc
			break
	eventos.append({"tipo": "coletado", "termo": id, "origem": origem})


static func _validar_lacuna(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> bool:
	var fato: String = cmd.get("fato", "")
	if not caso["fatos"].has(fato):
		eventos.append(Util.erro("fato_inexistente", {"fato": fato}))
		return false
	var lacuna := Util.normalizar(cmd.get("lacuna", ""))
	if not estado["fatos"][fato].has(lacuna):
		eventos.append(Util.erro("lacuna_inexistente", {"fato": fato, "lacuna": cmd.get("lacuna", "")}))
		return false
	return true


static func fato_completo(estado: Dictionary, fato: String) -> bool:
	for l in estado["fatos"][fato]:
		if estado["fatos"][fato][l] == "":
			return false
	return true


static func preencher(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if not _validar_lacuna(estado, caso, cmd, eventos):
		return
	var id := Util.achar_termo(caso, estado["caderno"], cmd.get("termo", ""))
	if id == "":
		eventos.append(Util.erro("termo_fora_do_caderno", {"termo": cmd.get("termo", "")}))
		return
	var fato: String = cmd["fato"]
	var lacuna := Util.normalizar(cmd["lacuna"])
	estado["fatos"][fato][lacuna] = id
	eventos.append({"tipo": "lacuna_preenchida", "fato": fato, "lacuna": lacuna, "termo": id, "completo": fato_completo(estado, fato)})


static func limpar_lacuna(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if not _validar_lacuna(estado, caso, cmd, eventos):
		return
	var lacuna := Util.normalizar(cmd["lacuna"])
	estado["fatos"][cmd["fato"]][lacuna] = ""
	eventos.append({"tipo": "lacuna_limpa", "fato": cmd["fato"], "lacuna": lacuna})


static func ocultar(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	var doc: String = cmd.get("doc", "")
	if not doc in estado["pendrive"]:
		eventos.append(Util.erro("doc_fora_do_pendrive", {"doc": doc}))
		return
	var pessoas := []
	for t in caso["documentos"][doc]["termos"]:
		if caso["termos"][t]["tipo"] == "pessoa":
			pessoas.append(t)
	var id := Util.achar_termo(caso, pessoas, cmd.get("nome", ""))
	if id == "":
		eventos.append(Util.erro("nome_nao_esta_no_doc", {"doc": doc, "nome": cmd.get("nome", "")}))
		return
	var lista: Array = estado["ocultos"].get(doc, [])
	if not id in lista:
		lista.append(id)
	estado["ocultos"][doc] = lista
	eventos.append({"tipo": "nome_oculto", "doc": doc, "termo": id})
