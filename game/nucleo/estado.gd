# Criação do estado inicial de um caso. O estado é um Dictionary serializável (vira o save).
extends RefCounted

const VERSAO_ESTADO := 1


static func novo(caso: Dictionary, exposicao_inicial: int = 0) -> Dictionary:
	var nos := {}
	for id in caso["nos"]:
		var publico: bool = caso["nos"][id]["publico"]
		nos[id] = {
			"revelado": id == caso["no_inicial"],
			"sondado": false,
			"desbloqueado": publico,
			"rastro": false,
		}

	var fatos := {}
	for id in caso["fatos"]:
		var lacunas := {}
		for l in caso["fatos"][id]["lacunas"]:
			lacunas[l] = ""
		fatos[id] = lacunas

	return {
		"versao": VERSAO_ESTADO,
		"caso": caso["id"],
		"ruido": 0,
		"exposicao": exposicao_inicial,
		"conectado": true,
		"no_atual": caso["no_inicial"],
		"nos": nos,
		"nomes_conhecidos": [],  # ids de nós cujo nome foi lido em documentos
		"lidos": [],
		"caderno": [],
		"pendrive": [],
		"ocultos": {},  # doc_id -> [termo_id]
		"fatos": fatos,
		"minigame": {},  # {no, porta} quando um crack está em andamento
		"aviso_rastros": false,
		"concluido": false,
		"resultado": {},
	}


## Ids dos nós que ainda têm rastros do jogador.
static func nos_com_rastro(estado: Dictionary) -> Array:
	var lista := []
	for id in estado["nos"]:
		if estado["nos"][id]["rastro"]:
			lista.append(id)
	return lista
