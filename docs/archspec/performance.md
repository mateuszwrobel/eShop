# archspec performance — eShop

| field | value |
| --- | --- |
| generated | 2026-11-17T19:52:18Z |
| archspec | archspec 0.6.94 |
| git | 4b63376 |
| host | Linux 6.18.49-1-MANJARO / matman |
| runs | 3 measured + 1 warm-up per command |
| mode | audit |

| command | exit | runs (ms) | min | median | max | mean |
| --- | --- | --- | --- | --- | --- | --- |
| `doctor` | 0 | 67 66 64 | 64 | 66 | 67 | 66 |
| `scan` | 0 | 452 469 507 | 452 | 469 | 507 | 476 |
| `scan --check` | 0 | 457 454 443 | 443 | 454 | 457 | 451 |
| `inspect` | 0 | 257 294 374 | 257 | 294 | 374 | 308 |
| `depgraph modules` | 0 | 458 463 446 | 446 | 458 | 463 | 456 |
| `depgraph ledger` | 0 | 443 442 441 | 441 | 442 | 443 | 442 |
| `depgraph api-usage` | 0 | 442 443 430 | 430 | 442 | 443 | 438 |
| `diagram` | 0 | 29 2 5 | 2 | 5 | 29 | 12 |
| `diagram --source scan` | 0 | 3 4 3 | 3 | 3 | 4 | 3 |
| `explain Ordering.API Ordering.Domain` | 0 | 449 451 449 | 449 | 449 | 451 | 450 |
| `update --force` (spec restored) | 0 | 485 442 429 | 429 | 442 | 485 | 452 |
| `verify` | 0 | 432 425 426 | 425 | 426 | 432 | 428 |
| `verify --strict` | 0 | 463 500 454 | 454 | 463 | 500 | 472 |
| `report` | 0 | 449 441 450 | 441 | 449 | 450 | 447 |
| `report --format json` | 0 | 435 469 414 | 414 | 435 | 469 | 439 |
| `spec --schema` | 0 | 7 1 1 | 1 | 1 | 7 | 3 |
| `help` | 0 | 1 3 1 | 1 | 1 | 3 | 2 |

Total of medians: 5299 ms across 17 commands.

Notes: all verbs run at the repo root (archspec 0.6.94 honours the spec's
language pin everywhere); `update` runs with the reconciled spec saved
and restored around each run (a reseed regenerates all model-derived content); times are warm page-cache runs.
