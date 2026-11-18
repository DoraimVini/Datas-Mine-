# Funções auxiliares puras do núcleo (sem Node, sem I/O).
extends RefCounted

const _ACENTOS := {
	"á": "a", "à": "a", "â": "a", "ã": "a", "ä": "a",
	"é": "e", "è": "e", "ê": "e", "ë": "e",
	"í": "i", "ì": "i", "î": "i", "ï": "i",
	"ó": "o", "ò": "o", "ô": "o", "õ": "o", "ö": "o",
	"ú": "u", "ù": "u", "û": "u", "ü": "u",
	"ç": "c", "ñ": "n",
}


## Normaliza um texto para comparação: minúsculas, sem acentos e só letras/dígitos.
## "R$ 480.000,00" -> "r48000000"; "Antônio Souza" -> "antoniosouza".
static func normalizar(texto: String) -> String:
	var saida := ""
	for c in texto.to_lower():
		var ch: String = _ACENTOS.get(c, c)
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			saida += ch
	return saida


## Procura, entre `ids`, o termo cujo rótulo corresponde a `entrada`.
## Aceita a entrada exata (normalizada) e, só para termos do tipo "valor", também sem o "R$".
static func achar_termo(caso: Dictionary, ids: Array, entrada: String) -> String:
	var alvo := normalizar(entrada)
	if alvo.is_empty():
		return ""
	for id in ids:
		var termo: Dictionary = caso["termos"][id]
		var rotulo := normalizar(termo["rotulo"])
		if rotulo == alvo:
			return id
		if termo["tipo"] == "valor" and rotulo.begins_with("r") and rotulo.substr(1) == alvo:
			return id
	return ""


## Converte um host ("srv-contratos", sem diferenciar maiúsculas) ou um id ("n3") no id do nó.
## "" se não existir.
static func id_do_no(caso: Dictionary, nome: String) -> String:
	var alvo := nome.strip_edges().to_lower()
	if caso["nos"].has(alvo):
		return alvo
	for id in caso["nos"]:
		if str(caso["nos"][id]["host"]).to_lower() == alvo:
			return id
	return ""


static func erro(codigo: String, dados: Dictionary = {}) -> Dictionary:
	var e := {"tipo": "erro", "codigo": codigo}
	e.merge(dados)
	return e
