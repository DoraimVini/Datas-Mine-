# App "Caderno": lista os termos coletados.
# É o PRIMEIRO candidato a virar grafo (.torch): ver "Guia - Trocando GDScript por grafos".
# Os nós $Vazio e $Lista já existem na cena; o script só preenche.
extends "res://ui/apps/app_base.gd"

@onready var _vazio: Label = $Vazio
@onready var _lista: ItemList = $Lista


func montar() -> void:
	_vazio.text = ti["caderno"]["vazio"]


func atualizar() -> void:
	var e := estado()
	if e.is_empty():
		return
	_lista.clear()
	for termo in e["caderno"]:
		_lista.add_item(str(ti["caderno"]["item"]).format({"rotulo": rotulo(termo), "tipo": caso()["termos"][termo]["tipo"]}))
	_vazio.visible = e["caderno"].is_empty()
