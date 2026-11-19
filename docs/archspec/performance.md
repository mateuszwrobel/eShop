# archspec performance — eShop

| field | value |
| --- | --- |
| generated | 2026-11-19T06:57:26Z |
| archspec | archspec 0.6.109 |
| git | 08b573e |
| host | Linux 6.18.49-1-MANJARO / matman |
| runs | 3 measured + 1 warm-up per command |
| mode | check |

| command | exit | runs (ms) | min | median | max | mean |
| --- | --- | --- | --- | --- | --- | --- |
| `scan --check` | 0 | 408 510 404 | 404 | 408 | 510 | 441 |
| `inspect --check` | 0 | 207 204 211 | 204 | 207 | 211 | 207 |
| `depgraph modules --check` | 0 | 428 416 467 | 416 | 428 | 467 | 437 |
| `depgraph ledger --check` | 0 | 399 396 416 | 396 | 399 | 416 | 404 |
| `diagram --check` | 0 | 1 2 1 | 1 | 1 | 2 | 1 |
| `report --check` | 0 | 412 397 417 | 397 | 412 | 417 | 409 |
| `verify` | 0 | 403 399 400 | 399 | 400 | 403 | 401 |
| `verify --strict` | 0 | 404 423 391 | 391 | 404 | 423 | 406 |

Total of medians: 2659 ms across 8 commands.

Notes: all verbs run at the repo root (archspec 0.6.109 honours the spec's
language pin everywhere); `update` runs with the reconciled spec saved
and restored around each run (a reseed regenerates all model-derived content); times are warm page-cache runs.
