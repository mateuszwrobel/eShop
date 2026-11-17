# Architecture audit findings — eShop (archspec 0.6.81 re-audit)

Second full audit of this solution, from scratch, against
[archspec](https://github.com/mateuszwrobel/archspec) **0.6.81**. The first audit
(0.6.69) is the baseline; the question here is as much "did the reported issues
get fixed" as "what does the architecture say". Spec:
[`architecture.spec.toml`](../../architecture.spec.toml) · verdict:
[`report.md`](report.md) · timings: [`performance.md`](performance.md).

## Verdict

`verify --strict` is **green with zero findings**: 22 boundaries (project +
namespace tier), **0 cycles, 0 exempt entries**, territory complete, inversion
ledger clean, and all nine test projects uniformly test-gated.

## Issue scoreboard (what the redo re-tested)

| issue | subject | status on 0.6.81 |
| --- | --- | --- |
| #37 | props `<Error>` breaks MSBuild 18 | **fixed** — props imports; follow-up archspec#42 filed (RID resolved at evaluation time → guard still errors for plain consumers) |
| #38 | verbs ignore the language pin with a foreign root marker | **fixed** — every verb now runs at the repo root with the pin; follow-up archspec#43 (specless `update` seeds the minority language; reseed drops `excluded_sources`) |
| #39 | MSTest.Sdk projects counted as production; xunit ones vanished | **fixed** — `scan` prints `test-gated unit: … — MSTest.Sdk / xunit.v3.mtp-v2`, census `test-gated units: 9` |
| #40 | `--write-exemptions` erases ledger `reason` | **not re-testable** — the tree now has zero live cycles, so the re-seed path never runs; the stale-entry detection itself works (it named our retired ledger entry correctly) |
| #41 | repro kit for #37/#38 | informational — both kits re-ran during this audit and drove the verdicts above |

## Findings

### F1 — The v1 cycle debt was an artifact, now retired

The first audit recorded one exempted cycle
(`Ordering.API -> Ordering.Domain -> Ordering.API`) caused by MSTest test files
declaring the bare `eShop.Ordering` namespace. With working test gating (#39)
that evidence is test-tier, the cycle is gone, and `verify` itself flagged the
ledger entry **stale** — the ratchet caught resolved debt exactly as designed.
No exempt entries remain.

### F2 — Namespace conventions visible once tests are gated out

With the seed spec's naive ownership, `verify` surfaced two namespace-tier rings
that project-tier claims had masked: `Microsoft::Extensions` ↔
`eShop::EventBusRabbitMQ`, and the bare `eShop::Ordering` ↔
`Ordering::Infrastructure`. Both are the .NET idiom of extension/wiring files
living in framework-shaped or service-root namespaces rather than real
inversions; the spec assigns them to owning/wiring claims so the facts are
represented instead of hidden, and the cross-claim graph is acyclic.

### F3 — Exact-set dependency contract (strict by design)

Every `allowed.depend_on` is a ceiling **and** a floor: 51 internal edges are
declared; removing one from code fails `verify --strict` as loudly as adding an
undeclared one. 72 external (NuGet/BCL) edges censused. Test-gated evidence
neither satisfies the floor nor engages the ceiling.

### F4 — Tooling notes

- `tools/Directory.Build.props` seeds `_ArchspecRid` for the package-props
  evaluation-time gap (archspec#42); remove it when that lands.
- `archspec update` keeps `language` but drops `excluded_sources` on reseed
  (archspec#43) — re-add after any reseed; the audit script always measures
  `update` with the reconciled spec restored around it.
- 20 TypeScript/JavaScript files remain declared out of scope via
  `excluded_sources`.

## Non-findings (checked, nothing found)

- inversion ledger clean; module graph acyclic with **zero** exempt entries
- territory complete over all production units; 9 test-gated units listed by scan

## Regenerating

```bash
./build/archspec/audit.sh          # regenerate every artefact + timings
git add docs/archspec && git commit
```
