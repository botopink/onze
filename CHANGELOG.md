# onze · CHANGELOG

## Unreleased

- **The core (front 49).** `modules/onze/`: `config.bp` — `OnzeConfig` (name, port, basePath,
  appDir, publicDir, outDir, dev, actionsBodyLimit, allowedRedirects), `defaultConfig()`,
  `withPort` / `withDev`, `loadConfig(botopinkJson, onzeJson)` refusing an unknown key, a wrong
  kind or an out-of-range port by name, `describeConfig`; the action wire names
  (`__bp_action` / `X-Bp-Action`) and the asset prefix `/_onze`; the `ONZE_PUBLIC_` rule
  (`publicEnvPrefix`, `isPublicEnvName`, `publicEnv`). `types.bp` — `AliasMap`, `loadAliases`
  (a target escaping the root refused at load), `resolveAlias` (longest prefix), `OnzeProject`,
  `AppFile`, the eight `appFileKinds()`, `classifyAppFile`. `integration.bp` — the boot
  adapter: `bootSite` (`app(plugins: [emiliaPlugin()], allowedRedirects)`, `setHooks`,
  `setWireNames`), `rakunEntries` (the five `rakun.*` keys), `responseOver`, `chainFor`,
  `pageInput`, `boot`. 21 tests on commonJS and on erlang. `docs.md` documents the four seams.
- **The client bundle (front 68).** `modules/onze-bundler/`: the manifest (`V/E/S/C/H/R/Y/P`,
  one parser on both targets, version-checked, unknown kinds ignored), `headScriptTags` /
  `scriptTags` and `bundleRenderHooks`; the textual import scanner and staged module ids; the
  client graph with chains; the refusals (server-only, request scope, the env table, emilia
  non-literal / flush / hash split — all reported, none relaxable); chunk planning, the
  `__onze_require` prelude, content-hashed names, `manifestOf`, `emitChunk`; the generated
  hydration entry (starters decoding `#[clientProps]`, the document/payload check, `hydrate`,
  `linkMount`, `formMount`, script scheduling) — compiled and run under node in a scratch
  package; `<Script>` strategies; the dev rebuild. 37 tests on commonJS and on erlang.
- **The blog's store (front 53 step 1).** `examples/blog/`: `botopink.json` (the `@/components`
  / `@/lib` aliases), `onze.json` (`appDir: "src/app"`), three seed posts under
  `content/posts/`, `src/lib/db.bp` (`listPosts` newest first, `readPost` naming a missing
  slug, `writePost` refusing a slug outside `[a-z0-9-]+`, `readCount`), and `test/db_test.bp`
  + `test/tags_test.bp` — 7 tests on both rows.
- **onze-test's core helpers (front 49).** `assertConfig`, `assertAppFiles`, `assertAlias`,
  `assertPublicEnv` over std's `snapshots.assertAs`, and `fixtureTree`. 7 tests on both rows.

- **The orchestrator's workspace (botopink front 95, decision 79).** The name `onze` passes
  from the archived mocking library (tag `mocking-lib-final`; its surface is std's
  `testing.mocks` and `testing.asserts`) to the orchestrator. `botopink.json` is a workspace
  (`targets ["commonJS", "erlang"]`, `workspaces ["modules/*", "examples/*"]`) with the seven
  members of `specs/1.0.10-beta/06-onze/modules.md`: `onze`, `onze-test`, `onze-cli`
  (`["commonJS"]`), `onze-bundler`, `onze-assets`, `onze-og` (`["erlang"]`), `onze-release` —
  each a `botopink.json` with `files ["root.bp"]` and a `src/root.bp` with an empty `pub`
  surface and one inline test, 1/1 on every row it declares. The in-workspace edges of the
  graph are declared (`{ "workspace": true }`); the edges to rakun, jhonstart and emilia come
  with the fronts that need them. `examples/` holds no member yet. The pre-commit hook and CI
  are jhonstart's, workspace-aware.
