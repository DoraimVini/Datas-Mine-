# Uma partida em andamento: guarda o caso e o estado atual e registra o histórico de comandos.
# É usada pelo console de texto e pelo autoload Jogo (interface).
extends RefCounted

const Conteudo := preload("res://app/conteudo.gd")
const Estado := preload("res://nucleo/estado.gd")
const Comandos := preload("res://nucleo/comandos.gd")

var caso: Dictionary = {}
var estado: Dictionary = {}
var historico: Array = []  # comandos aplicados, servem de cenário de teste (Arquitetura 8.6)


func iniciar(id_caso: String) -> Array:
	caso = Conteudo.carregar_caso(id_caso)
	if caso.is_empty():
		return ["não foi possível carregar o caso '%s'" % id_caso]
	var erros := Conteudo.validar_caso(caso)
	if erros.is_empty():
		estado = Estado.novo(caso)
		historico.clear()
	return erros


func executar(cmd: Dictionary) -> Array:
	var r := Comandos.aplicar(estado, caso, cmd)
	estado = r["estado"]
	historico.append(cmd)
	return r["eventos"]
