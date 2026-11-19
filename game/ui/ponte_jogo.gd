# PonteJogo: nó auxiliar para os grafos do Orchestrator.
# Repassa os sinais do autoload Jogo como sinais DESTA cena. Assim, no editor, dá para ligar
# "PonteJogo → estado_mudou" a uma função do grafo pelo painel Nó → Sinais, sem programar conexões.
extends Node

signal estado_mudou
signal evento(dados: Dictionary)


func _ready() -> void:
	var jogo := get_node("/root/Jogo")
	jogo.estado_mudou.connect(func(): estado_mudou.emit())
	jogo.evento.connect(func(e): evento.emit(e))
	# Primeira atualização assim que a cena estiver pronta.
	(func(): estado_mudou.emit()).call_deferred()
