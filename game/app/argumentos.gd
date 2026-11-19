# Lê os argumentos de usuário (depois de "--"): posicionais <caso> <jogador> e flags "--nome valor".
# O valor de cada flag NÃO conta como posicional.
extends RefCounted


static func ler(args: PackedStringArray) -> Dictionary:
	var posicionais := []
	var flags := {}
	var i := 0
	while i < args.size():
		var a: String = args[i]
		if a.begins_with("--"):
			var tem_valor := i + 1 < args.size() and not args[i + 1].begins_with("--")
			flags[a.trim_prefix("--")] = args[i + 1] if tem_valor else ""
			i += 2 if tem_valor else 1
		else:
			posicionais.append(a)
			i += 1
	return {
		"caso": posicionais[0] if posicionais.size() > 0 else "caso1",
		"jogador": posicionais[1] if posicionais.size() > 1 else "anonimo",
		"flags": flags,
	}
