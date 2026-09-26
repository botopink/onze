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
- **Images (front 51).** `Image` (props validation, the source rules and the empty-by-default
  allowlist, `srcset` snapped to configured widths, fill, blur with `data-src`, the loading
  policy, refused sources reported), `imageResponse` (400 on a width or quality outside the
  config, the encoder under `timeout` with an argument vector, pass-through when it is missing,
  a content-hash cache key, immutable caching with an `ETag`). 7 tests on both rows, with
  stand-in encoder scripts.
- **Fonts (front 52).** `googleFont` / `googleFontWith` (self-hosted faces, the requested
  subsets, `.metrics.txt` sidecars, preload tags, the class and the variable), the adjusted
  fallback from a committed metrics table (Inter over Arial: 107.00 % / 96.88 % / 24.15 % /
  0.00 %), `localFont` (copied under its hash, refused outside the root or missing, the
  probe-absent degradation logged), `fontHead`. 7 tests on both rows over a fixture Google CSS.
- **`onze build` (front 50 step 7).** `modules/onze-cli/src/build.bp`: scan, check, the client
  graph's refusals, the CSS modules' generated accessors, the staged server package compiled for
  erlang, the staged client package plus the generated entry compiled for commonJS and linked by
  file (`onze-bundler`'s `link.bp`), the stylesheet, the build id, `static/<buildId>/`,
  `client-manifest.txt`, `build-id`. The scaffold builds (twice, to the same id) and its bundle
  boots under node. 23 CLI tests.
- **Release packaging (front 71).** `modules/onze-release/`: `ReleaseSpec`, `generateBuildId`
  (sorted, deterministic), `validateBuildId`, `verifyBuildId`; the `.rel`, `sys.config`,
  `vm.args` (the cookie from the environment) and `bin/onze` texts; `assembleRelease` over a real
  `systools:make_script` (tested against the local OTP); the two-stage non-root Dockerfile and
  `.dockerignore`; `packageAssets` (the manifest's promises, `public/` verbatim, `BUILD_ID`) and
  `scanForSecrets`; readiness and the ordered `shutdown` over a `Lifecycle` record; static
  export. 9 tests on both rows.
- **The CLI, first half (front 50).** `modules/onze-cli/`: `resolve` (root walk-up, config,
  aliases), `scan` (the app walk, routing's patterns, decorator arguments, the page+route,
  missing-decorator and staging-clash refusals), `generate` (the decorator/directory check, the
  staged tree under `<outDir>/src/` — renamed directories and stems, rewritten aliases, generated
  `mod.bp`s, `onze_routes.bp`, root, manifest — checked by `botopink check` in a test), `create`
  (the flag table from one defaults record, `--libs` path dependencies, the non-empty refusal;
  the scaffold passes `botopink check`), `info`, and the dispatch. 19 tests on commonJS.
  `examples/scaffold/` is the committed `create` output.
- **The styling pipeline (front 69).** `modules/onze-assets/`: CSS modules compiled to a
  generated accessor module with `<file>_<class>_<hash>` names (undefined uses reported,
  `</style` refused), the global stylesheet (global first, fingerprinted, its `Y` record read
  back by the bundler's parser), `stylesheetLinks` / `pageRenderHooks`, the two static roots
  for rakun-web front 82 (`AssetRoot`, exactly two), the preprocessor hook. 11 tests on both rows.
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
