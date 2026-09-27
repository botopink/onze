# onze

> Path: `repository/onze/`
> Parent (workspace): [`../AGENTS.md`](../AGENTS.md) · Sibling (core): [`../botopink-lang/AGENTS.md`](../botopink-lang/AGENTS.md)
> Specs: `specs/1.0.10-beta/06-onze/` in the meta repository (`modules.md` is the cut)

The **Next.js-style orchestrator**: the one package that imports rakun, jhonstart, the
`jhonstart-emilia` bridge and emilia together (decision 113) — neither rakun nor jhonstart names
onze, and every value that crosses between them is handed across by `Onze.run`. Pure `.bp`
client, zero compiler-core surface, reached via `from "onze"`.

The workspace and its eight members exist (front 95, and `onze-server` — decision pending 49-e):
rakun is erlang-only (decision 117), so the rakun half of the boot lives in the erlang member
`onze-server` and the core stays on both rows. The name came from the old mocking library, archived
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
│   │                    parsePort, the ONZE_PUBLIC_ rule), types.bp (AliasMap, OnzeProject,
│   │                    AppFile), integration.bp (the jhonstart half of the boot — the one
│   │                    file that imports jhonstart and the jhonstart-emilia bridge: bootSite,
│   │                    siteRender, rakunEntries, responseOver, pageInput). config/types tests
│   │                    import only std; integration_test.bp renders through the bridge
│   ├── onze-server/   ← front 49's rakun half — targets ["erlang"] (49-e): server.bp —
│   │                    `Onze.run(config)` (reads <outDir>/build-id and the manifest, writes
│   │                    the rakun.* keys, copies jhonstart's UI table into rakun's with one
│   │                    PageRenderer per page, registers the fingerprinted static root,
│   │                    bootWeb, the page path, `Rakun.run(App(port, basePath))`),
│   │                    requestData, responseFor. Depends on rakun, rakun-app, rakun-web,
│   │                    jhonstart, onze, onze-bundler, onze-assets
│   ├── onze-test/     ← the `<lib>-test` member: core.bp (assertConfig, assertAppFiles,
│   │                    assertAlias, assertPublicEnv), fixtures.bp (fixtureTree); the E2E
│   │                    runner arrives with 53. Depends on onze. Re-exports nothing from std
│   ├── onze-cli/      ← front 50 — both rows: resolve.bp, scan.bp, generate.bp
│   │                    (the check, the staged tree under <outDir>/src/), create.bp,
│   │                    info.bp, build.bp (`onze build`: the staged server with its
│   │                    `onze_main` and onze-server, erlc into server/beam/, the styleMap
│   │                    evaluated on both backends), start.bp (`onze start`, the server's
│   │                    generated main), main.bp (dispatch; `node out/main.js <cmd>`); dev
│   │                    answers "not available yet". Depends on onze, onze-bundler,
│   │                    onze-assets, onze-release
│   ├── onze-bundler/  ← front 68: manifest.bp (both rows — the one parser the server
│   │                    reads), scan.bp, graph.bp, refusal.bp (+ the styleMap probe and
│   │                    `styleParity`), chunk.bp, entry.bp (starters through jhonstart's
│   │                    `registerStarter`, the payload `s` check),
│   │                    script.bp, rebuild.bp, hooks.bp (RenderHooks over the tags),
│   │                    fixture.bp (the frozen fixture app every suite reads) — depends
│   │                    on onze and jhonstart
│   ├── onze-assets/   ← fronts 69 (owns root.bp + botopink.json) · 51 · 52: style_module.bp,
│   │                    stylesheet.bp, assets.bp (the two static roots), preprocess.bp,
│   │                    head.bp (pageRenderHooks), font_metrics.bp (the committed
│   │                    table — transcribed, generator owed), font.bp (googleFont over
│   │                    a FontBuild seam, localFont, fallbackFace, fontHead), image.bp
│   │                    (Image, the allowlist), image_handler.bp (the encoder port, the
│   │                    /_onze/image outcome) — depends on onze-bundler and jhonstart
│   ├── onze-og/       ← front 70 — both rows: card_style.bp (the closed subset —
│   │                    `style` is taken by jhonstart's element), metrics.bp (front 52's
│   │                    sidecars), layout.bp, svg.bp, raster.bp (the port; NIF
│   │                    declared, never shipped), response.bp — depends on jhonstart (it
│   │                    parses the sidecar text itself, so no onze-assets edge)
│   └── onze-release/  ← front 71: spec.bp (ReleaseSpec, the build id), otp.bp (.rel,
│                        sys.config, vm.args, bin/onze, systools), docker.bp, package.bp
│                        (manifest completeness, the secret scan), lifecycle.bp (readiness,
│                        the shutdown order over a Lifecycle record), static_export.bp —
│                        depends on onze and onze-bundler
├── .gitignore         ← out/, .botopinkbuild/, .onze/ (a build's output); *.snap.new and
│                        *.snap.md.new (a snapshot mismatch's scratch file — the hook refuses
│                        one that is staged)
├── docs.md            ← the reference: onze.json, the alias map, the four seams, the not-built table
├── examples/          ← blog/ (53: src/lib/db.bp — the post store —, content/posts/*.md,
│                        src/components/{nav,post_card}.bp, src/app/ — layout, page, blog/
│                        layout + page, blog/[slug]/page, (marketing)/about/page —,
│                        public/, test/{db,tags,render}_test.bp; [slug] and (marketing)
│                        compile only through `onze build`'s staged tree, and are served
│                        by `onze start` in onze-cli's start_test); scaffold/ (50: the
│                        committed output of `onze create scaffold --yes --libs ../../..`,
│                        diffed by create_test.bp); static-site (71) arrives with its front
├── scripts/git-hooks/ ← pre-commit (lib/runner-standalone.sh): conflict markers, a staged
│                        *.snap.new, the compiler (absent → the gate fails, never skips),
│                        `botopink test` per `modules/*` member on every target its manifest
│                        declares (manifestTargets: the member's `targets`, else the
│                        workspace's), `botopink build` per example on every declared target
│                        (runExamplesGate — no allow list)
└── .github/workflows/ ← test.yml (one `botopink-lib-test` per runner × workspace target, the
                         members and examples discovered from the root via BOTOPINK_LIB_ROOTS,
                         every row hard; the sibling libraries checked out as dependencies;
                         then runExamplesGate on the row's target), tag.yml
```

## Rules

- A member depends on a sibling with `{ "workspace": true }` only; on another library's member by
  `path` (`{ "rakun": { "path": "../../../rakun/modules/rakun" } }`) — added by the front whose
  code needs the edge, never ahead of it. A member lists exactly the packages its sources and
  tests import: dependencies load transitively (decision 143). A bundled package (`std`,
  `routing`, `actions`, `validation`) is never listed.
- A member may only **restrict** the workspace's `targets`, and only structurally (gate-d): the
  excluded target's `botopink build` must fail on a host binding (`has no #[@External.<Target>]`),
  never on a checker error, and a member that builds there runs there. Today one member
  restricts: `onze-server` is `["erlang"]` — its commonJS build fails on rakun's hosts (`rkReqLive`,
  `rkBeanStore`, … `have no #[@External] for the node backend`); the rest, `onze-cli` and `onze-og`
  included, run on both rows. Nothing on both rows imports rakun (every rakun manifest is
  `["erlang"]`, decision 117) — that is `onze-server`'s.
- One module cannot hold two types of one name: an `as` alias of an imported type still binds its
  declared name (`language-gaps.md`). `onze-server` constructs rakun's `App` and holds
  jhonstart's only as the core's `SiteRender` function value.
- The front that adds a module appends its `pub mod` line and its `files` entry in its own commit
  (`06-onze/modules.md` § Front → submodule ownership names the owner of each `root.bp`).
- An imported module's body — its `#[page]` / `#[layout]` registrations — runs before the
  importer's, on every backend (decision 140). The staged app's `onze_routes.bp` imports every
  decorated convention file, and the server's `onze_main.bp` imports `onze_routes`.
- A test writes only under `BOTOPINK_TEST_TMPDIR` (each suite's `testTmp()`); a build a test
  runs moves its `outDir` there, so nothing is written into the checkout.
- Any code or layout change updates this file in the same commit.

## Local gate

`git config core.hooksPath scripts/git-hooks` once per clone. The hook runs `botopink test` in
every `modules/*` member on every target its manifest declares and builds every example on
every target it declares; it fails when the compiler binary is not found (`BOTOPINK_BIN`, an
ancestor `zig-out/bin/botopink`, or `PATH`) and when a `*.snap.new` / `*.snap.md.new` is staged.
The same cells, discovered by the runner from the workspace root, are CI's:
`cd $(mktemp -d) && BOTOPINK_LIB_ROOTS=<this repository> botopink-lib-test --target <t>`.

A `targets` restriction is audited by building the member on the excluded target: `onze-server`'s
commonJS build fails on rakun's host bindings, so its `["erlang"]` stands; `onze-cli` (erlang) and
`onze-og` (commonJS) built, so their lines were deleted and both run on both rows.
