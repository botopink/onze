# onze · CHANGELOG

## Unreleased

- **The orchestrator's workspace (botopink front 95, decision 79).** The name `onze` passes
  from the archived mocking library (tag `mocking-lib-final`; its surface is std's
  `testing.mocks` and `testing.asserts`) to the orchestrator. `botopink.json` is a workspace
  (`targets ["commonJS", "erlang"]`, `workspaces ["modules/*", "examples/*"]`) with the seven
  members of `specs/1.0.10-beta/06-onze/modules.md`: `onze`, `onze-test`, `onze-cli`
  (`["commonJS"]`), `onze-bundler`, `onze-assets`, `onze-og` (`["erlang"]`), `onze-release` —
  each a `botopink.json` with `files ["root.bp"]` and a `src/root.bp` with an empty `pub`
  surface and one inline test, 1/1 on every row it declares. The in-workspace edges of the
  graph are declared (`{ "workspace": true }`); the edges to rakun, jhonstart and emilia come
  with the fronts that need them. `examples/` holds no member yet. The pre-commit hook and CI
  are jhonstart's, workspace-aware.
