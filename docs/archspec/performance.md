# archspec performance — eShop

| field | value |
| --- | --- |
| generated | 2026-11-19T03:40:09Z |
| archspec | archspec 0.6.108 |
| git | 2d7bfec |
| host | Linux 6.18.49-1-MANJARO / matman |
| runs | 3 measured + 1 warm-up per command |
| mode | check |

| command | exit | runs (ms) | min | median | max | mean |
| --- | --- | --- | --- | --- | --- | --- |
| `scan --check` | 0 | 350 348 348 | 348 | 348 | 350 | 349 |
| `inspect --check` | 0 | 187 182 188 | 182 | 187 | 188 | 186 |
| `depgraph modules --check` | 0 | 362 360 352 | 352 | 360 | 362 | 358 |
| `depgraph ledger --check` | 0 | 345 344 345 | 344 | 345 | 345 | 345 |
| `diagram --check` | 0 | 2 2 1 | 1 | 2 | 2 | 2 |
| `report --check` | 0 | 346 348 348 | 346 | 348 | 348 | 347 |
| `verify` | 0 | 354 353 349 | 349 | 353 | 354 | 352 |
| `verify --strict` | 0 | 348 351 354 | 348 | 351 | 354 | 351 |

Total of medians: 2294 ms across 8 commands.

Notes: all verbs run at the repo root (archspec 0.6.108 honours the spec's
language pin everywhere); `update` runs with the reconciled spec saved
and restored around each run (a reseed regenerates all model-derived content); times are warm page-cache runs.
