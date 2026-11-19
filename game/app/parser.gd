# Traduz uma linha de texto ("login gab-educacao-03 lucia.prado x") em um Comando do núcleo.
# Usado pelo console de texto, pelo modo de captura da interface e, no futuro, pelo app Terminal
# (decisão 0002: a GUI e o terminal geram os MESMOS comandos).
extends RefCounted

const LOCAIS := ["help", "caderno", "fatos", "pendrive", "rede", "memorando"]

# verbo -> [mínimo de partes, construtor]
const _MINIMOS := {
	"probe": 2, "connect": 2, "login": 4, "crack": 3, "pin": 2, "read": 2, "download": 2,
	"coletar": 2, "preencher": 4, "limpar-lacuna": 3, "ocultar": 3, "revelar": 3,
}


## Devolve um destes formatos:
##   {"tipo": "comando", "cmd": {...}}          comando do núcleo
##   {"tipo": "local", "verbo": v, "arg": a}     consulta da interface (help, caderno...)
##   {"tipo": "uso", "verbo": v}                 faltam argumentos
##   {"tipo": "desconhecido", "verbo": v}
##   {"tipo": "vazio"}
static func analisar(linha: String) -> Dictionary:
	var limpa := linha.strip_edges().replace("<", "").replace(">", "")
	var p := limpa.split(" ", false)
	if p.is_empty():
		return {"tipo": "vazio"}
	var verbo := p[0].to_lower().trim_prefix("/")
	var resto := limpa.substr(limpa.find(" ") + 1).strip_edges() if p.size() > 1 else ""
	if verbo in ["ajuda", "?"]:
		verbo = "help"
	if verbo in LOCAIS:
		return {"tipo": "local", "verbo": verbo, "arg": resto.to_lower().trim_prefix("/")}
	if p.size() < _MINIMOS.get(verbo, 1):
		return {"tipo": "uso", "verbo": verbo}
	var cmd := {}
	match verbo:
		"scan", "ls", "limpar", "disconnect", "entregar": cmd = {"tipo": verbo}
		"probe", "connect": cmd = {"tipo": verbo, "no": p[1]}
		"login": cmd = {"tipo": "login", "no": p[1], "usuario": p[2], "senha": p[3]}
		"crack": cmd = {"tipo": "crack", "no": p[1], "porta": int(p[2])}
		"pin": cmd = {"tipo": "pin", "codigo": resto}
		"read", "download": cmd = {"tipo": verbo, "doc": p[1].to_lower()}
		"coletar": cmd = {"tipo": "coletar", "termo": resto}
		"preencher": cmd = {"tipo": "preencher", "fato": p[1].to_lower(), "lacuna": p[2], "termo": " ".join(p.slice(3))}
		"limpar-lacuna": cmd = {"tipo": "limpar_lacuna", "fato": p[1].to_lower(), "lacuna": p[2]}
		"ocultar", "revelar": cmd = {"tipo": verbo, "doc": p[1].to_lower(), "nome": " ".join(p.slice(2))}
		_: return {"tipo": "desconhecido", "verbo": verbo}
	return {"tipo": "comando", "cmd": cmd}
