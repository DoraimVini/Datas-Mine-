# Executor de testes próprio (decisão 0007).
# Uso: godot --headless --path game -s res://testes/executar.gd
# Roda todo arquivo testes/test_*.gd e todo método que começa com "test_". Código de saída 1 se algo falhar.
#
# Erros de script (ex.: chamar método em null) NÃO param o GDScript: a função só aborta.
# Por isso um Logger registra todo erro do motor durante cada teste, e qualquer erro conta como falha.
extends SceneTree


class Coletor extends Logger:
	var erros: Array = []
	var _trava := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array) -> void:
		if error_type == Logger.ERROR_TYPE_WARNING:
			return  # avisos (push_warning) não reprovam teste; só erros
		_trava.lock()
		erros.append("%s:%d (%s) %s" % [file, line, function, rationale if rationale != "" else code])
		_trava.unlock()


var _rodou := false


# Os testes rodam no PRIMEIRO frame: só então a raiz está na árvore e os autoloads (Jogo) já
# passaram pelo _ready. Em _init/_initialize ainda é cedo demais.
var _terminou := false


func _process(_delta: float) -> bool:
	if not _rodou:
		_rodou = true
		_rodar()
		# Se _rodar abortou no meio (erro no próprio executor), não pode ficar preso para sempre.
		if not _terminou:
			print("✖ o executor abortou antes do fim")
			print("0 testes, 1 falhas")
			quit(1)
	return false


func _rodar() -> void:
	var coletor := Coletor.new()
	OS.add_logger(coletor)
	var total := 0
	var falhas := []
	var arquivos := []
	for f in DirAccess.open("res://testes").get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			arquivos.append(f)
	arquivos.sort()

	for f in arquivos:
		var script: GDScript = load("res://testes/" + f)
		if script == null or not script.can_instantiate():
			total += 1
			falhas.append("%s: o arquivo de teste não compila" % f)
			print(" FALHA %s (não compila)" % f)
			continue
		var inst = script.new()
		inst.arvore = self
		for m in inst.get_method_list():
			var nome: String = m["name"]
			if not nome.begins_with("test_"):
				continue
			total += 1
			inst._teste_atual = "%s::%s" % [f, nome]
			var antes: int = inst.falhas.size()
			var erros_antes: int = coletor.erros.size()
			inst.call(nome)
			for i in range(erros_antes, coletor.erros.size()):
				inst.falhas.append("%s: ERRO %s" % [inst._teste_atual, coletor.erros[i]])
			print("%s %s" % ["  ok  " if inst.falhas.size() == antes else " FALHA", inst._teste_atual])
		falhas.append_array(inst.falhas)

	OS.remove_logger(coletor)
	print("")
	for msg in falhas:
		print("✖ " + msg)
	print("%d testes, %d falhas" % [total, falhas.size()])
	_terminou = true
	quit(1 if not falhas.is_empty() else 0)
