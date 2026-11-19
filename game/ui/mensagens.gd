# Converte um evento do núcleo em uma linha curta para notificações (toasts) da interface.
# Usa os MESMOS modelos do console (console.json), para os dois falarem igual.
extends RefCounted


## Devolve {"texto": String, "nivel": "info"|"ok"|"alerta"|"erro"} ou {} se o evento não gera aviso.
static func para_toast(e: Dictionary, caso: Dictionary, t: Dictionary) -> Dictionary:
	var ev: Dictionary = t["eventos"]
	var host := func(id): return caso["nos"][id]["host"] if caso["nos"].has(id) else str(id)
	var rotulo := func(id): return caso["termos"][id]["rotulo"] if caso["termos"].has(id) else str(id)
	match e["tipo"]:
		"erro":
			var dados := e.duplicate()
			if e.has("no"): dados["host"] = host.call(e["no"])
			if e.has("fatos"): dados["lista"] = ", ".join(e["fatos"])
			return {"texto": str(t["erros"].get(e["codigo"], e["codigo"])).format(dados), "nivel": "erro"}
		"ruido":
			return {"texto": ev["ruido"].format({"custo": int(e["custo"]), "total": int(e["total"]), "orcamento": int(e["orcamento"])}), "nivel": "info"}
		"varredura":
			if e["novos"].is_empty():
				return {"texto": ev["varredura_nada"], "nivel": "info"}
			return {"texto": ev["varredura_novos"].format({"lista": ", ".join(e["novos"].map(host))}), "nivel": "ok"}
		"conectado": return {"texto": ev["conectado"].format({"host": host.call(e["no"])}), "nivel": "ok"}
		"login_ok": return {"texto": ev["login_ok"].format({"usuario": e["usuario"]}), "nivel": "ok"}
		"senha_errada": return {"texto": ev["senha_errada"], "nivel": "erro"}
		"pin_ok": return {"texto": ev["pin_ok"].format({"host": host.call(e["no"])}), "nivel": "ok"}
		"pin_errado": return {"texto": ev["pin_errado"], "nivel": "erro"}
		"coletado": return {"texto": ev["coletado"].format({"rotulo": rotulo.call(e["termo"])}), "nivel": "ok"}
		"baixado": return {"texto": ev["baixado"].format(e), "nivel": "ok"}
		"rastros_limpos": return {"texto": ev["rastros_limpos"].format({"host": host.call(e["no"])}), "nivel": "ok"}
		"aviso_rastros":
			return {"texto": ev["aviso_rastros"].format({"qtd": e["nos"].size(), "lista": ", ".join(e["nos"].map(host)), "exposicao": e["exposicao_prevista"]}), "nivel": "alerta"}
		"desconectado": return {"texto": ev["desconectado"].format({"ganho": e["exposicao_ganha"], "exposicao": e["exposicao"]}), "nivel": "info"}
		"lockdown": return {"texto": ev["lockdown"].format({"ganho": e["exposicao_ganha"], "exposicao": e["exposicao"]}), "nivel": "erro"}
		"nome_oculto": return {"texto": ev["nome_oculto"].format(e), "nivel": "ok"}
		"nome_revelado": return {"texto": ev["nome_revelado"].format({"doc": e["doc"], "rotulo": rotulo.call(e["termo"])}), "nivel": "ok"}
	return {}


## Linhas da resposta da jornalista a uma entrega (parecer), para o app Chat.
static func linhas_parecer(parecer: Dictionary, t: Dictionary) -> Array:
	var ev: Dictionary = t["eventos"]
	var linhas := []
	for f in parecer["fatos"]:
		var chave: String = "parecer_" + str(f["status"])
		if f.has("campos_errados"):
			chave = "parecer_incorreto_parcial"
		linhas.append(str(ev[chave]).format({"fato": f["fato"], "n": f.get("campos_errados", 0)}).strip_edges())
	linhas.append(str(ev["inocentes"]).format({"protegidos": parecer["inocentes_protegidos"], "total": parecer["inocentes_total"]}).strip_edges())
	return linhas
