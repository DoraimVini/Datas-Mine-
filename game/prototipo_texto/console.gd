# Protótipo de texto: joga o caso no terminal, sem interface gráfica.
# É só uma "casca" de apresentação sobre o núcleo: traduz texto -> comando e evento -> texto.
# Uso: godot --headless --path game -s res://prototipo_texto/console.gd [-- <caso> <jogador>]
#   ex.: ... -- caso1 P01   → grava o log do playtest como P01 (padrão: caso1, anonimo)
extends SceneTree

const Sessao := preload("res://app/sessao.gd")
const Conteudo := preload("res://app/conteudo.gd")
const Dossie := preload("res://nucleo/dossie.gd")
const Telemetria := preload("res://app/telemetria.gd")

const PASTA_LOGS := "user://playtests"

var sessao := Sessao.new()
var t: Dictionary = {}
var caso: Dictionary = {}

# Telemetria do playtest (só a casca registra; o núcleo não sabe de nada disso).
var jogador := "anonimo"
var _inicio_ms := 0
var _registros: Array = []  # {t, comando, eventos}
var _consultas := {}  # comandos locais usados (help, caderno, fatos...): quantas vezes


func _init() -> void:
	t = Conteudo.carregar_json("res://conteudo/textos/console.json")
	var args := OS.get_cmdline_user_args()
	var id_caso: String = args[0] if args.size() > 0 else "caso1"
	if args.size() > 1:
		jogador = args[1]
	var erros := sessao.iniciar(id_caso)
	if not erros.is_empty():
		for e in erros:
			print(_fmt(t["rotulos"]["conteudo_invalido"], {"erro": e}))
		quit(1)
		return
	caso = sessao.caso
	_inicio_ms = Time.get_ticks_msec()
	_intro()
	_loop()
	_gravar_log()
	quit(0)


func _segundos() -> float:
	return (Time.get_ticks_msec() - _inicio_ms) / 1000.0


## Grava em user://playtests/<data>_<jogador>_<caso>.json os comandos, os eventos e as métricas.
func _gravar_log() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA_LOGS)
	var carimbo := Time.get_datetime_string_from_system(false, true).replace(":", "-").replace(" ", "_")
	var caminho := "%s/%s_%s_%s.json" % [PASTA_LOGS, carimbo, jogador, caso["id"]]
	var dados := {
		"jogador": jogador,
		"data": Time.get_datetime_string_from_system(false, true),
		"metricas": Telemetria.metricas(caso, _registros, sessao.estado, {
			"consultas": _consultas,
			"dicas_vistas": _dicas_vistas.keys(),
			"duracao_total_s": int(_segundos()),
		}),
		"registros": _registros,
	}
	var f := FileAccess.open(caminho, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(dados, "  "))
	f.close()
	print(_fmt(t["rotulos"]["log_salvo"], {"caminho": ProjectSettings.globalize_path(caminho)}))


var _buffer := ""
var _fim_da_entrada := false


## read_string_from_stdin lê BLOCOS (até 1024 bytes), não linhas: montamos as linhas aqui.
## Devolve null quando a entrada acabou.
func _proxima_linha():
	while _buffer.find("\n") == -1 and not _fim_da_entrada:
		var bloco := OS.read_string_from_stdin()
		if bloco == "":
			_fim_da_entrada = true
		else:
			_buffer += bloco
	if _buffer == "":
		return null
	var i := _buffer.find("\n")
	var linha: String
	if i == -1:
		linha = _buffer
		_buffer = ""
	else:
		linha = _buffer.substr(0, i)
		_buffer = _buffer.substr(i + 1)
	return linha


func _loop() -> void:
	while true:
		printraw("\n> ")
		var bruto = _proxima_linha()
		if bruto == null:
			print("")
			return
		var linha: String = bruto.strip_edges().replace("<", "").replace(">", "")
		if linha == "":
			continue
		print(linha)  # eco do comando (útil quando a entrada vem de um arquivo)
		if linha.to_lower().trim_prefix("/") in ["sair", "exit", "quit"]:
			return
		_processar(linha)
		if sessao.estado["concluido"] and linha.to_lower().begins_with("entregar"):
			return


# ---------------- entrada ----------------

