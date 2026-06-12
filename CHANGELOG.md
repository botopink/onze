# onze · CHANGELOG

## Unreleased

- Promoted from workspace subdir to standalone repository under
  `botopink/onze`. Tracked from `botopink/projects` as a git submodule on the
  `feat` branch.

## 0.0.1 — v0.beta.8

- Initial release: Mockito-style mocking + verification.
- Runtime (`onze.mjs`) — call log + stub table, the one mutable seam.
- `#[mock]` decorator synthesis (comptime `@Decl` reflection).
- Matchers: `eq`, `anyInt`, `anyString`, …
- Verification: `times`, `never`, `atLeastOnce`.
