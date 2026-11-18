# Autoload "Jogo": a ponte entre a interface (grafos do Orchestrator) e o núcleo.
# A interface só faz duas coisas: chama Jogo.executar({...}) e escuta o sinal `evento`.
# Nenhuma regra de jogo mora aqui nem na interface (decisão 0005).
extends Node

const Sessao := preload("res://app/sessao.gd")

signal evento(dados: Dictionary)
signal caso_iniciado(id_caso: String)

var sessao := Sessao.new()


func iniciar_caso(id_caso: String) -> bool:
	var erros := sessao.iniciar(id_caso)
	for e in erros:
		push_error("Conteúdo inválido (%s): %s" % [id_caso, e])
	if erros.is_empty():
		caso_iniciado.emit(id_caso)
	return erros.is_empty()


func executar(cmd: Dictionary) -> void:
	for e in sessao.executar(cmd):
		evento.emit(e)


## Leitura do estado para a interface (cópia: a interface nunca altera o estado).
func estado() -> Dictionary:
	return sessao.estado.duplicate(true)


func caso() -> Dictionary:
	return sessao.caso
