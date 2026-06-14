# onze

[![CI](https://github.com/botopink/onze/actions/workflows/test.yml/badge.svg?branch=feat)](https://github.com/botopink/onze/actions/workflows/test.yml)

> Mockito-style mocking + verification library for botopink unit tests.

`onze` is botopink's test-double layer. Create a **mock** of an interface,
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
interface Greeter {
    fn hello(name: string) -> string
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

Same as the parent botopink workspace.
