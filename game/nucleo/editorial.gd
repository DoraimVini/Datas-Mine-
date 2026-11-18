# Fase "Entregar": checklist editorial da jornalista.
extends RefCounted

const Util := preload("res://nucleo/util.gd")
const Dossie := preload("res://nucleo/dossie.gd")


## Um documento do pendrive prova o fato se estiver em fato.provas e nenhuma das
## RESPOSTAS DESTE FATO tiver sido ocultada nele (ocultar quem o fato acusa apaga a prova).
## Se o caso não tiver a regra "prova_documental", qualquer fato correto basta.
static func _provado(estado: Dictionary, caso: Dictionary, fato: String) -> bool:
	if not "prova_documental" in caso["regras_editoriais"]:
		return true
	var respostas: Array = caso["fatos"][fato]["respostas"].values()
	for doc in caso["fatos"][fato]["provas"]:
		if not doc in estado["pendrive"]:
			continue
		var ocultos: Array = estado["ocultos"].get(doc, [])
		var enfraquecido := false
		for nome in ocultos:
			if nome in respostas:
				enfraquecido = true
		if not enfraquecido:
			return true
	return false


static func avaliar(estado: Dictionary, caso: Dictionary) -> Dictionary:
	var fatos := []
	var aprovado := true
	for fato in caso["fatos"]:
		var errados := 0
		for l in caso["fatos"][fato]["respostas"]:
			if estado["fatos"][fato][l] != caso["fatos"][fato]["respostas"][l]:
				errados += 1
		var provado := _provado(estado, caso, fato)
		var status := "confirmado"
		if errados > 0:
			status = "incorreto"
		elif not provado:
			status = "sem_prova"
		if status != "confirmado":
			aprovado = false
		var item := {"fato": fato, "status": status}
		if caso["feedback"] == "parcial" and errados > 0:
			item["campos_errados"] = errados
		fatos.append(item)

	var inocentes_total := 0
	var inocentes_protegidos := 0
	for doc in estado["pendrive"]:
		var ocultos: Array = estado["ocultos"].get(doc, [])
		for nome in caso["documentos"][doc]["inocentes"]:
			inocentes_total += 1
			if nome in ocultos:
				inocentes_protegidos += 1

	return {
		"aprovado": aprovado,
		"fatos": fatos,
		"inocentes_total": inocentes_total,
		"inocentes_protegidos": inocentes_protegidos,
	}


static func entregar(estado: Dictionary, caso: Dictionary, _cmd: Dictionary, eventos: Array) -> void:
	if estado["concluido"]:
		eventos.append(Util.erro("caso_ja_concluido"))
		return
	if estado["conectado"]:
		eventos.append(Util.erro("entregar_conectado"))
		return
	var faltando := []
	for fato in caso["fatos"]:
		if not Dossie.fato_completo(estado, fato):
			faltando.append(fato)
	if not faltando.is_empty():
		eventos.append(Util.erro("fatos_incompletos", {"fatos": faltando}))
		return

	var parecer := avaliar(estado, caso)
	if parecer["aprovado"]:
		estado["concluido"] = true
		estado["resultado"] = {
			"forca": parecer["fatos"].size(),
			"total_fatos": caso["fatos"].size(),
			"inocentes_protegidos": parecer["inocentes_protegidos"],
			"inocentes_total": parecer["inocentes_total"],
			"ruido": estado["ruido"],
			"exposicao": estado["exposicao"],
		}
		eventos.append({"tipo": "caso_concluido", "parecer": parecer, "resultado": estado["resultado"]})
	else:
		eventos.append({"tipo": "parecer_recusado", "parecer": parecer})
