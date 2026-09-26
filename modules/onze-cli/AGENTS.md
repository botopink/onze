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
| `src/main.bp` | `run(cwd, args, version) -> Outcome`, `main()` — `node out/main.js <command> …` after `botopink build` |

`dev`, `build` and `start` answer "not available yet": `build` waits on the release member's
build id (front 71) to be wired, `dev` and `start` on rakun's server boot (rakun fronts 04, 23).

Tests (`test/`, commonJS): `scan_test` (scan + resolve), `generate_test` (the check, the staged
tree, and a round trip that runs `botopink check` over it — the binary is found by walking up to
`repository/botopink-lang/zig-out/bin/botopink`), `create_test` (flags, help, the refusal, the
scaffold passing `botopink check`, `examples/scaffold` equal to a fresh `create`, `info`, the
dispatch).
