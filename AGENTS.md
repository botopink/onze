# onze

> Path: `repository/onze/`
> Parent (workspace): [`../AGENTS.md`](../AGENTS.md) · Sibling (core): [`../botopink-lang/AGENTS.md`](../botopink-lang/AGENTS.md)
> Specs: `specs/1.0.10-beta/06-onze/` in the meta repository (`modules.md` is the cut)

The **Next.js-style orchestrator**: the one package that imports rakun, jhonstart, the
`jhonstart-emilia` bridge and emilia together (decision 113) — neither rakun nor jhonstart names
onze, and every value that crosses between them is handed across by `Onze.run`. Pure `.bp`
client, zero compiler-core surface, reached via `from "onze"`.

The workspace and its seven members exist (front 95); the core (front 49) and the core helpers of
`onze-test` are written, the other members still hold their skeleton `root.bp`. The name came from the old mocking library, archived
under the tag `mocking-lib-final` (decision 79); nothing of it is here, and its surface is std's
`testing.mocks` / `testing.asserts`.

## Tree

```text
onze/
├── AGENTS.md          ← you are here
├── README.md
├── CHANGELOG.md
├── botopink.json      ← WORKSPACE: name onze · targets [commonJS, erlang] ·
│                        workspaces [modules/*, examples/*]. Nothing is importable from it;
│                        `botopink build/test` here is a refusal naming the members
├── modules/           ← each: botopink.json (name, entry root.bp, files [root.bp]) + src/root.bp
│   ├── onze/          ← CORE (front 49) — `from "onze"`: config.bp (OnzeConfig, onze.json,
│   │                    the ONZE_PUBLIC_ rule), types.bp (AliasMap, OnzeProject, AppFile),
│   │                    integration.bp (the boot adapter — the one file that imports
│   │                    jhonstart and the jhonstart-emilia bridge). config/types tests import
│   │                    only std; integration_test.bp renders through the bridge
│   ├── onze-test/     ← the `<lib>-test` member: core.bp (assertConfig, assertAppFiles,
│   │                    assertAlias, assertPublicEnv), fixtures.bp (fixtureTree); the E2E
│   │                    runner arrives with 53. Depends on onze. Re-exports nothing from std
│   ├── onze-cli/      ← front 50 — targets ["commonJS"]; depends on onze
│   ├── onze-bundler/  ← front 68 — depends on onze
│   ├── onze-assets/   ← fronts 69 (owns root.bp + botopink.json) · 51 · 52 — depends on onze,
│   │                    onze-bundler
│   ├── onze-og/       ← front 70 — targets ["erlang"]; depends on onze, onze-assets
│   └── onze-release/  ← front 71 — depends on onze, onze-bundler, onze-assets
├── docs.md            ← the reference: onze.json, the alias map, the four seams, the not-built table
├── examples/          ← blog/ (53: src/lib/db.bp — the post store —, content/posts/*.md,
│                        test/{db,tags}_test.bp); scaffold (50) and static-site (71) arrive
│                        with their fronts, each a member with its own botopink.json
├── scripts/git-hooks/ ← pre-commit: conflict markers, `botopink test` per `modules/*`
│                        member, `botopink build` per example
└── .github/workflows/ ← test.yml (`zig build test-libs -- --lib onze`), tag.yml
```

## Rules

- A member depends on a sibling with `{ "workspace": true }` only; on another library's core by
  `path` (`{ "rakun": { "path": "../../../rakun/modules/rakun" } }`) — added by the front whose
  code needs the edge, never ahead of it. The compiler follows no dependency's own
  `dependencies` and loads the map in the order written, so a member that depends on `onze`
  lists `jhonstart`, `jhonstart-link`, `jhonstart-forms`, `emilia`, `jhonstart-emilia` first, in
  that order (a dependency before whatever depends on it).
- Importing a record type from another package also imports nothing its fields or methods name:
  `integration.bp` imports `RenderPlugin`, `RequestData`, `ErrorInfo`, `LayoutProps`,
  `PageContext`, `OpenGraph`, `TwitterCard` and `Icons` only so `App`, `PageInput` and `UiSegment`
  type. A `pub val` imported from a sibling module is `undefined` on commonJS and does not compile
  on erlang — constants are `pub fn`. `xs.at(i).unwrapOr(d)` inside a record method is not
  lowered — call a free function from the method. A bundled package (`std`, `routing`, `actions`,
  `validation`) is never listed.
- A member may only **restrict** the workspace's `targets`: `onze-cli` is commonJS, `onze-og`
  erlang, the rest inherit both.
- The front that adds a module appends its `pub mod` line and its `files` entry in its own commit
  (`06-onze/modules.md` § Front → submodule ownership names the owner of each `root.bp`).
- Any code or layout change updates this file in the same commit.

## Local gate

`git config core.hooksPath scripts/git-hooks` once per clone. The hook runs `botopink test` in
every `modules/*` member on its manifest target and builds every example.
