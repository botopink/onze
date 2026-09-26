# onze

[![CI](https://github.com/botopink/onze/actions/workflows/test.yml/badge.svg?branch=feat)](https://github.com/botopink/onze/actions/workflows/test.yml)

> **Archived — this library is retired.** Its last code commit is tagged `mocking-lib-final`.
> The mocking surface lives on in botopink's std as the `mocks` module
> (`libs/std/src/mocks.bp`, `import {mocks} from "std"`) and the assertion surface as the
> `asserts` module (`libs/std/src/asserts.bp`, `import {asserts} from "std"`) — both under
> `testing` once std's tree is regrouped (`import {testing: {mocks, asserts}} from "std"`).
> The name `onze` now belongs to the Next.js-style orchestrator (decision 79 of botopink
> 1.0.10-beta); the migration table is `specs/1.0.10-beta/01-std/onze-migration.md` in the
> botopink meta repository.

> Mockito-style mocking + verification library for botopink unit tests.

`onze` is botopink's test-double layer. Create a **mock** of a behavior,
**stub** what its methods return, run the code under test, then **verify**
the mock was called as you expect. Pure `.bp` client — the compiler core
knows nothing about it.

## Install

`onze` is an opt-in package. Inside a `.bp` source file:

```bp
import {mock, when, verify, eq, anyInt, times, never, atLeastOnce} from "onze";
```

The package is resolved by botopink's multi-root loader; no extra wiring is
required when this repo lives under a workspace that also has
`repository/botopink-lang/`.

## Quick example

```bp
behavior Greeter {
    fn hello(name: string) -> string;
}

test "greeter is greeted by name" {
    val g = mock(@type(Greeter));
    when(g.hello(eq("world"))).thenReturn("hi, world");

    assert g.hello("world") == "hi, world";
    verify(g.hello(eq("world")), times(1));
}
```

## Docs

- [AGENTS.md](AGENTS.md) — internals + the comptime synthesis / host-cell model.
- [docs.md](docs.md) — API reference (matchers, `when`/`verify` protocol,
  `#[mock]` decorator).
- `src/` — implementation (`onze.bp` + `onze.mjs` host runtime).
- `test/` — runnable unit tests.

## License

MIT — see [`LICENSE`](LICENSE). Same license as the rest of the botopink workspace.
