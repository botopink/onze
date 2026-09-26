# onze — the joint

onze is the full-stack orchestrator of the botopink ecosystem: the one package that imports
jhonstart (the UI), the `jhonstart-emilia` bridge, emilia (the styles) and rakun (the server)
together, and wires them into an application with an `app/` convention (decision 113). jhonstart
and rakun never import each other, emilia imports nobody, and neither jhonstart nor rakun names
onze: every value that crosses between them is handed across here.

**onze is opt-in.** Nothing in `libs/std`, the bundled libraries (`routing`, `actions`,
`validation`) or the compiler references it; a project that does not list it never loads it.

**Requirements.** OTP 28 or later for the server half (the release OTP the botopink CI runs;
the erlang backend's `json` and `maybe` usage needs it) — the replacement for Next's
"Node.js >= 20.9". Node 20 or later for the CLI and the client build (`onze-cli` is commonJS).

## What onze owns

Five things, and nothing that duplicates a rakun or jhonstart definition:

| Piece | Where | What |
|---|---|---|
| `OnzeConfig` | `modules/onze/src/config.bp` | the project configuration `onze.json` holds — `defaultConfig()`, `withPort` / `withDev`, `loadConfig(botopinkJson, onzeJson)` (an unknown key, a wrong kind or a port outside `1..65535` is an `Error` naming the key), `describeConfig` (the table `onze info` prints) |
| the import alias map | `modules/onze/src/types.bp` | `AliasMap`, `loadAliases(botopinkJson)` (a target that escapes the package root is refused at load, naming the entry), `resolveAlias(map, spec)` (longest prefix first, at a module boundary) |
| the routing-file vocabulary | `modules/onze/src/types.bp` | `OnzeProject`, `AppFile(authoredPath, segment, kind)`, `appFileKinds()`, `classifyAppFile(appDir, path)` |
| the environment rule | `modules/onze/src/config.bp` | `publicEnvPrefix()`, `isPublicEnvName`, `publicEnv` |
| the boot adapter | `modules/onze/src/integration.bp` | `bootSite`, `rakunEntries`, `responseOver`, `chainFor`, `pageInput`, `boot` |

### `onze.json`

| Key | Default | Meaning |
|---|---|---|
| `name` | `botopink.json`'s `name` | the project name |
| `port` | `3000` | the listener's port |
| `basePath` | `""` | passed to rakun's `App` unchanged — onze does not reimplement prefixing |
| `appDir` | `"app"` | written into rakun as `rakun.appDir`; `"src/app"` is the same mechanism with another string |
| `publicDir` | `"public"` | served verbatim at `/` |
| `outDir` | `".onze"` | the build output |
| `dev` | `false` | development mode |
| `actionsBodyLimit` | `1048576` | bytes; written into rakun as `rakun.actions.bodyLimit` (decision 117) |
| `allowedRedirects` | `[]` | absolute redirect targets jhonstart accepts; handed to `app(allowedRedirects: …)` |

### The import alias map

```json
{ "name": "blog", "alias": { "@/components": "components", "@/lib": "lib" } }
```

`import {PostCard} from "@/components.post_card";` resolves to `components.post_card`. The
mechanism is textual and build-time: `onze-cli`'s scan rewrites the prefix before the compiler
sees the import. **The compiler does not know aliases exist**, so an alias is visible through
`onze dev` / `onze build` only — a bare `botopink check` on the source tree does not resolve it.

## The four seams

### Seam 1 — the `app/` tree reaches rakun's route table

Not at comptime: `@Decl` carries no source location, so a decorator cannot learn which file it
annotates. The answer is an explicit argument — `#[page("blog/[slug]")]`, `#[layout("blog")]`
(jhonstart front 30), `#[getRoute("api/posts")]` (rakun front 25) — where the argument is the
app-relative directory and the segment grammar is the bundled `routing`'s. `onze-cli` generates
the `pub mod` lines from the tree and **fails the scan when a file's location and its decorator
argument disagree**. `AppFile.segment` is the value it compares:

| File | `segment` | `kind` |
|---|---|---|
| `app/page.bp` | `""` | `page` |
| `app/blog/[slug]/page.bp` | `blog/[slug]` | `page` |
| `app/(marketing)/about/page.bp` | `(marketing)/about` — the group is in the segment, absent from the route pattern | `page` |
| `app/api/posts/route.bp` | `api/posts` | `route` |
| `app/_components/card.bp` | — a `_private` folder opts out with everything below it | not an app file |

The eight kinds are exactly `page`, `layout`, `template`, `default`, `loading`, `error`,
`not-found` and `route`.

### Seam 2 — a matched route becomes HTML, and the HTML reaches the wire

rakun serves and jhonstart renders; the boot hands each what it needs from the other:

- **to jhonstart**, `bootSite(config, hooks)`: `app(plugins: [emiliaPlugin()], allowedRedirects:
  config.allowedRedirects)`, the two tag fields of `RenderHooks` (`headExtra` / `bodyExtra`, filled
  from `onze-bundler`'s script tags) installed with `setHooks`, and the action wire names installed
  with `setWireNames`;
- **to rakun**, `rakunEntries(config, i18nExclude)`: `rakun.appDir`, `rakun.actions.field`
  (`__bp_action`), `rakun.actions.header` (`X-Bp-Action`), `rakun.actions.bodyLimit` and
  `rakun.i18n.exclude` with `/_onze` appended once — every key rakun reads is a `rakun.*` key
  (decision 115), and neither library spells an action wire name (decision 114);
- **per request**, the renderer onze registers for a page pattern builds the `PageInput` with
  `pageInput(…)` — the segment chain is `chainFor(patterns)`, one `UiSegment` per ancestor pattern
  rakun's layout chain names, each as jhonstart's UI registry holds it (`segmentFor`) — and wraps
  rakun's `ChunkWriter` in jhonstart's `Response` with `responseOver`, which maps `status` /
  `header` / `write` / `close` onto `setStatus` / `setHeader` / `write` / `close` one to one:

  ```bp
  // one PageRenderer per page pattern — rakun front 23's `page(pattern, render)`
  page(route, fn(req: Request, out: ChunkWriter) -> @Task<@Result<void, string>> {
      return site.renderStream(pageInput(…), requestData(req), responseOver(
          { c -> out.setStatus(c) }, { n, v -> out.setHeader(n, v) },
          { chunk -> out.write(chunk) }, { -> out.close() },
      ));
  });
  ```

  jhonstart never sees the `ChunkWriter`, and rakun never sees the `Response`.

**Navigation signals never reach onze.** A page, layout or template that calls jhonstart's
`notFound()` or `redirect(url)` is handled inside jhonstart's render (decision 117): before the
first chunk it answers 404 / 307 through the `Response` onze built, after it the late-signal
markup; it also checks the redirect target against the route table and `allowedRedirects`. onze
has no `case` on a signal, imports nothing from `routing`, and hands jhonstart no matcher.

The vocabulary — `PageContext`, `LayoutProps.children` — is jhonstart's; onze does not restate it.

### Seam 3 — emilia's classes reach the HTML

`emilia(tokens)` registers a rule and returns a class name; `flush()` serialises the sheet and
clears it. The moments it is flushed — once into the head after the shell, once per streamed
boundary inside that boundary's fill, nothing left at the end — are jhonstart's `RenderPlugin`
calls, and the `jhonstart-emilia` bridge adapts them (its `payload()` contributes the payload's
`s` key). **emilia's block is written by jhonstart's render through the bridge**; onze's whole part
is registering the bridge in `bootSite`. No onze file calls `flush()` and no onze file defines a
style sink.

Two project-level properties: on erlang the sheet is per BEAM process, so a per-request process
gives per-request style isolation for free; on the JS half there is one process, so **the client
bundle must never call `flush()`** — the `<style>` block is a server artifact, and `onze-bundler`
fails a build whose client graph reaches it.

### Seam 4 — the environment split (a security rule)

> An environment variable is inlinable into the client bundle **only** if its name begins with
> `ONZE_PUBLIC_`, compared case-sensitively. Any other `env.read` reached from a client module
> fails the build, naming the variable and the module that read it. There is no flag, config key
> or annotation that downgrades this to a warning.

`isPublicEnvName("ONZE_PUBLIC_API_URL")` is true; `DATABASE_URL`, `onze_public_x` and
`Onze_Public_Secret` are false — a case-insensitive match is how a secret named
`Onze_Public_Secret` would leak. `publicEnv(names)` drops every name the predicate rejects, so the
list the bundler inlines cannot hold a non-public value even when its caller passes one.

## The client bundle (`onze-bundler`, front 68)

`onze build` walks the client module graph textually (the compiler exposes no module-graph API):
every `import … ;` and `mod …;` line of every `.bp` file, an unreadable import failing the scan with
`file:line`. The roots are the `#[client]` modules the route modules reach on the server side; each
root's closure is the client graph, and every node keeps the chain from the root that pulled it in.

**The build refuses**, with no flag, config key or annotation that relaxes it, a client-graph module
that imports jhonstart's `serverOnly` (or `request` / `cookies` / `headers`), reads a non-`ONZE_PUBLIC_`
variable, reads a variable whose name is not a literal, calls `env.vars()` / `env.write` /
`env.clear`, calls `emilia(…)` with a token list that is not a literal (or a module-level `val` of
one), calls `flush()`, or writes a non-ASCII token list (the two targets' `contentHash` would
disagree). Every refusal of a build is printed, each with its chain:

```
refused: server-only module lib.db reached from client root components.status
  components.status > lib.format > lib.db
build failed: 1 refusal
```

**Chunks.** `shared` (every client module two or more routes reach, plus jhonstart's client
runtime), one `route:<pattern>` chunk per route that reaches a module of its own, and `entry` (the
generated hydration entry). Each is the `__onze_require` registry prelude plus one factory per
module, named `<base>.<contentHash>.js` and served from `/_onze/static/<buildId>/` — immutable, so
two builds of an unchanged tree give the same names and one changed byte changes exactly the
chunks containing it.

**The manifest**, `<outDir>/client-manifest.txt`, read back by the server on every render:

```
V|1|<buildId>
E|entry|/_onze/static/<buildId>/entry.<hash>.js|<hash>|<bytes>
S|shared|/_onze/static/<buildId>/shared.<hash>.js|<hash>|<bytes>
C|route:/blog/[slug]|/_onze/static/<buildId>/r1.<hash>.js|<hash>|<bytes>
H|script:analytics|/a.js|<hash>|<bytes>
R|/blog/[slug]|route:/blog/[slug]
Y|styles|/_onze/static/<buildId>/app.<hash>.css|<hash>|<bytes>
P|ONZE_PUBLIC_API_URL|https://api.example.com
```

A field escapes `%`, `|`, line feed and carriage return (`%25`, `%7C`, `%0A`, `%0D`) and is read
back with std's `percentDecode`. A line of an unknown kind is ignored; a `V` other than `1` is an
error. One parser, both targets.

**The script-tag order**, straddling jhonstart's render:

| # | What | Where | Owner |
|---|---|---|---|
| 1 | every `beforeInteractive` script (`H`), blocking | `<head>` | `headScriptTags` |
| 2 | the document's markup | `<body>` | jhonstart's render |
| 3 | the payload script, `window.__bp0 = …` | end of `<body>` | jhonstart's render, never onze |
| 4 | `shared`, `defer` | after the payload | `scriptTags` |
| 5 | the route chunk, `defer` | after `shared` | `scriptTags` |
| 6 | `entry`, `defer` | last | `scriptTags` |

`bundleRenderHooks(manifest)` wraps the two functions as jhonstart's `RenderHooks`; `bootSite`
installs them. `afterInteractive` and `lazyOnload` scripts are scheduled by the entry, `worker`
scripts started by it (a worker cannot declare `onLoad`).

**The entry** is generated botopink source: it sets the validation message source, registers
`globals().fill` and `globals().signal` (with `allowedRedirects`), registers one starter per
client component in `globalThis.__jhIslandStarters` (decoding the island's props into the
component's `#[clientProps]` record from its source), raises on an island or a hole present on one
side of the document/payload only, then calls `hydrate()`, `linkMount()` and
`formMount(actionHeader)`. It imports nothing from `routing` and nothing of rakun.

**Dev.** A body edit relinks only the chunks containing the module; an import edit re-walks the
graph; a refusal fails dev with the build's own report; the manifest is written before the push.

## What onze deliberately does not build

| Not built | Why it is not here |
|---|---|
| `reexports.bp` | A consumer writes `import {div, text} from "jhonstart";` because that is where `div` lives. A re-export layer buys one shorter import line for a second name for every symbol in three libraries |
| `PageProps` / `LayoutProps` / `Params` | jhonstart delivers `PageContext` and `LayoutProps`, and `params` is read with `ctxParam(route, name)`. A second vocabulary is a translation layer and a class of bugs |
| `registerPage` / `registerLayout` / `registerAction` | jhonstart's `#[page]` / `#[layout]` decorators fill jhonstart's UI registry, the boot copies it into rakun's table, rakun's `#[serverAction]` registers actions, and `onze-cli` generates the `pub mod` lines that make the decorated modules load |
| `renderDocument` | jhonstart owns the document and the moments the render plugin is called, because only the render knows whether the response is streaming |
| `ActionResponse<S>(state, success, message)` | rakun's `ActionResult` (the bundled `actions`' envelope) is the action envelope |
| `RouteSegmentConfig(dynamic, revalidate)` | rakun front 60's `SegmentConfig(dynamic, dynamicParams, revalidate, fetchCache)` |

## What is not wired yet

The rakun half of the boot is data and adapters today: rakun's `ChunkWriter` with `setStatus` /
`setHeader`, `PageRenderer` and `page(pattern, render)` (rakun front 23 step 1), the core on
`["erlang"]` (front 04), rakun-web's `registerStaticRoot` (front 82) and a way to apply the
`rakun.*` entries from a library do not exist yet, so `Onze.run(config)` — `Rakun.run(App(port,
basePath))` after the boot — lands with them.
