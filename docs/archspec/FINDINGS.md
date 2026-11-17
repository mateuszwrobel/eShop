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
ledger clean, and all nine test projects uniformly test-gated. The
cross-service event layer is declared via `[[async_depends]]`: **18 edges over
9 service pairs** (13 contracts), reported advisory-only — one legit async ring
(Ordering↔Catalog), zero false positives.

## Issue scoreboard (what the redo re-tested)

| issue | subject | status |
| --- | --- | --- |
| #37 | props `<Error>` breaks MSBuild 18 | **fixed** (0.6.81); follow-up #42 fixed (0.6.94) |
| #38 | language-pin ignored by some verbs | **fixed** (0.6.81); follow-up #43 fixed |
| #39 | MSTest/xunit test-gating asymmetry | **fixed** — uniform `test-gated units: 9` |
| #40 | write-exemptions erases ledger reason | dormant — no cycles to seed |
| #41 | repro kits | consumed as regression harness |
| #42 | RID at evaluation time | **fixed (0.6.94)** — verified on this tree: consumer seed deleted, the tools project resolves `ArchspecPath` cleanly through the pure package path (official SDK, target-time `linux-x64`), and a synthetic consumer on the Arch system SDK (execution-time RID `arch-x64`) resolves through the fold row to the `linux-x64` binary with no seed and no error |
| #43 | update misseed / drops excluded_sources | **fixed (0.6.93)** — verified on this tree: specless polyglot roots get a loud mismatch refusal naming the pin remedy (no silent minority seed), and reseeds preserve `[project] excluded_sources` |
| #44 | cross-service event deps invisible | **fixed** — shipped as `[[async_depends]]` (0.6.86–0.6.91), declared in this spec |

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

- No consumer-side RID seeding is needed since 0.6.94: the package selects
  the binary at target-execution time (the `tools/Directory.Build.props`
  seed that the evaluation-time gap required was retired with the fix).
- `archspec update --force` preserves `[project]` keys (language,
  excluded_sources) since 0.6.93 (archspec#43 fixed), but still reseeds all
  model-derived content — the audit script therefore keeps measuring `update`
  with the reconciled spec saved and restored around it, since a reseed drops
  reconciled claims, constraints and `[[async_depends]]` by design.
- 20 TypeScript/JavaScript files remain declared out of scope via
  `excluded_sources`.

### F5 — The cross-service event layer is now declared, not inferred

The 13 integration-event contracts duplicate per consumer (the distributed-
contract idiom), so no compile-time edge connects publisher to subscriber —
the original audit could only call this a blind spot. With `[[async_depends]]`
(archspec#44 fixed) the contract graph is a declared fact: 18 edges over 9
service pairs — endpoint legs identity declaration-trusted, while payload
shape, bind-site liveness and async rings are derived from source (a
mutation matrix of 8 arms confirmed the endpoint legs themselves are
declaration-trusted, not adjudicated; the shipped spec wording is exact
here, prose elsewhere overclaimed). Census: `Ordering.API` fan-in 5 /
fan-out 12 — the
"0 dependents" reading of the direct graph is finally quotable with its async
half. The Ordering↔Catalog round-trip appears as an advisory async ring, not
a cycle violation: `no_cycles` adjudicates the direct graph only, which stays
acyclic. Drift census on the declared set prints nothing — no field binds a
field the publisher lacks, and the enum→string `OrderStatus` projections do
not warn because the WebApp handlers never stringify the event field itself
(the projection class is bind-site based; a probe using the field makes
exactly one row appear). Wire-safety of those projections rests on the
`[JsonConverter(JsonStringEnumConverter)]` attribute on `OrderStatus` — the
one contract fact no static check covers; deleting that attribute would flip
the wire format to integers silently.

## Non-findings (checked, nothing found)

- inversion ledger clean; module graph acyclic with **zero** exempt entries
- territory complete over all production units; 9 test-gated units listed by scan

## Regenerating

```bash
./build/archspec/audit.sh          # regenerate every artefact + timings
git add docs/archspec && git commit
```
