# Tema visual do ÉterOS (SO fictício). Cores como tokens; o Theme é montado em código
# para ficar legível e diffável. Renderizador Compatibility: só StyleBoxFlat, sem shaders pesados.
extends RefCounted

# --- tokens ---
const FUNDO := Color("0b0f14")        # papel de parede
const SUPERFICIE := Color("121821")   # janelas
const SUPERFICIE_2 := Color("1a2330") # barras, campos
const BORDA := Color("263241")
const TEXTO := Color("d6dde6")
const TEXTO_FRACO := Color("7d8a99")
const ACENTO := Color("39e5b6")       # neon do coletivo
const ACENTO_2 := Color("5aa9ff")     # links / termos
const PERIGO := Color("ff5d73")
const ALERTA := Color("ffc857")
const OK := Color("6bdc8b")

const TAM_FONTE := 15


static func fonte_mono() -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Consolas", "Cascadia Mono", "DejaVu Sans Mono", "Courier New", "monospace"])
	return f


static func caixa(cor: Color, borda: Color = Color.TRANSPARENT, largura := 0, raio := 4, margem := 8) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = cor
	s.border_color = borda
	s.set_border_width_all(largura)
	s.set_corner_radius_all(raio)
	s.set_content_margin_all(margem)
	return s


static func criar() -> Theme:
	var t := Theme.new()
	t.default_font = fonte_mono()
	t.default_font_size = TAM_FONTE

	for tipo in ["Label", "RichTextLabel", "Button", "LineEdit", "ItemList", "OptionButton", "CheckButton"]:
		t.set_color("font_color", tipo, TEXTO)
	t.set_color("default_color", "RichTextLabel", TEXTO)
	t.set_color("font_hover_color", "Button", ACENTO)
	t.set_color("font_pressed_color", "Button", FUNDO)
	t.set_color("font_disabled_color", "Button", TEXTO_FRACO)

	t.set_stylebox("normal", "Button", caixa(SUPERFICIE_2, BORDA, 1, 3, 6))
	t.set_stylebox("hover", "Button", caixa(SUPERFICIE_2, ACENTO, 1, 3, 6))
	t.set_stylebox("pressed", "Button", caixa(ACENTO, ACENTO, 1, 3, 6))
	t.set_stylebox("disabled", "Button", caixa(SUPERFICIE, BORDA, 1, 3, 6))
	t.set_stylebox("focus", "Button", caixa(Color.TRANSPARENT, ACENTO_2, 1, 3, 6))

	for tipo in ["OptionButton"]:
		t.set_stylebox("normal", tipo, caixa(SUPERFICIE_2, BORDA, 1, 3, 6))
		t.set_stylebox("hover", tipo, caixa(SUPERFICIE_2, ACENTO_2, 1, 3, 6))
		t.set_stylebox("pressed", tipo, caixa(SUPERFICIE_2, ACENTO, 1, 3, 6))

	t.set_stylebox("normal", "LineEdit", caixa(FUNDO, BORDA, 1, 3, 6))
	t.set_stylebox("focus", "LineEdit", caixa(FUNDO, ACENTO, 1, 3, 6))
	t.set_stylebox("panel", "ItemList", caixa(FUNDO, BORDA, 1, 3, 4))
	t.set_color("font_selected_color", "ItemList", FUNDO)
	t.set_stylebox("selected", "ItemList", caixa(ACENTO, Color.TRANSPARENT, 0, 2, 4))
	t.set_stylebox("selected_focus", "ItemList", caixa(ACENTO, Color.TRANSPARENT, 0, 2, 4))
	t.set_stylebox("normal", "RichTextLabel", caixa(FUNDO, BORDA, 1, 3, 10))
	t.set_stylebox("panel", "PanelContainer", caixa(SUPERFICIE, BORDA, 1, 6, 0))

	t.set_stylebox("background", "ProgressBar", caixa(FUNDO, BORDA, 1, 3, 0))
	t.set_stylebox("fill", "ProgressBar", caixa(ACENTO, Color.TRANSPARENT, 0, 3, 0))
	t.set_color("font_color", "ProgressBar", TEXTO)
	return t
