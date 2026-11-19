# Testes do parser de comandos (compartilhado: console, captura, futuro Terminal) e dos argumentos.
extends "res://testes/base_teste.gd"

const Parser := preload("res://app/parser.gd")
const Argumentos := preload("res://app/argumentos.gd")


func test_comandos_simples_e_com_argumentos() -> void:
	igual(Parser.analisar("scan"), {"tipo": "comando", "cmd": {"tipo": "scan"}})
	igual(Parser.analisar("/SCAN")["cmd"], {"tipo": "scan"})
	igual(Parser.analisar("login gab lucia.prado x")["cmd"], {"tipo": "login", "no": "gab", "usuario": "lucia.prado", "senha": "x"})
	igual(Parser.analisar("crack srv 445")["cmd"]["porta"], 445)
	igual(Parser.analisar("pin <2 9 1>")["cmd"]["codigo"], "2 9 1")
	igual(Parser.analisar("READ DOC3")["cmd"]["doc"], "doc3")


func test_termos_com_espacos_e_acentos() -> void:
	igual(Parser.analisar("coletar Antônio Souza")["cmd"]["termo"], "Antônio Souza")
	var p: Dictionary = Parser.analisar("preencher fato1 quanto R$ 480.000,00")["cmd"]
	igual(p["termo"], "R$ 480.000,00")
	igual(Parser.analisar("ocultar doc5 Joana Alves")["cmd"]["nome"], "Joana Alves")
	igual(Parser.analisar("limpar-lacuna fato1 quem")["cmd"]["tipo"], "limpar_lacuna")


func test_locais_uso_e_desconhecido() -> void:
	igual(Parser.analisar("ajuda /login"), {"tipo": "local", "verbo": "help", "arg": "login"})
	igual(Parser.analisar("?")["verbo"], "help")
	igual(Parser.analisar("caderno")["tipo"], "local")
	igual(Parser.analisar("login gab"), {"tipo": "uso", "verbo": "login"})
	igual(Parser.analisar("xyz")["tipo"], "desconhecido")
	igual(Parser.analisar("   ")["tipo"], "vazio")


func test_argumentos_pulam_valor_das_flags() -> void:
	var a := Argumentos.ler(PackedStringArray(["--comandos", "scan", "--captura", "x.png"]))
	igual(a["caso"], "caso1", "valor de flag não pode virar o caso:")
	igual(a["jogador"], "anonimo")
	igual(a["flags"], {"comandos": "scan", "captura": "x.png"})
	a = Argumentos.ler(PackedStringArray(["caso1", "P03", "--abrir", "rede,arquivos"]))
	igual(a["jogador"], "P03")
	igual(a["flags"]["abrir"], "rede,arquivos")
