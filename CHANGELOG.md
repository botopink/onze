# onze · CHANGELOG

## Unreleased

- **The 1.0.3 surface** (botopink-lang front 12): `#[mock] behavior` replaces `#[mock] interface`,
  the synthesized double is `type MockXxx(__id: string) implement Xxx`, `OnzeStub` is a
  `type`, and the sources are `botopink format`ted. The mock synthesis reads
  `DeclKind.Behavior`; commonJS 8/8, example 4/4 and `can fulfil 3 widgets: true` as
  before. The erlang cell still stops on unqualified imported calls (C1).
- The host cells have an erlang form: every `onze*` external carries an
  `@External.Erlang` template mirroring `onze.mjs` (call log, stubs, matcher stack
  and verify mode in the process dictionary; the same verify message). The
  erlang test cell no longer stops at `MissingExternalTarget`; it still fails
  to compile on a compiler defect — calls to functions imported from the onze
  package are emitted unqualified (`'when'/1 undefined`) — so the CI row keeps
  `allow_fail`.

- The examples gate no longer aborts silently on a `scripts/known-broken-examples.txt`
  holding only comments or blank lines: the runner reads the list with `awk`, whose
  "no entry" is not a failure under `set -euo pipefail`.

- **MIT license.** `LICENSE` (`Copyright (c) 2026 Eric Fillipe and botopink
  contributors`) backs the README's License section, which now points at it.

- The gate builds the examples: after `botopink test`, the pre-commit hook
  and CI run `botopink build` in every `examples/*/` with a `botopink.json`;
  `scripts/known-broken-examples.txt` lists the ones allowed to fail, and a
  listed example that builds fails the gate.
- The pre-commit hook is self-contained: the dead delegation to a meta
  workspace runner is gone, and `AGENTS.md` documents the install
  (`git config core.hooksPath scripts/git-hooks`) instead of a
  `scripts/install-hooks.sh` that exists in no repository.
- Promoted from workspace subdir to standalone repository under
  `botopink/onze`. Tracked from `botopink/projects` as a git submodule on the
  `feat` branch.

## 0.0.1 — v0.beta.8

- Initial release: Mockito-style mocking + verification.
- Runtime (`onze.mjs`) — call log + stub table, the one mutable seam.
- `#[mock]` decorator synthesis (comptime `@Decl` reflection).
- Matchers: `eq`, `anyInt`, `anyString`, …
- Verification: `times`, `never`, `atLeastOnce`.
