# onze

> The Next.js-style orchestrator for botopink: the one package that knows rakun (the server),
> jhonstart (the UI) and emilia (the styles) together, and wires them into an application.

**Status: skeleton.** The workspace and its seven members exist with an empty `pub` surface and
one inline test each; the code lands with the track-E fronts of 1.0.10-beta (49 first).

This repository took the name `onze` from the old mocking library (decision 79 of 1.0.10-beta):
that library is archived under the tag `mocking-lib-final`, and its surface is std's
`testing.mocks` and `testing.asserts` (`import {testing: {mocks, asserts}} from "std"`).

## Layout

`botopink.json` is a **workspace** (`"workspaces": ["modules/*", "examples/*"]`, decision 75): it
compiles nothing and ships nothing. Each member is reached by its manifest name:

| Member | `from` | Target | Front |
|---|---|---|---|
| [`modules/onze/`](modules/onze/) | `"onze"` — config, project vocabulary, alias map, env rule, boot adapter | both | 49 |
| [`modules/onze-test/`](modules/onze-test/) | `"onze-test"` — `assert<Subject>(loc, …)` helpers, fixtures, the E2E runner | both | 49 + each front |
| [`modules/onze-cli/`](modules/onze-cli/) | `"onze-cli"` — `create · dev · build · start · info` | commonJS | 50 |
| [`modules/onze-bundler/`](modules/onze-bundler/) | `"onze-bundler"` — client graph, refusals, chunks, manifest, hydration entry | both | 68 |
| [`modules/onze-assets/`](modules/onze-assets/) | `"onze-assets"` — CSS modules, stylesheet, `public/`, `Image`, fonts | both | 69 · 51 · 52 |
| [`modules/onze-og/`](modules/onze-og/) | `"onze-og"` — `ImageResponse` | erlang | 70 |
| [`modules/onze-release/`](modules/onze-release/) | `"onze-release"` — build id, OTP release, Dockerfile, static export | both | 71 |

`botopink test` runs inside a member, never at the root. The cut and the dependency graph are
`specs/1.0.10-beta/06-onze/modules.md` in the botopink meta repository.
