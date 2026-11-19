# Desktop do ÉterOS: papel de parede, ícones, barra de tarefas com HUD, janelas e notificações.
# Apresentação pura: abre apps, mostra eventos como toasts e o HUD a partir de Jogo.estado().
#
# Modo de captura (para conferir o visual sem jogar):
#   Godot --path game -- caso1 anonimo --comandos "scan;probe gab-educacao-03" --abrir rede,arquivos --captura C:/tmp/tela.png
extends Control

const Tema := preload("res://ui/tema/tema.gd")
const Mensagens := preload("res://ui/mensagens.gd")
const Parser := preload("res://app/parser.gd")
const Argumentos := preload("res://app/argumentos.gd")
const JANELA := preload("res://ui/janela/Janela.tscn")

const APPS := {
	"chat": {"cena": "res://ui/apps/Chat.tscn", "tamanho": Vector2(440, 330), "pos": Vector2(760, 330)},
	"rede": {"cena": "res://ui/apps/Rede.tscn", "tamanho": Vector2(540, 470), "pos": Vector2(110, 24)},
	"arquivos": {"cena": "res://ui/apps/Arquivos.tscn", "tamanho": Vector2(760, 470), "pos": Vector2(170, 60)},
	"caderno": {"cena": "res://ui/apps/Caderno.tscn", "tamanho": Vector2(300, 400), "pos": Vector2(480, 24)},
	"dossie": {"cena": "res://ui/apps/Dossie.tscn", "tamanho": Vector2(660, 400), "pos": Vector2(220, 120)},
	"pendrive": {"cena": "res://ui/apps/Pendrive.tscn", "tamanho": Vector2(680, 440), "pos": Vector2(260, 90)},
	"ajuda": {"cena": "res://ui/apps/Ajuda.tscn", "tamanho": Vector2(680, 440), "pos": Vector2(300, 70)},
}
const ORDEM_ICONES := ["rede", "arquivos", "caderno", "dossie", "pendrive", "chat", "ajuda"]
const MAX_TOASTS := 5

@onready var _fundo: ColorRect = $Fundo
@onready var _marca: Label = $Marca
@onready var _icones: VBoxContainer = $Icones
@onready var _area: Control = $AreaJanelas
@onready var _barra: PanelContainer = $Barra
@onready var _nome_so: Label = $Barra/Linha/NomeSO
@onready var _tarefas: HBoxContainer = $Barra/Linha/Tarefas
@onready var _conexao: Label = $Barra/Linha/Conexao
@onready var _ruido: ProgressBar = $Barra/Linha/Ruido
@onready var _ruido_txt: Label = $Barra/Linha/Ruido/Texto
@onready var _exposicao: Label = $Barra/Linha/Exposicao
@onready var _relogio: Label = $Barra/Linha/Relogio
@onready var _toasts: VBoxContainer = $Toasts

var jogo: Node
var ti: Dictionary = {}
var _janelas := {}  # id -> Janela
var _botoes_tarefa := {}  # id -> Button
var _dicas_vistas := []


func _ready() -> void:
	add_to_group("desktop")
	theme = Tema.criar()
	jogo = get_node("/root/Jogo")
	ti = jogo.textos_interface
	_fundo.color = Tema.FUNDO
	_marca.text = "%s\n%s" % [ti["so"]["nome"], ti["so"]["slogan"]]
	_marca.add_theme_color_override("font_color", Tema.BORDA)
	_marca.add_theme_font_size_override("font_size", 22)
	_barra.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, Tema.BORDA, 1, 0, 6))
	_nome_so.text = " %s " % ti["so"]["nome"]
	_nome_so.add_theme_color_override("font_color", Tema.ACENTO)
	_ruido_txt.add_theme_color_override("font_color", Tema.TEXTO)
	# Contorno escuro: o texto continua legível sobre a barra verde, amarela ou vermelha.
	_ruido_txt.add_theme_color_override("font_outline_color", Tema.FUNDO)
	_ruido_txt.add_theme_constant_override("outline_size", 5)

	for id in ORDEM_ICONES:
		var app: Dictionary = ti["apps"][id]
		var b := Button.new()
		b.text = "%s\n%s" % [app["icone"], _titulo_app(id).split(" ")[0]]
		b.custom_minimum_size = Vector2(84, 64)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(abrir_app.bind(id))
		_icones.add_child(b)

	var relogio := Timer.new()
	relogio.wait_time = 1.0
	relogio.autostart = true
	relogio.timeout.connect(_atualizar_relogio)
	add_child(relogio)
	_atualizar_relogio()

	jogo.estado_mudou.connect(_atualizar_hud)
	jogo.evento.connect(_ao_evento)

	var args := Argumentos.ler(OS.get_cmdline_user_args())
	var id_caso: String = args["caso"]
	jogo.iniciar_caso(id_caso)
	abrir_app("chat")
	abrir_app("rede")
	_modo_captura(args["flags"])


func _titulo_app(id: String) -> String:
	return str(ti["apps"][id]["titulo"]).format(jogo.caso().get("jornalista", {}))


# ---------------- janelas ----------------