func _processar(linha: String) -> void:
	var p := linha.split(" ", false)
	var verbo := p[0].to_lower().trim_prefix("/")  # aceita "/help", "/scan"...
	var resto := linha.substr(linha.find(" ") + 1).strip_edges() if p.size() > 1 else ""
	if verbo in ["ajuda", "help", "?", "caderno", "fatos", "pendrive", "rede", "memorando"]:
		var chave := "help" if verbo in ["ajuda", "?"] else verbo
		if chave == "help" and resto != "":
			chave = "help " + resto.to_lower()
		_consultas[chave] = _consultas.get(chave, 0) + 1
	match verbo:
		"ajuda", "help", "?": _ajuda(resto.to_lower().trim_prefix("/"))
		"caderno": _caderno()
		"fatos": _fatos()
		"pendrive": _pendrive()
		"rede": _rede()
		"scan", "ls", "limpar", "disconnect", "entregar":
			_exec({"tipo": verbo})
		"memorando": print(_fmt(t["rotulos"]["memorando"], {"regra": caso["memorando"]}))
		"probe", "connect":
			if _faltam(p, 2, verbo):
				return
			_exec({"tipo": verbo, "no": p[1]})
		"login":
			if _faltam(p, 4, verbo):
				return
			_exec({"tipo": "login", "no": p[1], "usuario": p[2], "senha": p[3]})
		"crack":
			if _faltam(p, 3, verbo):
				return
			_exec({"tipo": "crack", "no": p[1], "porta": int(p[2])})
		"pin":
			if _faltam(p, 2, verbo):
				return
			_exec({"tipo": "pin", "codigo": resto})
		"read", "download":
			if _faltam(p, 2, verbo):
				return
			_exec({"tipo": verbo, "doc": p[1].to_lower()})
		"coletar":
			if _faltam(p, 2, verbo):
				return
			_exec({"tipo": "coletar", "termo": resto})
		"preencher":
			if _faltam(p, 4, verbo):
				return
			_exec({"tipo": "preencher", "fato": p[1].to_lower(), "lacuna": p[2], "termo": " ".join(p.slice(3))})
		"limpar-lacuna":
			if _faltam(p, 3, verbo):
				return
			_exec({"tipo": "limpar_lacuna", "fato": p[1].to_lower(), "lacuna": p[2]})
		"ocultar", "revelar":
			if _faltam(p, 3, verbo):
				return
			_exec({"tipo": verbo, "doc": p[1].to_lower(), "nome": " ".join(p.slice(2))})
		_:
			print(_fmt(t["erros"]["comando_desconhecido"], {}))


## Mostra o uso correto (texto em console.json → usos) e devolve true se faltarem partes.
func _faltam(partes: PackedStringArray, minimo: int, verbo: String) -> bool:
	if partes.size() < minimo:
		_uso(t["manual"]["comandos"].get(verbo, {}).get("uso", verbo))
		return true
	return false


var _dicas_vistas := {}  # tutorial contextual: cada dica aparece só na primeira vez


func _exec(cmd: Dictionary) -> void:
	var eventos := sessao.executar(cmd)
	_registros.append({"t": snappedf(_segundos(), 0.1), "comando": cmd, "eventos": eventos})
	for e in eventos:
		_mostrar(e)
		_dica(e["tipo"])
	_status()


func _dica(tipo_evento: String) -> void:
	if t["dicas"].has(tipo_evento) and not _dicas_vistas.has(tipo_evento):
		_dicas_vistas[tipo_evento] = true
		print(t["rotulos"]["prefixo_dica"] + t["dicas"][tipo_evento])


func _uso(uso: String) -> void:
	print(_fmt(t["erros"]["uso"], {"uso": uso}))


# ---------------- saída ----------------

func _fmt(modelo: String, dados: Dictionary) -> String:
	return modelo.format(dados)


func _host(id: String) -> String:
	return caso["nos"][id]["host"] if caso["nos"].has(id) else id


func _rotulo(termo: String) -> String:
	return caso["termos"][termo]["rotulo"] if caso["termos"].has(termo) else termo


