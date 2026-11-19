# Base dos apps (cola provisória em GDScript, decisão 0008).
# Todo app faz só três coisas: lê Jogo.estado(), chama Jogo.executar({...}) e reage aos sinais de Jogo.
# Quem for trocar um app por um grafo .torch precisa reproduzir exatamente isso.
extends VBoxContainer

const Tema := preload("res://ui/tema/tema.gd")

var jogo: Node
var t: Dictionary = {}   # console.json (eventos, erros, manual)
var ti: Dictionary = {}  # interface.json (rótulos da interface)


func _ready() -> void:
	jogo = get_node("/root/Jogo")
	t = jogo.textos_console
	ti = jogo.textos_interface
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	montar()
	jogo.estado_mudou.connect(atualizar)
	jogo.evento.connect(ao_evento)
	atualizar()


## Cria os nós fixos do app (uma vez). Sobrescreva nos apps.
func montar() -> void:
	pass


## Redesenha a partir do estado atual. Sobrescreva nos apps.
func atualizar() -> void:
	pass


## Reage a um evento específico do núcleo (opcional).
func ao_evento(_e: Dictionary) -> void:
	pass


func caso() -> Dictionary:
	return jogo.caso()


func estado() -> Dictionary:
	return jogo.estado()


func executar(cmd: Dictionary) -> void:
	jogo.executar(cmd)


func host(id: String) -> String:
	return caso()["nos"][id]["host"] if caso()["nos"].has(id) else id


func rotulo(termo: String) -> String:
	return caso()["termos"][termo]["rotulo"] if caso()["termos"].has(termo) else termo


func abrir_app(id: String) -> void:
	get_tree().call_group("desktop", "abrir_app", id)


func botao(texto: String, ao_clicar: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(ao_clicar)
	return b


func rotulo_ui(texto: String, cor: Color = Tema.TEXTO, quebra := false) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_color_override("font_color", cor)
	if quebra:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# Sem largura mínima, o Label com quebra calcula uma altura enorme antes do layout.
		l.custom_minimum_size = Vector2(160, 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func limpar_filhos(no: Node) -> void:
	for c in no.get_children():
		no.remove_child(c)
		c.queue_free()