func abrir_app(id: String) -> void:
	if not APPS.has(id):
		return
	if _janelas.has(id):
		var j: Control = _janelas[id]
		j.visible = true
		j.trazer_para_frente()
		_garantir_tarefa(id)
		return
	var cfg: Dictionary = APPS[id]
	var app: Control = load(cfg["cena"]).instantiate()
	var j: Control = JANELA.instantiate()
	_area.add_child(j)
	j.configurar(id, "%s  %s" % [ti["apps"][id]["icone"], _titulo_app(id)], app, ti["janela"]["minimizar"], ti["janela"]["fechar"], cfg["tamanho"])
	j.mover_para.call_deferred(cfg["pos"])  # depois do layout, para o limite da área estar calculado
	j.fechar_pedido.connect(_fechar)
	j.minimizar_pedido.connect(_minimizar)
	_janelas[id] = j
	_garantir_tarefa(id)
	j.trazer_para_frente()


func janela(id: String) -> Control:
	return _janelas.get(id)


## Fechar esconde a janela e tira da barra (o app mantém o que estava mostrando).
func _fechar(j: Control) -> void:
	j.visible = false
	if _botoes_tarefa.has(j.id_app):
		_botoes_tarefa[j.id_app].queue_free()
		_botoes_tarefa.erase(j.id_app)


func _minimizar(j: Control) -> void:
	j.visible = false


func _garantir_tarefa(id: String) -> void:
	if _botoes_tarefa.has(id):
		return
	var b := Button.new()
	b.text = "%s %s" % [ti["apps"][id]["icone"], _titulo_app(id).split(" ")[0]]
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func():
		var j: Control = _janelas[id]
		if j.visible and j.get_index() == _area.get_child_count() - 1:
			j.visible = false
		else:
			abrir_app(id))
	_tarefas.add_child(b)
	_botoes_tarefa[id] = b


# ---------------- HUD e notificações ----------------

func _atualizar_relogio() -> void:
	var h := Time.get_time_dict_from_system()
	_relogio.text = " %02d:%02d " % [h["hour"], h["minute"]]


func _atualizar_hud() -> void:
	var e: Dictionary = jogo.estado()
	var caso: Dictionary = jogo.caso()
	if e.is_empty():
		return
	var maximo: int = caso["orcamento_ruido"]
	_ruido.max_value = maximo
	_ruido.value = e["ruido"]
	_ruido_txt.text = str(ti["hud"]["ruido"]).format({"valor": int(e["ruido"]), "max": maximo})
	var fracao := float(e["ruido"]) / maximo
	var cor := Tema.ACENTO if fracao < 0.7 else (Tema.ALERTA if fracao < 0.9 else Tema.PERIGO)
	_ruido.add_theme_stylebox_override("fill", Tema.caixa(cor, Color.TRANSPARENT, 0, 3, 0))
	_exposicao.text = " " + str(ti["hud"]["exposicao"]).format({"valor": int(e["exposicao"])}) + " "
	_exposicao.add_theme_color_override("font_color", Tema.TEXTO if e["exposicao"] == 0 else Tema.ALERTA)
	if e["conectado"]:
		_conexao.text = str(ti["hud"]["conectado"]).format({"host": caso["nos"][e["no_atual"]]["host"]})
		_conexao.add_theme_color_override("font_color", Tema.ACENTO)
	else:
		_conexao.text = ti["hud"]["desconectado"]
		_conexao.add_theme_color_override("font_color", Tema.TEXTO_FRACO)


func _ao_evento(e: Dictionary) -> void:
	var m := Mensagens.para_toast(e, jogo.caso(), jogo.textos_console)
	if not m.is_empty():
		toast(m["texto"], m["nivel"])
	var dicas: Dictionary = ti["dicas"]
	if dicas.has(e["tipo"]) and not e["tipo"] in _dicas_vistas:
		_dicas_vistas.append(e["tipo"])
		jogo.registrar_extra("dicas_vistas", _dicas_vistas.duplicate())
		toast(jogo.textos_console["rotulos"]["prefixo_dica"] + dicas[e["tipo"]], "dica")
	if e["tipo"] in ["parecer_recusado", "caso_concluido"]:
		abrir_app("chat")


func toast(texto: String, nivel := "info") -> void:
	var cores := {"info": Tema.BORDA, "ok": Tema.OK, "alerta": Tema.ALERTA, "erro": Tema.PERIGO, "dica": Tema.ACENTO_2}
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Tema.caixa(Tema.SUPERFICIE_2, cores.get(nivel, Tema.BORDA), 2, 4, 8))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.text = texto
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(340, 0)
	p.add_child(l)
	_toasts.add_child(p)
	while _toasts.get_child_count() > MAX_TOASTS:
		_toasts.get_child(0).free()
	var tw := p.create_tween()
	tw.tween_interval(5.0 if nivel != "dica" else 8.0)
	tw.tween_property(p, "modulate:a", 0.0, 0.6)
	tw.tween_callback(p.queue_free)


# ---------------- modo de captura ----------------

func _modo_captura(flags: Dictionary) -> void:
	var destino: String = flags.get("captura", "")
	if destino == "":
		return
	for linha in str(flags.get("comandos", "")).split(";", false):
		var r := Parser.analisar(linha)
		if r["tipo"] == "comando":
			jogo.executar(r["cmd"])
	for id in str(flags.get("abrir", "")).split(",", false):
		abrir_app(id.strip_edges())
	for i in 20:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	img.save_png(destino)
	print("captura salva: ", destino)
	get_tree().quit()
