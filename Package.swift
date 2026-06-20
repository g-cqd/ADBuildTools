// swift-tools-version: 6.4
import PackageDescription

// ADBuildTools — the single source of truth for the g-cqd Swift family's lint/format discipline.
//
// It vends three dependency-free plugins that drive the toolchain's bundled `swift format`:
//   • `format`     (command)   — formats the package in place against the canonical `.swift-format`.
//   • `lint`       (command)   — formatting gate + shipped-library discipline; exits non-zero on failure.
//   • `LintBuild`  (buildTool) — runs `swift format lint --strict` as a prebuild step.
//
// Consumers add this as a dev-only dependency (gated behind their own `*_DEV` env var) and reference
// the plugins via `.plugin(name:package:)`, so the lint logic lives in exactly one place. The canonical
// `.swift-format` at this package's root is the authority; `scripts/sync-config.sh` copies it into a
// consumer and the reusable CI workflow fails on drift.
let package = Package(
    name: "ADBuildTools",
    products: [
        .plugin(name: "Format", targets: ["Format"]),
        .plugin(name: "Lint", targets: ["Lint"]),
        .plugin(name: "LintBuild", targets: ["LintBuild"])
    ],
    targets: [
        .plugin(
            name: "Format",
            capability: .command(
                intent: .custom(verb: "format", description: "Format Swift sources with swift-format"),
                permissions: [.writeToPackageDirectory(reason: "Format Swift sources with swift-format")])),
        .plugin(
            name: "Lint",
            capability: .command(
                intent: .custom(verb: "lint", description: "Check formatting and shipped-library discipline"))),
        .plugin(name: "LintBuild", capability: .buildTool())
    ]
)
