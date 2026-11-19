# Métricas de playtest calculadas a partir do histórico da partida.
# Função pura sobre dados (comandos + eventos + estado final): testável sem arquivos.
extends RefCounted


## `registros` = lista de {t (segundos desde o início), comando, eventos[]}.
static func metricas(caso: Dictionary, registros: Array, estado_final: Dictionary, extras: Dictionary = {}) -> Dictionary:
	var erros := {}
	var contagem := {
		"senhas_erradas": 0, "pins_errados": 0, "lockdowns": 0,
		"entregas_recusadas": 0, "avisos_rastros": 0, "limpezas": 0, "downloads": 0,
	}
	var iscas_tentadas := []
	var primeira_entrega := -1.0
	var conclusao := -1.0

	var iscas_por_fato := {}
	for f in caso["fatos"]:
		iscas_por_fato[f] = caso["fatos"][f].get("iscas", [])

	for r in registros:
		for e in r["eventos"]:
			match e["tipo"]:
				"erro": erros[e["codigo"]] = erros.get(e["codigo"], 0) + 1
				"senha_errada": contagem["senhas_erradas"] += 1
				"pin_errado": contagem["pins_errados"] += 1
				"lockdown": contagem["lockdowns"] += 1
				"aviso_rastros": contagem["avisos_rastros"] += 1
				"rastros_limpos": contagem["limpezas"] += 1
				"baixado": contagem["downloads"] += 1
				"parecer_recusado":
					contagem["entregas_recusadas"] += 1
					if primeira_entrega < 0: primeira_entrega = r["t"]
				"caso_concluido":
					conclusao = r["t"]
					if primeira_entrega < 0: primeira_entrega = r["t"]
				"lacuna_preenchida":
					if e["termo"] in iscas_por_fato.get(e["fato"], []):
						iscas_tentadas.append({"fato": e["fato"], "lacuna": e["lacuna"], "termo": e["termo"]})

	var duracao: float = registros[-1]["t"] if not registros.is_empty() else 0.0
	return {
		"caso": caso["id"],
		"concluido": estado_final.get("concluido", false),
		"resultado": estado_final.get("resultado", {}),
		"duracao_s": int(duracao),
		"tempo_ate_primeira_entrega_s": int(primeira_entrega),
		"tempo_ate_conclusao_s": int(conclusao),
		"comandos": registros.size(),
		"ruido_final": estado_final.get("ruido", 0),
		"exposicao_final": estado_final.get("exposicao", 0),
		"termos_coletados": estado_final.get("caderno", []).size(),
		"documentos_lidos": estado_final.get("lidos", []).size(),
		"contagem": contagem,
		"erros_por_codigo": erros,
		"iscas_tentadas": iscas_tentadas,
	}.merged(extras)
