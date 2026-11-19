# Autoload "Jogo": a ponte entre a interface (cenas + grafos do Orchestrator) e o núcleo.
# A interface só faz três coisas: chama Jogo.executar({...}), escuta os sinais e lê Jogo.estado().
# Nenhuma regra de jogo mora aqui nem na interface (decisão 0005).
extends Node

const Sessao := preload("res://app/sessao.gd")
const Telemetria := preload("res://app/telemetria.gd")
const Conteudo := preload("res://app/conteudo.gd")
const Argumentos := preload("res://app/argumentos.gd")
const Dossie := preload("res://nucleo/dossie.gd")

const PASTA_LOGS := "user://playtests"

signal evento(dados: Dictionary)  # um sinal por evento do núcleo
signal estado_mudou  # depois de cada executar (a interface redesenha)
signal caso_iniciado(id_caso: String)

var sessao := Sessao.new()
var jogador := "anonimo"
var textos_console: Dictionary = {}  # mensagens de eventos, erros, dicas e manual (fonte única com o console)
var textos_interface: Dictionary = {}

var _inicio_ms := 0
var _registros: Array = []  # {t, comando, eventos}: mesma estrutura do log do console
var _extras_log := {}  # dados de apresentação para o log (dicas vistas, apps abertos...)


func _ready() -> void:
	textos_console = Conteudo.carregar_json("res://conteudo/textos/console.json")
	textos_interface = Conteudo.carregar_json("res://conteudo/textos/interface.json")
	jogador = Argumentos.ler(OS.get_cmdline_user_args())["jogador"]


func iniciar_caso(id_caso: String) -> bool:
	var erros := sessao.iniciar(id_caso)
	for e in erros:
		push_error("Conteúdo inválido (%s): %s" % [id_caso, e])
	if erros.is_empty():
		_inicio_ms = Time.get_ticks_msec()
		_registros.clear()
		_extras_log.clear()
		_caso_ui = sessao.caso.duplicate(true)
		_estado_ui = sessao.estado.duplicate(true)
		caso_iniciado.emit(id_caso)
		estado_mudou.emit()
	return erros.is_empty()


## Executa um comando no núcleo, emite um sinal por evento e devolve os eventos.
func executar(cmd: Dictionary) -> Array:
	var eventos := sessao.executar(cmd)
	_estado_ui = sessao.estado.duplicate(true)
	_registros.append({"t": snappedf((Time.get_ticks_msec() - _inicio_ms) / 1000.0, 0.1), "comando": cmd, "eventos": eventos})
	for e in eventos:
		evento.emit(e)
	estado_mudou.emit()
	return eventos


# Cópias para a interface: atualizadas uma vez por comando (não a cada leitura).
# Se a interface (ou um grafo) alterar essas cópias, o estado real do jogo NÃO muda.
var _estado_ui: Dictionary = {}
var _caso_ui: Dictionary = {}


## Leitura do estado para a interface (cópia; a única forma de mudar o estado é executar()).
func estado() -> Dictionary:
	return _estado_ui


## Conteúdo do caso para a interface (cópia).
func caso() -> Dictionary:
	return _caso_ui


## Consultas ao núcleo que a interface precisa mostrar (a UI não recalcula regras).
func fato_completo(fato: String) -> bool:
	return Dossie.fato_completo(sessao.estado, fato)


## Apresentação registra dados extras no log (ex.: dicas vistas). Não afeta o jogo.
func registrar_extra(chave: String, valor) -> void:
	_extras_log[chave] = valor


func salvar_log() -> String:
	if sessao.caso.is_empty() or _registros.is_empty():
		return ""
	DirAccess.make_dir_recursive_absolute(PASTA_LOGS)
	var carimbo := Time.get_datetime_string_from_system(false, true).replace(":", "-").replace(" ", "_")
	var caminho := "%s/%s_%s_%s_gui.json" % [PASTA_LOGS, carimbo, jogador, sessao.caso["id"]]
	var extras := _extras_log.duplicate()
	extras["interface"] = "gui"
	extras["duracao_total_s"] = int((Time.get_ticks_msec() - _inicio_ms) / 1000.0)
	var dados := {
		"jogador": jogador,
		"data": Time.get_datetime_string_from_system(false, true),
		"metricas": Telemetria.metricas(sessao.caso, _registros, sessao.estado, extras),
		"registros": _registros,
	}
	var f := FileAccess.open(caminho, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(JSON.stringify(dados, "  "))
	f.close()
	return ProjectSettings.globalize_path(caminho)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		salvar_log()
