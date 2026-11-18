---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0004"
status: aceita
data: "2026-11-18"
area: tecnica
---

# 0004 — Engine e linguagem: Godot 4.7 + GDScript (renderizador Compatibility)

## Contexto
A [[Arquitetura]] foi escrita independente da tecnologia, à espera desta decisão. O rascunho anterior ([[Plano técnico (rascunho)]]) propunha fazer o jogo **sem engine**, em TypeScript + Canvas. A inspeção do PC (`../Conhecimento/Setup do PC.md` no cérebro) mostrou:
- **8 GB de RAM** em um pente só (o gargalo);
- uma GPU **GT 630 Fermi**, que **não tem Vulkan** (OpenGL 4.x e DirectX 11);
- nenhuma engine instalada.

Depois de ver o que o PC suporta, o usuário escolheu o **Godot**.

## Opções consideradas
1. **Sem engine, TypeScript + Canvas:** muito leve e com controle total, mas tudo é feito à mão (UI, texto, layout, áudio, empacotamento).
2. **Godot 4.7 + GDScript:** engine leve, grátis, licença MIT. Já tem UI (nós `Control`), texto, temas, sinais, áudio e exportação para PC. A documentação offline 4.7 já está no computador. **Exige o renderizador Compatibility** (OpenGL 3.3), porque Forward+ e Mobile precisam de Vulkan.
3. **Godot 4.7 + C#:** linguagem mais conhecida no mercado, mas exige o .NET SDK e o editor .NET, pesa mais na RAM e a documentação oficial recomenda GDScript para começar.
4. **Godot 3.6:** roda em hardware ainda mais fraco, mas é a geração antiga, que só recebe manutenção.
5. **Unity / Unreal:** pesadas demais para este PC.

## Decisão
**Godot 4.7.x (estável) com GDScript e o renderizador Compatibility.** O jogo é 2D e feito de interface, então o renderizador Compatibility não limita nada do que o [[GDD]] pede.

A arquitetura em camadas continua valendo, adaptada ao Godot:
| Camada (arquitetura) | No Godot |
|---|---|
| **Núcleo de regras** (puro) | Scripts GDScript que estendem `RefCounted` ou `Resource`, **sem nós, sem `SceneTree`, sem `Input`**. Funções puras sobre o `Estado` |
| **Comandos e eventos** | `Comando` como dado (Dictionary/classe). Os eventos do núcleo são devolvidos como lista. A aplicação os repassa como **sinais** |
| **Aplicação** | Um *autoload* `Jogo` (executor de comandos, save, carregamento de conteúdo) + cenas principais |
| **Apresentação** | Cenas com nós `Control` (apps do desktop, terminal, quadro), `Theme`, `AudioStreamPlayer` |
| **Plataforma** | O próprio Godot (janela, input, áudio, disco via `user://`) |
| **Conteúdo** | JSON em `res://conteudo/` (formato exato na ADR 0005), carregado e validado na inicialização |
| **Testes** | **GUT** ou **gdUnit4** para o núcleo e os cenários (escolha no setup) |

## Consequências
- ✅ UI, texto com acentos, temas, áudio e exportação para Windows prontos. Sobra muito mais tempo para o conteúdo dos casos.
- ✅ GDScript é simples e bem documentado (a doc offline 4.7 já está em `C:\Users\werne\GameDevDocs\godot`). Cenas e scripts são **arquivos de texto** (`.tscn`, `.gd`), bons para git e para trabalhar com IA.
- ✅ Leve o bastante para 8 GB de RAM.
- ⚠️ **Renderizador Compatibility obrigatório** neste PC: shaders avançados e efeitos do Forward+ ficam de fora. Os efeitos CRT do GDD precisam ser feitos com shaders simples de `CanvasItem`.
- ⚠️ A separação entre núcleo e Godot é **disciplina**, não uma imposição da engine: o `/revisar` precisa conferir que o núcleo não usa nós.
- ❌ O [[Plano técnico (rascunho)]] (TypeScript + Canvas) é descartado.
- 🔄 A nota `Jogo sem engine` do cérebro continua como conhecimento geral, mas não vale para este projeto.

## Revisar quando
Se o renderizador Compatibility impedir algum efeito essencial, ou se o PC receber uma GPU com Vulkan (aí o Forward+ fica disponível sem mudar a arquitetura).
