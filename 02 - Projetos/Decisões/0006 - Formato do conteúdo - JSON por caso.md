---
tags: [decisao]
projeto: "Datas_Mine!"
numero: "0006"
status: aceita
data: "2026-11-18"
area: tecnica
---

# 0006 — Formato do conteúdo: um JSON por caso + textos de interface em JSON

## Contexto
A [[Arquitetura]] (seção 8.1) pede conteúdo orientado a dados, com ids estáveis separados do texto exibido ([[0003 - Idioma do jogo - PT-BR]]). O formato deveria sair de um caso real, e agora o [[Caso 1 - A Merenda de Vila Serena]] existe e já foi jogado.

## Opções consideradas
1. **JSON** (um arquivo por caso): texto puro, fácil de diffar, editável em qualquer editor, carregado com `JSON.parse_string`.
2. **Resources do Godot (`.tres`)**: editáveis no inspetor do Godot, mas o formato é menos legível fora da engine e prende o conteúdo ao Godot.
3. **CSV/planilhas**: bom para tabelas, ruim para estruturas aninhadas (rede, portas, fatos).

## Decisão
**JSON, um arquivo por caso** em `game/conteudo/casos/<id>.json`, e os **textos de interface** em `game/conteudo/textos/*.json`, com placeholders `{nome}`.

Estrutura de um caso (chaves principais):
| Chave | Conteúdo |
|---|---|
| `id`, `titulo`, `jornalista`, `intro[]`, `memorando` | apresentação |
| `orcamento_ruido`, `custos{}`, `exposicao{}` | balanceamento (dados, não código) |
| `regras_editoriais[]`, `feedback` (`binario` \| `parcial`) | checklist do caso |
| `no_inicial`, `nos{id → host, publico, vizinhos[], portas[], acesso{}, arquivos[]}` | rede. `acesso.tipo`: `publico` \| `login` \| `pin` |
| `termos{id → rotulo, tipo}` | tudo o que pode ser coletado. A lógica compara **ids** |
| `documentos{id → arquivo, texto[], termos[], revela_nos[], inocentes[], nomes_prova[]}` | documentos e seus papéis |
| `fatos{id → frase, lacunas[], respostas{lacuna → termo_id}, iscas[], provas[]}` | dossiê |

**Validação:** `app/conteudo.gd` valida o caso ao carregar (referências quebradas, respostas que não aparecem em nenhum documento, provas inexistentes). Um teste automatizado roda a mesma validação.

## Consequências
- ✅ Editar o caso não exige código. O teste de conteúdo pega quebra-cabeças impossíveis.
- ✅ É fácil gerar casos novos com ajuda da IA, porque o formato é texto.
- ⚠️ Sem editor visual por enquanto. Se a produção de casos ficar lenta, considerar uma ferramenta (por exemplo, um plugin do Godot) mais tarde.
- ⚠️ Mudanças de formato exigem atualizar o validador e os testes junto.

## Revisar quando
No caso 2: se o formato não comportar a regra de confirmação (2 documentos) ou o feedback parcial sem gambiarra.
