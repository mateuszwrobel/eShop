# Architecture audit findings — eShop

Audit of the full solution with [archspec](https://github.com/mateuszwrobel/archspec) 0.6.69.
Spec: [`architecture.spec.toml`](../../architecture.spec.toml) · machine-readable verdict: [`report.md`](report.md) · timings: [`performance.md`](performance.md).

## Verdict

`verify --strict` is **green**: the code matches the declared contract, all 27
namespaces/projects belong to a boundary (territory 27/27), and the inversion
ledger is clean. "Clean" here means *code ≡ contract* — the findings below are
the real observations that came out of building the contract against the tree.

## Findings

### F1 — Namespace-tier cycle: Ordering.API → Ordering.Domain → Ordering.API (recorded debt)

Files in `tests/Ordering.UnitTests` declare the **bare** `namespace eShop.Ordering`
instead of `eShop.Ordering.UnitTests` while importing `Ordering.API` types.
Because that bare namespace is owned by the `Ordering.Domain` boundary, the test
helpers create an `Ordering.Domain → Ordering.API` edge on top of the legitimate
`Ordering.API → Ordering.Domain` one — a cycle at the namespace tier (module-tier
graph stays acyclic).

Recorded in the sanctioned cycle ledger ([`architecture.spec.toml`](../../architecture.spec.toml),
`[[exempt]]`), so the census reports `exempt: 1, violating: 0` — it never silently
drops to zero.

**Fix:** re-home those helper files under `eShop.Ordering.UnitTests` and delete
the `[[exempt]]` entry. `archspec explain Ordering.API Ordering.Domain` shows the
evidence chain.

### F2 — Test projects participate as production units

All five `*.UnitTests` projects (`Application`, `Basket`, `ClientApp`,
`Ordering`, `eShop.AppHost`) are classified `is_test = false` by the driver: eShop
adopts `MSTest.Sdk` / Microsoft.Testing.Platform, which archspec's test detector
does not recognize as test markers yet. Consequences:

- test-only edges are declared in `depend_on` like any other (the F1 cycle lands
  in the production census), and
- a test project adding an undeclared reference will fail `verify --strict` —
  stricter than upstream default, kept deliberately.

### F3 — Exact-set dependency contract (strict by design)

Every `allowed.depend_on` is a ceiling **and** a floor: 51 internal edges are all
declared, and removing one from code fails `verify --strict` as loudly as adding
one without declaring it. 72 external (NuGet/BCL) edges are censused. This is the
tightest posture archspec supports; drift in either direction breaks CI.

### F4 — Repository tooling notes (not architecture debt)

- Root `package.json` (Playwright) hijacks driver auto-detection for
  `update`/`depgraph`/`inspect` → those verbs run against `src/` in
  `build/archspec/audit.sh`. Upstream: archspec#38.
- The NuGet package's `build/archspec.props` uses a bare `<Error>` element that
  MSBuild 18 (.NET 10 SDK) refuses, so the tools project consumes it with
  `ExcludeAssets="build"` and mirrors the RID selection. Upstream: archspec#37.
- 20 TypeScript/JavaScript files (Playwright specs, static assets) are declared
  out of scope via `excluded_sources` — the spec pins `language = "csharp"`.

## Non-findings (checked, nothing found)

- inversion ledger: no used-but-undeclared, no declared-but-unused pairs ([`depgraph-ledger.md`](depgraph-ledger.md))
- module-tier graph: acyclic ([`depgraph-modules.mmd`](depgraph-modules.mmd))
- territory: no orphan namespaces or components
- module API surface: see [`api-usage.md`](api-usage.md)

## Regenerating

```bash
./build/archspec/audit.sh          # regenerate every artifact + timings
git add docs/archspec && git commit
```
