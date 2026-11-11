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

### F2 — Test projects are modeled inconsistently: MSTest ones as production, xunit ones absent

None of the nine test projects is classified as a test. The two shapes differ
(archspec#39):

- the five `tests/*.UnitTests` projects (`Sdk="MSTest.Sdk"`) appear as **plain
  production units** — the driver's C# test markers (`xunit`, `nunit`,
  `Microsoft.NET.Test.Sdk`) miss the SDK-style `MSTest.Sdk` attribute, so their
  edges land in the production `depend_on` contract — this is what produces the
  F1 cycle in the production census; and
- the four `tests/*.FunctionalTests` projects (`xunit.v3.mtp-v2` marker) are
  **gated out of the model entirely** — no unit, no edges, no diagnostic line —
  despite sitting in `eShop.slnx`.

Consequence: a test project adding an undeclared reference fails
`verify --strict` for the MSTest ones (stricter than upstream default, kept
deliberately) while the FunctionalTests ones could drift silently until the
marker gap is fixed upstream.

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
