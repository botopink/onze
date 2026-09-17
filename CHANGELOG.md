# onze · CHANGELOG

## Unreleased

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
