# onze-content

> Path: `repository/onze/modules/onze-content/` · Parent: [`../../AGENTS.md`](../../AGENTS.md)
> Spec: `specs/1.0.12-beta/08-bpp/121-bpp-content/README.md` in the meta repository

Markdown for onze, commonJS and erlang: CommonMark 0.31.2 and the GitHub-flavoured extensions
(tables, strikethrough, task list items, extended autolinks, footnotes, the tag filter) parsed to
an `MdNode` tree, written as HTML or built as jhonstart's `Element`; content collections and an
RSS feed. Steps 1–2, 4–5 of front 121; frontmatter (`frontmatter.bp`, step 3 — waits on the `08-f`
decision) arrives later, and until then a `.md` entry under `glob` is a sync problem naming the
step. Depends on jhonstart (`Element`, `el`, `voidEl`, `fragment`, `text`, `raw`), std and the
bundled `validation` (`Schema<T>`, `Violation`; never listed in `dependencies` — after front 138
moves it out of the compiler it becomes `"validation": { "git":
"https://github.com/botopink/validation.git", "branch": "feat" }`); nothing in onze imports it yet.

| File | What |
|---|---|
| `src/markdown.bp` | The public surface — `MarkdownOptions` (`smartPunctuation`, `gfm`, `headingIds`, all on by default), `commonmarkOptions()`, `gfmOptions()`, `MdNode`, `MdDoc`, `Footnote`, `Heading`; `parse` / `parseWith`, `toHtml` (the reference renderer's HTML, cmark-gfm's for the extensions), `toElement` (raw HTML through `raw(…)`; a table cell's alignment as `style="text-align:…"`), `headings`, `plainText`. Inside: the block parser (commonmark.js's line-by-line container walk over a stack of open blocks, `P` the state), the definitions pass (link references, footnote definitions), the inline parser (`IP`: pending items, the delimiter and bracket stacks of § 6.2–6.4), extended autolinks over finished text, GitHub's slug rule for heading ids |
| `src/md_text.bp` | `Chars` — a string's code points with constant-time reads (a JS array / an erlang tuple behind two host cells; `string.at` walks the whole value on erlang), character classes (Unicode punctuation through one host cell per row), `escapeHtml`, `matchEntity`, `unescapeString`, `normalizeLabel`, `normalizeUri` |
| `src/collections.bp` | Content collections. `RawEntry(id, data: Json, body, filePath)`; `Loader = fn() -> @Task<@Result<Array<RawEntry>, string>>` — `glob(base, pattern)` (one `.json` object per file, id = the path under `base` without its extension, each segment slugged by `markdown.slug`, a `slug` member overrides; a `.md` file is refused until step 3), `file(path)` (an array of objects, each with a unique non-empty `id`, taken out of the data), or the application's own function. `Collection<T>(name, loader, schema: Schema<T>, references)` from `defineCollection`, `.reference(field, collection)` (the `// LANGUAGE GAP` form of `#[reference]`), `.erased() -> AnyCollection` (the schema kept as `check`). Readers: `getCollection`, `getCollectionWhere`, `getEntry` (`?Entry<T>`), `render(entry) -> Rendered(content: Element, headings)`; a read that meets an unreadable collection or an entry that does not decode panics naming it. The sync: `syncProblems(collections)` (every violation as `<file>: <path>: <message>`, a repeated id, a collection defined twice, a reference to a missing entry or an unsynced collection, a loader's own error), `writeStore(collections, outDir)` (refuses with every problem, else writes `<outDir>/content/<name>.json` — the data as the file wrote it); `useStore(outDir)` / `useFiles()` choose what `getCollection` reads (the process variable `ONZE_CONTENT_STORE`), `storeFile(outDir, name)` |
| `src/feeds.bp` | `RssFeed(title, description, site, items)`, `RssItem(title, link, description: ?string, pubDate: ?i64)`, `rssFeed(feed)` — RSS 2.0, every text node through std's `escape.html`, a link rooted at `/` made absolute against `site` (also the item's `guid`), a date as RFC 822 in GMT (`rfc822(epochMillis)`) |
| `src/md_entities.bp` | `entityText(name)` — the 2 125 HTML5 named references ending in `;`, generated from <https://html.spec.whatwg.org/entities.json> |

Tests (`test/`, both rows): `commonmark/<section>_test.bp` — the 652 examples of
<https://spec.commonmark.org/0.31.2/spec.json>, one test per example named by its number
(`commonmark 042: …`), generated from that file, rendered with `commonmarkOptions()`;
`gfm_extensions_test.bp` — the 24 extension examples of cmark-gfm's `test/spec.txt` (GFM 0.29),
`gfmOptions()`; `gfm_footnotes_test.bp` — cmark-gfm's three footnote examples
(`test/extensions.txt`); `markdown_test.bp` — the default options, `toElement` rendered with
jhonstart's `renderNode`, `headings`, the tree; `budget_test.bp` — a 200 kB document parsed and
rendered within 2 000 ms (measured ~130 ms erlang, ~140 ms commonJS); `collections_test.bp` — the
loaders, the readers, the sync's problems, references and the store, over content trees each test
writes under `BOTOPINK_TEST_TMPDIR` (`#[schema]` records of the test's own); `feeds_test.bp` — the
whole document, escaping, the RFC 822 date.
