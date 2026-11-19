# Janela genérica do ÉterOS: arrastar pela barra de título, trazer para frente ao clicar,
# minimizar e fechar. Fica presa aos limites do pai (a área do desktop). O app vai em $Conteudo.
extends PanelContainer

signal fechar_pedido(janela: Control)
signal minimizar_pedido(janela: Control)
signal focada(janela: Control)

const Tema := preload("res://ui/tema/tema.gd")

@onready var _barra: PanelContainer = $Corpo/Barra
@onready var _titulo: Label = $Corpo/Barra/Linha/Titulo
@onready var _bt_min: Button = $Corpo/Barra/Linha/Minimizar
@onready var _bt_fechar: Button = $Corpo/Barra/Linha/Fechar
@onready var conteudo: MarginContainer = $Corpo/Conteudo

var id_app := ""
var _arrastando := false


func _ready() -> void:
	_barra.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, Tema.BORDA, 1, 6, 6))
	_titulo.add_theme_color_override("font_color", Tema.ACENTO)
	_barra.gui_input.connect(_na_barra)
	_bt_min.pressed.connect(func(): minimizar_pedido.emit(self))
	_bt_fechar.pressed.connect(func(): fechar_pedido.emit(self))
	gui_input.connect(_ao_clicar)


func configurar(id: String, titulo: String, app: Control, simbolo_min: String, simbolo_fechar: String, tamanho: Vector2) -> void:
	id_app = id
	_titulo.text = titulo
	_bt_min.text = simbolo_min
	_bt_fechar.text = simbolo_fechar
	conteudo.add_child(app)
	clip_contents = true
	custom_minimum_size = tamanho
	size = tamanho


func _ao_clicar(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed:
		trazer_para_frente()


func trazer_para_frente() -> void:
	move_to_front()
	focada.emit(self)


func _na_barra(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		_arrastando = ev.pressed
		if ev.pressed:
			trazer_para_frente()
	elif ev is InputEventMouseMotion and _arrastando:
		mover_para(position + ev.relative)


## Move a janela mantendo-a dentro da área do pai.
func mover_para(destino: Vector2) -> void:
	var limite: Vector2 = get_parent().size if get_parent() is Control else get_viewport_rect().size
	position = Vector2(
		clampf(destino.x, 0.0, maxf(0.0, limite.x - size.x)),
		clampf(destino.y, 0.0, maxf(0.0, limite.y - size.y)))