func _mostrar(e: Dictionary) -> void:
	var ev: Dictionary = t["eventos"]
	match e["tipo"]:
		"erro":
			var dados := e.duplicate()
			if e.has("no"): dados["host"] = _host(e["no"])
			if e.has("fatos"): dados["lista"] = ", ".join(e["fatos"])
			print(_fmt(t["erros"].get(e["codigo"], e["codigo"]), dados))
		"ruido":
			print(_fmt(ev["ruido"], {"custo": int(e["custo"]), "total": int(e["total"]), "orcamento": int(e["orcamento"])}))
		"varredura":
			if e["novos"].is_empty():
				print(ev["varredura_nada"])
			else:
				print(_fmt(ev["varredura_novos"], {"lista": ", ".join(e["novos"].map(_host))}))
			_rede()
		"sondagem":
			var no: Dictionary = caso["nos"][e["no"]]
			if e["por_nome"]:
				print(_fmt(ev["sondagem_por_nome"], {"host": no["host"]}))
			print(_fmt(ev["sondagem"], {"host": no["host"], "descricao": no["descricao"]}))
			for porta in no["portas"]:
				print(_fmt(ev["porta"], {"numero": int(porta["numero"]), "servico": porta["servico"], "estado": porta["estado"].to_upper()}))
			match no["acesso"]["tipo"]:
				"publico": print(ev["acesso_publico"])
				"login": print(_fmt(ev["acesso_login"], {"porta": int(no["acesso"]["porta"])}))
				"pin": print(_fmt(ev["acesso_pin"], {"porta": int(no["acesso"]["porta"])}))
		"conectado":
			print(_fmt(ev["conectado"], {"host": _host(e["no"])}))
		"login_ok":
			print(_fmt(ev["login_ok"], {"usuario": e["usuario"]}))
		"senha_errada":
			print(ev["senha_errada"])
		"minigame":
			var acesso: Dictionary = caso["nos"][e["no"]]["acesso"]
			print(ev["minigame_inicio"])
			print("┌─ " + acesso["titulo"])
			for l in acesso["enunciado"]:
				print("│  " + l)
			print("└─")
		"pin_ok":
			print(_fmt(ev["pin_ok"], {"host": _host(e["no"])}))
		"pin_errado":
			print(ev["pin_errado"])
		"lista":
			var no: Dictionary = caso["nos"][e["no"]]
			print(_fmt(ev["lista"], {"host": no["host"], "pasta": no["pasta"]}))
			for d in e["arquivos"]:
				var doc: Dictionary = caso["documentos"][d]
				print(_fmt(ev["arquivo"], {"id": d, "arquivo": doc["arquivo"], "tamanho": doc["tamanho"]}))
		"documento":
			var doc: Dictionary = caso["documentos"][e["doc"]]
			print("┌" + "─".repeat(70))
			for l in doc["texto"]:
				print("│ " + l)
			print("└" + "─".repeat(70))
			if not e["nomes_novos"].is_empty():
				print(_fmt(ev["nomes_novos"], {"lista": ", ".join(e["nomes_novos"].map(_host))}))
		"coletado":
			print(_fmt(ev["coletado"], {"rotulo": _rotulo(e["termo"])}))
		"baixado":
			print(_fmt(ev["baixado"], e))
		"rastros_limpos":
			print(_fmt(ev["rastros_limpos"], {"host": _host(e["no"])}))
		"aviso_rastros":
			print(_fmt(ev["aviso_rastros"], {"qtd": e["nos"].size(), "lista": ", ".join(e["nos"].map(_host)), "exposicao": e["exposicao_prevista"]}))
		"desconectado":
			print(_fmt(ev["desconectado"], {"ganho": e["exposicao_ganha"], "exposicao": e["exposicao"]}))
		"lockdown":
			print(_fmt(ev["lockdown"], {"ganho": e["exposicao_ganha"], "exposicao": e["exposicao"]}))
		"lacuna_preenchida", "lacuna_limpa":
			print(ev[e["tipo"]])
			_fato(e["fato"])
		"nome_oculto":
			print(_fmt(ev["nome_oculto"], e))
		"nome_revelado":
			print(_fmt(ev["nome_revelado"], {"doc": e["doc"], "rotulo": _rotulo(e["termo"])}))
		"parecer_recusado":
			_parecer(e["parecer"])
			print(ev["parecer_recusado"])
		"caso_concluido":
			_parecer(e["parecer"])
			var dados: Dictionary = e["resultado"].duplicate()
			dados["manchete"] = caso["resultado"]["manchete"]
			dados["proximo"] = caso["resultado"]["proximo_caso"]
			for l in ev["concluido"]:
				print(_fmt(l, dados))


func _parecer(parecer: Dictionary) -> void:
	var ev: Dictionary = t["eventos"]
	print(_fmt(ev["parecer_titulo"], {"nome": caso["jornalista"]["nome"]}))
	for f in parecer["fatos"]:
		var chave: String = "parecer_" + str(f["status"])
		if f.has("campos_errados"):
			chave = "parecer_incorreto_parcial"
		print(_fmt(ev[chave], {"fato": f["fato"], "n": f.get("campos_errados", 0)}))
	print(_fmt(ev["inocentes"], {"protegidos": parecer["inocentes_protegidos"], "total": parecer["inocentes_total"]}))


func _status() -> void:
	var r: Dictionary = t["rotulos"]
	print("[%s: %d / %d · %s: %d]" % [r["ruido"], sessao.estado["ruido"], caso["orcamento_ruido"], r["exposicao"], sessao.estado["exposicao"]])


