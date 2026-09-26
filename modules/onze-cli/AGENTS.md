# onze-cli

> Path: `repository/onze/modules/onze-cli/` · Parent: [`../../AGENTS.md`](../../AGENTS.md)
> Spec: `specs/1.0.10-beta/06-onze/50-onze-cli/README.md` in the meta repository

The `onze` command line, commonJS only — it runs on a developer's machine before any BEAM node
exists. `compiler-cli`'s shape: `main.bp` dispatches, one module per command, pure option parsers,
no parser drops a token.

| File | What |
|---|---|
| `src/resolve.bp` | `Project`, `findRoot` (walk up to `botopink.json`), `resolveProject` (config + aliases, errors naming their file) |
| `src/scan.bp` | `RouteEntry`, `scanFiles` / `scanApp` (routing's `patternOf`, the decorator argument, the three refusals — authored paths only) |
| `src/generate.bp` | `checkTree`, `stagedPath`, `rewriteImports`, `modFiles`, `routesModule`, `stagedManifest`, `stage` — the staged tree under `<outDir>/src/` |
| `src/create.bp` | `CreateOpts`, `createDefaults` (the one defaults record), `createHelp`, `parseCreateOpts`, `scaffoldFiles(In)`, `writeScaffold`, `mkdirs` |
| `src/info.bp` | `infoText`, `dependencyVersions`, `versionAt`, `tools` |
| `src/build.bp` | `buildProject(project, bin)` — scan, check, the client graph's refusals, the style modules (generated into the staged tree as `styles.<file>`), the staged server package compiled for erlang into `<outDir>/server/`, the staged client package (+ the generated entry) compiled for commonJS, the file-level link, the stylesheet, the build id, `static/<buildId>/`, `client-manifest.txt`, `build-id`; `srcDirOf`, `workspaceMembers` (a `{ "workspace": true }` dependency becomes a path in the staged manifest) |
| `src/main.bp` | `run(cwd, args, version) -> Outcome`, `main()` — `node out/main.js <command> …` after `botopink build` |

`dev` and `start` answer "not available yet": they boot rakun's server (rakun fronts 04, 23).
`build` runs the compiler through `BOTOPINK_BIN` (or `botopink` on `PATH`). Route-level
splitting is not done: the generated entry imports every client component, so every island is in
`shared`; the server half is the `.erl` the compiler emits (no `erlc` pass yet); no prerender
(rakun front 60).

Tests (`test/`, commonJS): `scan_test` (scan + resolve), `generate_test` (the check, the staged
tree, and a round trip that runs `botopink check` over it — the binary is found by walking up to
`repository/botopink-lang/zig-out/bin/botopink`), `create_test` (flags, help, the refusal, the
scaffold passing `botopink check`, `examples/scaffold` equal to a fresh `create`, `info`, the
dispatch), `build_test` (the committed scaffold built twice to the same id — ~18 s a build —, a
refusal failing a build before anything compiles, a CSS module's accessors compiling).
