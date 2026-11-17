# archspec performance — eShop

| field | value |
| --- | --- |
| generated | 2026-11-17T18:46:55Z |
| archspec | archspec 0.6.93 |
| git | 155d67a |
| host | Linux 6.18.49-1-MANJARO / matman |
| runs | 3 measured + 1 warm-up per command |
| mode | audit |

| command | exit | runs (ms) | min | median | max | mean |
| --- | --- | --- | --- | --- | --- | --- |
| `doctor` | 0 | 73 76 69 | 69 | 73 | 76 | 73 |
| `scan` | 0 | 409 418 404 | 404 | 409 | 418 | 410 |
| `scan --check` | 0 | 407 422 417 | 407 | 417 | 422 | 415 |
| `inspect` | 0 | 230 229 228 | 228 | 229 | 230 | 229 |
| `depgraph modules` | 0 | 412 410 426 | 410 | 412 | 426 | 416 |
| `depgraph ledger` | 0 | 417 415 404 | 404 | 415 | 417 | 412 |
| `depgraph api-usage` | 0 | 420 436 415 | 415 | 420 | 436 | 424 |
| `diagram` | 0 | 15 2 6 | 2 | 6 | 15 | 8 |
| `diagram --source scan` | 0 | 3 5 4 | 3 | 4 | 5 | 4 |
| `explain Ordering.API Ordering.Domain` | 0 | 423 419 414 | 414 | 419 | 423 | 419 |
| `update --force` (spec restored) | 0 | 411 413 416 | 411 | 413 | 416 | 413 |
| `verify` | 0 | 407 409 409 | 407 | 409 | 409 | 408 |
| `verify --strict` | 0 | 406 413 409 | 406 | 409 | 413 | 409 |
| `report` | 0 | 404 403 405 | 403 | 404 | 405 | 404 |
| `report --format json` | 0 | 411 416 412 | 411 | 412 | 416 | 413 |
| `spec --schema` | 0 | 2 2 2 | 2 | 2 | 2 | 2 |
| `help` | 0 | 1 1 1 | 1 | 1 | 1 | 1 |

Total of medians: 4854 ms across 17 commands.

Notes: all verbs run at the repo root (archspec 0.6.93 honours the spec's
language pin everywhere); `update` runs with the reconciled spec saved
and restored around each run (a reseed regenerates all model-derived content); times are warm page-cache runs.
