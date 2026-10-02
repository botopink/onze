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
│   │                    reads), scan.bp, graph.bp (an edge per `from "<alias>…"`, per
│   │                    `mod` line, per item naming an app module by its path inside the
│   │                    braces — `lib.db.Post`, decision 206 — and per shorthand sibling),
│   │                    refusal.bp (+ the styleMap probe and
│   │                    `styleParity`), chunk.bp, entry.bp (starters through jhonstart's
│   │                    `registerStarter`, the payload `s` check; components imported by
│   │                    their path inside the braces),
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
├── scripts/git-hooks/ ← pre-commit (lib/runner-standalone.sh — one text in the five library
│                        repositories): a staged *.snap.new or conflict marker, the compiler
│                        (absent → the gate fails, never skips), `botopink test` in every
│                        workspace member — `modules/*` and `examples/*` — on every target its
│                        manifest declares (manifestTargets: the member's `targets`, else the
│                        workspace's), `botopink build` of every example on every declared
│                        target (runExamplesGate — no allow list)
└── .github/workflows/ ← test.yml ({ubuntu-24.04, macos-14} × {commonJS, erlang}, every row
                         hard, OTP 28 and Node 20 on every row; one `botopink-lib-test
                         --strict` per row, the members and examples discovered from the root
                         via BOTOPINK_LIB_ROOTS; the sibling libraries checked out as
                         dependencies; then the hook's other stages on the row's target),
                         tag.yml
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

`git config core.hooksPath scripts/git-hooks` once per clone. `scripts/git-hooks/pre-commit`
sources `scripts/git-hooks/lib/runner-standalone.sh`; the gate's stages, in order — each one a
refusal (decision 67: fail beats warn), none with a flag, variable or list that turns it off:

1. **staged files** — no `*.snap.new` / `*.snap.md.new` (both are in `.gitignore`; the hook
   catches a `git add -f`) and no conflict marker;
2. **the compiler** — `$BOTOPINK_BIN` when it is set (a value that is not an executable is a
   refusal, never a reason to pick another compiler), else the enclosing checkout's
   `repository/botopink-lang/zig-out/bin/botopink` (the walk stops at the first ancestor that
   holds `repository/botopink-lang/`), else a botopink-lang checkout's own `zig-out`, else
   `$PATH`. None → the gate fails, naming `zig build install` and `BOTOPINK_BIN`. The path is
   exported as `BOTOPINK_BIN`: `onze-cli`'s fixture suites compile with the compiler that runs
   them;
3. **repository stages** — `scripts/git-hooks/repository-stages.sh`, when a repository tracks
   one. onze has none;
4. **tests** — `botopink test --target <t>` in every workspace member (every directory the root
   manifest's `workspaces` patterns expand to: the eight `modules/*` and `examples/{blog,scaffold}`)
   on every target its manifest declares — 19 cells: nine members on both rows, `onze-server` on
   erlang. A member with no `test` block (`scaffold`) is still compiled;
5. **examples** — `botopink build --target <t>` of every `examples/*/` on every declared target,
   into a throwaway `--out`: 4 builds;
6. **refusals** — every `refusals/*/` case, when the directory exists. onze has none.

Stages 1–3 stop the gate at the first red. Stages 4–6 all run: every red cell is listed with the
tail of its output and a re-run line, and the gate fails at the end — one run tells every red.
Measured 2026-10-02 with the compiler built from botopink-lang `29cfffc8`: 17 of 19 cells green, 4/4
builds, exit 1 — the two reds are `onze-cli` on both targets (`test/start_test.bp:120` on both,
`test/start_test.bp:103` and `test/build_test.bp:63` on erlang — `06-onze` and the compiler rows
the front README names), listed by the one run with every other cell's verdict. Never commit
with `--no-verify`; fix the red instead.

`pre-commit` and `lib/runner-standalone.sh` are one text in the five library repositories
(emilia, erika, jhonstart, onze, rakun): the meta repository's `hook-integrity` workflow compares
the bytes (its check 4), so a change to either lands in all five together. What only one
repository checks lives in that repository's `scripts/git-hooks/repository-stages.sh`, which the
runner runs in a child process — it can add a red, it cannot remove or skip a shared stage.

The same cells, discovered by the runner from the workspace root, are CI's:
`cd $(mktemp -d) && BOTOPINK_LIB_ROOTS=<this repository> botopink-lib-test --bin "$BOTOPINK_BIN"
--target <t> --strict`, on `{ubuntu-24.04, macos-14} × {commonJS, erlang}` — every row hard, no
windows row (gate-f: botopink-lang has none; it returns with the compiler's), `ubuntu-24.04`
because the compiler links against a pinned glibc 2.38 and imports `arc4random_buf`
(GLIBC_2.36), which ubuntu-22.04's glibc 2.35 cannot load. OTP 28 and Node 20 are installed on
every row (`zig build install` runs `erlc`; the cli suites drive `node`); jhonstart, emilia and
rakun are checked out under `botopink-lang/repository/` as the `path` dependencies the manifests
declare — dependencies, never rows.

A `targets` restriction is audited by building the member on the excluded target: `onze-server`'s
commonJS build fails on rakun's host bindings, so its `["erlang"]` stands; `onze-cli` (erlang) and
`onze-og` (commonJS) built, so their lines were deleted and both run on both rows.
