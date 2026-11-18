# Carrega e valida o conteúdo (JSON). Fica na camada de aplicação porque faz I/O.
extends RefCounted

const CUSTOS_OBRIGATORIOS := ["scan", "probe", "login", "senha_errada", "crack", "pin_errado", "download", "limpar"]
const REGRAS_CONHECIDAS := ["prova_documental"]


static func carregar_json(caminho: String) -> Dictionary:
	if not FileAccess.file_exists(caminho):
		push_error("Conteúdo não encontrado: %s" % caminho)
		return {}
	var dados = JSON.parse_string(FileAccess.get_file_as_string(caminho))
	if typeof(dados) != TYPE_DICTIONARY:
		push_error("JSON inválido: %s" % caminho)
		return {}
	return dados


static func carregar_caso(id: String) -> Dictionary:
	return carregar_json("res://conteudo/casos/%s.json" % id)


## Devolve a lista de problemas do caso (vazia = válido). Também checa se o caso tem solução.
static func validar_caso(caso: Dictionary) -> Array:
	var erros := []
	for chave in ["id", "orcamento_ruido", "custos", "exposicao", "feedback", "no_inicial", "nos", "termos", "documentos", "fatos"]:
		if not caso.has(chave):
			erros.append("falta a chave '%s'" % chave)
	if not erros.is_empty():
		return erros

	var termos: Dictionary = caso["termos"]
	var docs: Dictionary = caso["documentos"]
	var nos: Dictionary = caso["nos"]

	for chave in CUSTOS_OBRIGATORIOS:
		if not caso["custos"].has(chave):
			erros.append("custos: falta '%s'" % chave)
	for chave in ["sair_com_rastros", "lockdown"]:
		if not caso["exposicao"].has(chave):
			erros.append("exposicao: falta '%s'" % chave)
	if not caso["feedback"] in ["binario", "parcial"]:
		erros.append("feedback '%s' inválido (use binario ou parcial)" % caso["feedback"])
	for regra in caso.get("regras_editoriais", []):
		if not regra in REGRAS_CONHECIDAS:
			erros.append("regra editorial desconhecida '%s'" % regra)

	if not nos.has(caso["no_inicial"]):
		erros.append("no_inicial '%s' não existe" % caso["no_inicial"])

	var dono_do_doc := {}
	for id in nos:
		var no: Dictionary = nos[id]
		for v in no["vizinhos"]:
			if not nos.has(v):
				erros.append("nó %s: vizinho '%s' não existe" % [id, v])
		for d in no["arquivos"]:
			if not docs.has(d):
				erros.append("nó %s: arquivo '%s' não existe" % [id, d])
			elif dono_do_doc.has(d):
				erros.append("documento %s está em dois nós" % d)
			else:
				dono_do_doc[d] = id
		var acesso: Dictionary = no["acesso"]
		match acesso.get("tipo", ""):
			"publico": pass
			"login":
				for k in ["usuario", "senha"]:
					if not acesso.has(k):
						erros.append("nó %s: login sem '%s'" % [id, k])
			"pin":
				for k in ["porta", "solucao", "enunciado"]:
					if not acesso.has(k):
						erros.append("nó %s: pin sem '%s'" % [id, k])
			_: erros.append("nó %s: tipo de acesso inválido" % id)
		if acesso.has("porta"):
			var numeros := []
			for porta in no["portas"]:
				numeros.append(int(porta["numero"]))
			if not int(acesso["porta"]) in numeros:
				erros.append("nó %s: a porta de acesso %d não está em 'portas'" % [id, int(acesso["porta"])])

	for d in docs:
		var doc: Dictionary = docs[d]
		if not dono_do_doc.has(d):
			erros.append("documento %s não está em nenhum nó" % d)
		var texto := "\n".join(doc["texto"])
		for t in doc["termos"]:
			if not termos.has(t):
				erros.append("documento %s: termo '%s' não existe" % [d, t])
			elif texto.find("[%s]" % termos[t]["rotulo"]) == -1:
				erros.append("documento %s: o texto não marca [%s]" % [d, termos[t]["rotulo"]])
		for t in doc["inocentes"]:
			if not t in doc["termos"]:
				erros.append("documento %s: inocente '%s' não é termo do documento" % [d, t])
			elif termos.has(t) and termos[t]["tipo"] != "pessoa":
				erros.append("documento %s: inocente '%s' não é uma pessoa" % [d, t])
		for n in doc["revela_nos"]:
			if not nos.has(n):
				erros.append("documento %s: revela nó inexistente '%s'" % [d, n])

	# Todos os nós precisam ser alcançáveis a partir do nó inicial.
	var alcancados := [caso["no_inicial"]]
	var fila := [caso["no_inicial"]]
	while not fila.is_empty():
		var atual = fila.pop_front()
		for v in nos.get(atual, {}).get("vizinhos", []):
			if not v in alcancados:
				alcancados.append(v)
				fila.append(v)
	for id in nos:
		if not id in alcancados:
			erros.append("nó %s é inalcançável" % id)

	for f in caso["fatos"]:
		var fato: Dictionary = caso["fatos"][f]
		for l in fato["lacunas"]:
			if not fato["respostas"].has(l):
				erros.append("fato %s: lacuna '%s' sem resposta" % [f, l])
			if fato["frase"].find("{%s}" % l) == -1:
				erros.append("fato %s: a frase não tem {%s}" % [f, l])
		for l in fato["respostas"]:
			var t: String = fato["respostas"][l]
			if not termos.has(t):
				erros.append("fato %s: resposta '%s' não existe" % [f, t])
				continue
			var aparece := false
			for d in docs:
				if t in docs[d]["termos"]:
					aparece = true
			if not aparece:
				erros.append("fato %s: a resposta '%s' não aparece em nenhum documento (impossível)" % [f, t])
		if fato["provas"].is_empty():
			erros.append("fato %s: sem documentos de prova" % f)
		for d in fato["provas"]:
			if not docs.has(d):
				erros.append("fato %s: prova '%s' não existe" % [f, d])
	return erros