func _intro() -> void:
	var r: Dictionary = t["rotulos"]
	print("═".repeat(60))
	print("  " + _fmt(t["titulo"], {"n": caso["id"].trim_prefix("caso"), "titulo": caso["titulo"].to_upper()}))
	print("═".repeat(60))
	print(_fmt(r["mensagem_de"], caso["jornalista"]))
	for l in caso["intro"]:
		print("  " + l)
	print("")
	print(_fmt(r["memorando"], {"regra": caso["memorando"]}))
	print("")
	_fatos()
	_rede()
	_status()
	print(r["dica_ajuda"])


## "help" lista os comandos por fase; "help <comando>" mostra o manual do comando.
## Custos vêm do caso (dados), nunca fixos no texto.
func _ajuda(comando: String) -> void:
	var m: Dictionary = t["manual"]
	if comando != "":
		if not m["comandos"].has(comando):
			print(_fmt(t["erros"]["help_desconhecido"], {"comando": comando}))
			return
		var c: Dictionary = m["comandos"][comando]
		print("── %s ──" % comando.to_upper())
		print(c["resumo"])
		print(_fmt(m["detalhe_uso"], {"uso": c["uso"]}))
		if c.has("custo"):
			print(_fmt(m["detalhe_custo"], {"valor": _texto_custo(c)}))
		for l in c["explicacao"]:
			print("  • " + l)
		print(_fmt(m["detalhe_exemplo"], {"exemplo": c["exemplo"]}))
		return
	print("═══ %s ═══" % m["titulo"])
	for g in m["grupos"]:
		print(g["titulo"])
		for nome in g["comandos"]:
			var c: Dictionary = m["comandos"][nome]
			var custo: String = _fmt(m["custo"], {"valor": _texto_custo(c)}) if c.has("custo") else ""
			print(_fmt(m["linha_comando"], {"uso": c["uso"], "espaco": " ".repeat(maxi(1, 36 - c["uso"].length())), "resumo": c["resumo"], "custo": custo}))
	print(m["rodape"])


func _texto_custo(c: Dictionary) -> String:
	var txt := str(int(caso["custos"][c["custo"]]))
	if c.has("custo_rotulo"):
		txt += " " + c["custo_rotulo"]
	if c.has("custo_erro"):
		txt += " (erro: %d)" % int(caso["custos"][c["custo_erro"]])
	return txt


func _caderno() -> void:
	print("%s (%d)" % [t["rotulos"]["caderno"], sessao.estado["caderno"].size()])
	for termo in sessao.estado["caderno"]:
		print(_fmt(t["rotulos"]["item_caderno"], {"rotulo": _rotulo(termo), "tipo": caso["termos"][termo]["tipo"]}))


func _pendrive() -> void:
	print("%s (%d)" % [t["rotulos"]["pendrive"], sessao.estado["pendrive"].size()])
	for d in sessao.estado["pendrive"]:
		print(_fmt(t["rotulos"]["item_pendrive"], {"id": d, "arquivo": caso["documentos"][d]["arquivo"]}))


func _fato(id: String) -> void:
	var lacunas: Dictionary = sessao.estado["fatos"][id]
	var dados := {}
	for l in lacunas:
		dados[l] = "[%s]" % (_rotulo(lacunas[l]) if lacunas[l] != "" else _fmt(t["rotulos"]["lacuna_vazia"], {"lacuna": l}))
	var linha := "%s: %s" % [id, caso["fatos"][id]["frase"].format(dados)]
	if Dossie.fato_completo(sessao.estado, id):
		linha += "   " + t["rotulos"]["completo"]
	print(linha)


func _fatos() -> void:
	print(t["rotulos"]["fatos"])
	for id in caso["fatos"]:
		_fato(id)


func _rede() -> void:
	var r: Dictionary = t["rotulos"]
	print(r["rede"] + ":")
	for id in caso["nos"]:
		var n: Dictionary = sessao.estado["nos"][id]
		if not n["revelado"] and not id in sessao.estado["nomes_conhecidos"]:
			continue
		var estado_txt: String = r["estado_no"]["por_nome"] if not n["revelado"] else (
			r["estado_no"]["publico"] if caso["nos"][id]["publico"] else (
				r["estado_no"]["desbloqueado"] if n["desbloqueado"] else r["estado_no"]["bloqueado"]))
		var aqui: String = "   " + r["voce_esta_aqui"] if sessao.estado["conectado"] and sessao.estado["no_atual"] == id else ""
		print("  ● %s   (%s)%s" % [caso["nos"][id]["host"], estado_txt, aqui])
