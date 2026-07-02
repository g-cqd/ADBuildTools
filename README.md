# ADBuildTools

The single source of truth for the g-cqd Swift family's lint/format discipline: three
dependency-free SwiftPM plugins, the canonical `.swift-format` configuration, the shared
git-hook templates, and the reusable CI workflow every sibling package calls.

## What it vends

| Piece | What it does |
|---|---|
| `format` (command plugin) | Formats the consuming package in place against the canonical `.swift-format`. |
| `lint` (command plugin) | Formatting gate + shipped-library discipline; exits non-zero on failure. |
| `LintBuild` (build-tool plugin) | Runs `swift format lint --strict` as a prebuild step. |
| `.swift-format` (root) | The canonical configuration; `scripts/sync-config.sh` copies it into a consumer, and the reusable CI fails on drift. |
| `githooks/` | `pre-commit` / `pre-push` templates that exec the [`project-hooks`](https://github.com/g-cqd/project-hooks) binary. |
| `.github/workflows/swift-quality.yml` | The reusable quality workflow (below). |
| `scripts/` | `sync-config.sh`, `check-manifest-settings.sh`, `check-tags.sh`. |

## Consuming the plugins

Consumers add ADBuildTools as a **dev-only** dependency behind their own `*_DEV` env var, so
downstream users never resolve it:

```swift
if Context.environment["ADF_DEV"] != nil {
    if let path = Context.environment["ADBUILDTOOLS_PATH"], !path.isEmpty {
        packageDependencies.append(.package(path: path))
    } else {
        packageDependencies.append(.package(url: "https://github.com/g-cqd/ADBuildTools.git", branch: "main"))
    }
}
```

Then per shipped target: `plugins: isDev ? [.plugin(name: "LintBuild", package: "ADBuildTools")] : []`,
and on demand: `ADF_DEV=1 swift package lint` / `swift package format`.

Per-repo policy lives in `.adbuildtools.json` (the `devEnv` name, banned constructs such as
`forceUnwrap` / `wallClock` / `untypedThrows`, and the shipped-target list the lint plugin holds to
a stricter standard).

## Reusable CI (`swift-quality.yml`)

Siblings call it with `uses: g-cqd/ADBuildTools/.github/workflows/swift-quality.yml@main`. Inputs
cover: `dev-env-var`, `container-image` / `macos-runner`, `enable-coverage`, `strict-tags`,
`requires-published-siblings` (gates resolution-dependent jobs on the `AD_SWIFT_SIBLINGS_PUBLISHED`
repo variable), `enable-sanitizers` + `sanitizers`, `enable-docs` + `docs-target`, `build-system`,
`system-packages` (Linux apt packages, e.g. `libsqlite3-dev`), and `fixtures-command` (a command run
before the build/test legs to materialize network-fetched fixtures).

## License

MIT — see [LICENSE](LICENSE).
