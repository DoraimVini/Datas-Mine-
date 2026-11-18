# Fase "Invadir": rede, acesso, arquivos e rastros.
# Cada função recebe uma CÓPIA do estado (feita em comandos.gd), altera essa cópia e acrescenta eventos.
extends RefCounted

const Util := preload("res://nucleo/util.gd")
const Ruido := preload("res://nucleo/ruido.gd")
const Estado := preload("res://nucleo/estado.gd")


static func _conhecido(estado: Dictionary, id: String) -> bool:
	return id != "" and (estado["nos"][id]["revelado"] or id in estado["nomes_conhecidos"])


static func _exige_conexao(estado: Dictionary, eventos: Array) -> bool:
	if not estado["conectado"]:
		eventos.append(Util.erro("desconectado"))
		return false
	return true


static func _entrar(estado: Dictionary, caso: Dictionary, id: String) -> void:
	var no: Dictionary = estado["nos"][id]
	no["revelado"] = true
	no["desbloqueado"] = true
	if not caso["nos"][id]["publico"]:
		no["rastro"] = true
	estado["conectado"] = true
	estado["no_atual"] = id


static func scan(estado: Dictionary, caso: Dictionary, _cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	if not Ruido.gastar(estado, caso, "scan", eventos):
		return
	var novos := []
	for viz in caso["nos"][estado["no_atual"]]["vizinhos"]:
		if not estado["nos"][viz]["revelado"]:
			estado["nos"][viz]["revelado"] = true
			novos.append(viz)
	eventos.append({"tipo": "varredura", "origem": estado["no_atual"], "novos": novos})


static func probe(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	var id := Util.id_do_no(caso, cmd.get("no", ""))
	if not _conhecido(estado, id):
		eventos.append(Util.erro("no_desconhecido", {"no": cmd.get("no", "")}))
		return
	if not Ruido.gastar(estado, caso, "probe", eventos):
		return
	var por_nome: bool = not estado["nos"][id]["revelado"]
	estado["nos"][id]["revelado"] = true
	estado["nos"][id]["sondado"] = true
	eventos.append({"tipo": "sondagem", "no": id, "por_nome": por_nome})


static func connect_no(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	var id := Util.id_do_no(caso, cmd.get("no", ""))
	if not _conhecido(estado, id):
		eventos.append(Util.erro("no_desconhecido", {"no": cmd.get("no", "")}))
		return
	if not estado["nos"][id]["desbloqueado"]:
		eventos.append(Util.erro("no_bloqueado", {"no": id}))
		return
	_entrar(estado, caso, id)
	eventos.append({"tipo": "conectado", "no": id})


static func login(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	var id := Util.id_do_no(caso, cmd.get("no", ""))
	if not _conhecido(estado, id):
		eventos.append(Util.erro("no_desconhecido", {"no": cmd.get("no", "")}))
		return
	var acesso: Dictionary = caso["nos"][id]["acesso"]
	if acesso["tipo"] != "login":
		eventos.append(Util.erro("sem_login", {"no": id}))
		return
	if estado["nos"][id]["desbloqueado"]:
		_entrar(estado, caso, id)
		eventos.append({"tipo": "conectado", "no": id})
		return
	var certo: bool = cmd.get("usuario", "").strip_edges().to_lower() == acesso["usuario"] \
		and cmd.get("senha", "").strip_edges() == acesso["senha"]
	if certo:
		if not Ruido.gastar(estado, caso, "login", eventos):
			return
		_entrar(estado, caso, id)
		eventos.append({"tipo": "login_ok", "no": id, "usuario": acesso["usuario"]})
	else:
		if not Ruido.gastar(estado, caso, "senha_errada", eventos):
			return
		eventos.append({"tipo": "senha_errada", "no": id})


static func crack(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	var id := Util.id_do_no(caso, cmd.get("no", ""))
	if not _conhecido(estado, id):
		eventos.append(Util.erro("no_desconhecido", {"no": cmd.get("no", "")}))
		return
	var acesso: Dictionary = caso["nos"][id]["acesso"]
	if acesso["tipo"] != "pin" or int(cmd.get("porta", -1)) != int(acesso["porta"]):
		eventos.append(Util.erro("crack_indisponivel", {"no": id, "porta": cmd.get("porta", -1)}))
		return
	if estado["nos"][id]["desbloqueado"]:
		eventos.append(Util.erro("ja_desbloqueado", {"no": id}))
		return
	if not Ruido.gastar(estado, caso, "crack", eventos):
		return
	estado["nos"][id]["revelado"] = true
	estado["minigame"] = {"no": id, "porta": int(acesso["porta"])}
	eventos.append({"tipo": "minigame", "no": id})


static func pin(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if estado["minigame"].is_empty():
		eventos.append(Util.erro("sem_minigame"))
		return
	var id: String = estado["minigame"]["no"]
	var tentativa := Util.normalizar(str(cmd.get("codigo", "")))
	if tentativa == str(caso["nos"][id]["acesso"]["solucao"]):
		estado["minigame"] = {}
		_entrar(estado, caso, id)
		eventos.append({"tipo": "pin_ok", "no": id})
	else:
		if not Ruido.gastar(estado, caso, "pin_errado", eventos):
			return
		eventos.append({"tipo": "pin_errado", "no": id})


static func ls(estado: Dictionary, caso: Dictionary, _cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	eventos.append({"tipo": "lista", "no": estado["no_atual"], "arquivos": caso["nos"][estado["no_atual"]]["arquivos"].duplicate()})


static func _doc_acessivel(estado: Dictionary, caso: Dictionary, doc: String) -> bool:
	if doc in estado["pendrive"]:
		return true
	return estado["conectado"] and doc in caso["nos"][estado["no_atual"]]["arquivos"]


static func read(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	var doc: String = cmd.get("doc", "")
	if not caso["documentos"].has(doc) or not _doc_acessivel(estado, caso, doc):
		eventos.append(Util.erro("doc_inacessivel", {"doc": doc}))
		return
	if not doc in estado["lidos"]:
		estado["lidos"].append(doc)
	var novos := []
	for id in caso["documentos"][doc]["revela_nos"]:
		if not id in estado["nomes_conhecidos"] and not estado["nos"][id]["revelado"]:
			estado["nomes_conhecidos"].append(id)
			novos.append(id)
	eventos.append({"tipo": "documento", "doc": doc, "nomes_novos": novos})


static func download(estado: Dictionary, caso: Dictionary, cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	var doc: String = cmd.get("doc", "")
	if not doc in caso["nos"][estado["no_atual"]]["arquivos"]:
		eventos.append(Util.erro("doc_inacessivel", {"doc": doc}))
		return
	if doc in estado["pendrive"]:
		eventos.append(Util.erro("ja_baixado", {"doc": doc}))
		return
	if not Ruido.gastar(estado, caso, "download", eventos):
		return
	estado["pendrive"].append(doc)
	eventos.append({"tipo": "baixado", "doc": doc})


static func limpar(estado: Dictionary, caso: Dictionary, _cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	var id: String = estado["no_atual"]
	if not estado["nos"][id]["rastro"]:
		eventos.append(Util.erro("sem_rastro", {"no": id}))
		return
	if not Ruido.gastar(estado, caso, "limpar", eventos):
		return
	estado["nos"][id]["rastro"] = false
	eventos.append({"tipo": "rastros_limpos", "no": id})


## Primeira chamada com rastros: só avisa (o jogador decide). Segunda chamada seguida: sai.
static func disconnect_rede(estado: Dictionary, caso: Dictionary, _cmd: Dictionary, eventos: Array) -> void:
	if not _exige_conexao(estado, eventos):
		return
	var rastros := Estado.nos_com_rastro(estado)
	var ganho: int = caso["exposicao"]["sair_com_rastros"] if not rastros.is_empty() else 0
	if not rastros.is_empty() and not estado["aviso_rastros"]:
		estado["aviso_rastros"] = true
		eventos.append({"tipo": "aviso_rastros", "nos": rastros, "exposicao_prevista": ganho})
		return
	estado["exposicao"] += ganho
	for id in rastros:
		estado["nos"][id]["rastro"] = false
	estado["conectado"] = false
	estado["no_atual"] = ""
	estado["minigame"] = {}
	estado["aviso_rastros"] = false
	eventos.append({"tipo": "desconectado", "exposicao_ganha": ganho, "exposicao": estado["exposicao"]})
