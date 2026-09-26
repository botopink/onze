# onze examples

Every child of `examples/` holding a `botopink.json` is a member of the onze workspace and a row
of `zig build test-libs`; this directory holds none yet. The three planned projects
(`specs/1.0.10-beta/06-onze/modules.md` § `repository/onze/examples/**`):

| Example | Front | What it proves |
|---|---|---|
| `blog/` | 53 | the acceptance app — every route under `onze dev` and `onze build && onze start`, the client chunk, the stylesheet, the OG route, the release |
| `scaffold/` | 50 | the committed output of `onze create scaffold --yes` |
| `static-site/` | 71 · 60 | `output: export` — every route prerenderable |
