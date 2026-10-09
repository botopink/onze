# onze-content

> Path: `repository/onze/modules/onze-content/` · Parent: [`../../AGENTS.md`](../../AGENTS.md)
> Spec: `specs/1.0.12-beta/08-bpp/121-bpp-content/README.md` in the meta repository

Markdown for onze, commonJS and erlang: CommonMark 0.31.2 and the GitHub-flavoured extensions
(tables, strikethrough, task list items, extended autolinks, footnotes, the tag filter) parsed to
an `MdNode` tree, written as HTML or built as jhonstart's `Element`. Steps 1–2 of front 121;
frontmatter (`frontmatter.bp`, step 3 — waits on the `08-f` decision), collections
(`collections.bp`) and feeds (`feeds.bp`) arrive with the later steps. Depends on jhonstart
(`Element`, `el`, `voidEl`, `fragment`, `text`, `raw`) and std; nothing in onze imports it yet.

| File | What |
|---|---|
| `src/markdown.bp` | The public surface — `MarkdownOptions` (`smartPunctuation`, `gfm`, `headingIds`, all on by default), `commonmarkOptions()`, `gfmOptions()`, `MdNode`, `MdDoc`, `Footnote`, `Heading`; `parse` / `parseWith`, `toHtml` (the reference renderer's HTML, cmark-gfm's for the extensions), `toElement` (raw HTML through `raw(…)`; a table cell's alignment as `style="text-align:…"`), `headings`, `plainText`. Inside: the block parser (commonmark.js's line-by-line container walk over a stack of open blocks, `P` the state), the definitions pass (link references, footnote definitions), the inline parser (`IP`: pending items, the delimiter and bracket stacks of § 6.2–6.4), extended autolinks over finished text, GitHub's slug rule for heading ids |
| `src/md_text.bp` | `Chars` — a string's code points with constant-time reads (a JS array / an erlang tuple behind two host cells; `string.at` walks the whole value on erlang), character classes (Unicode punctuation through one host cell per row), `escapeHtml`, `matchEntity`, `unescapeString`, `normalizeLabel`, `normalizeUri` |
| `src/md_entities.bp` | `entityText(name)` — the 2 125 HTML5 named references ending in `;`, generated from <https://html.spec.whatwg.org/entities.json> |

The parser avoids four shapes the compiler mistranslates today (each marked `// LANGUAGE GAP` and
a row of the milestone's `language-gaps.md`): the record update form on a lambda parameter, a
`var` written in a statement `case` arm (erlang) or an arm ending in `for` (commonJS), a `var`
written in an `if` block that returns (erlang), and a `case` binder named like the `val` it
initialises (erlang).

Tests (`test/`, both rows): `commonmark/<section>_test.bp` — the 652 examples of
<https://spec.commonmark.org/0.31.2/spec.json>, one test per example named by its number
(`commonmark 042: …`), generated from that file, rendered with `commonmarkOptions()`;
`gfm_extensions_test.bp` — the 24 extension examples of cmark-gfm's `test/spec.txt` (GFM 0.29),
`gfmOptions()`; `gfm_footnotes_test.bp` — cmark-gfm's three footnote examples
(`test/extensions.txt`); `markdown_test.bp` — the default options, `toElement` rendered with
jhonstart's `renderNode`, `headings`, the tree; `budget_test.bp` — a 200 kB document parsed and
rendered within 2 000 ms (measured ~130 ms erlang, ~140 ms commonJS).
