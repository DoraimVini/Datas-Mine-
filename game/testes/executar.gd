# Executor de testes próprio (decisão 0007).
# Uso: godot --headless --path game -s res://testes/executar.gd
# Roda todo arquivo testes/test_*.gd e todo método que começa com "test_". Código de saída 1 se algo falhar.
extends SceneTree


func _init() -> void:
	var total := 0
	var falhas := []
	var dir := DirAccess.open("res://testes")
	var arquivos := []
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			arquivos.append(f)
	arquivos.sort()

	for f in arquivos:
		var script: GDScript = load("res://testes/" + f)
		var inst = script.new()
		for m in inst.get_method_list():
			var nome: String = m["name"]
			if not nome.begins_with("test_"):
				continue
			total += 1
			inst._teste_atual = "%s::%s" % [f, nome]
			var antes: int = inst.falhas.size()
			inst.call(nome)
			print("%s %s" % ["  ok  " if inst.falhas.size() == antes else " FALHA", inst._teste_atual])
		falhas.append_array(inst.falhas)

	print("")
	for msg in falhas:
		print("✖ " + msg)
	print("%d testes, %d falhas" % [total, falhas.size()])
	quit(1 if not falhas.is_empty() else 0)
