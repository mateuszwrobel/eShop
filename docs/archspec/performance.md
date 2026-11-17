# archspec performance — eShop

| field | value |
| --- | --- |
| generated | 2026-11-17T10:43:15Z |
| archspec | archspec 0.6.81 |
| git | 913acea |
| host | Linux 6.18.49-1-MANJARO / matman |
| runs | 3 measured + 1 warm-up per command |
| mode | audit |

| command | exit | runs (ms) | min | median | max | mean |
| --- | --- | --- | --- | --- | --- | --- |
| `doctor` | 0 | 150 150 151 | 150 | 150 | 151 | 150 |
| `scan` | 0 | 253 265 254 | 253 | 254 | 265 | 257 |
| `scan --check` | 0 | 257 262 398 | 257 | 262 | 398 | 306 |
| `inspect` | 0 | 237 258 247 | 237 | 247 | 258 | 247 |
| `depgraph modules` | 0 | 261 283 286 | 261 | 283 | 286 | 277 |
| `depgraph ledger` | 0 | 264 287 307 | 264 | 287 | 307 | 286 |
| `depgraph api-usage` | 0 | 284 258 314 | 258 | 284 | 314 | 285 |
| `diagram` | 0 | 7 1 12 | 1 | 7 | 12 | 7 |
| `diagram --source scan` | 0 | 6 5 6 | 5 | 6 | 6 | 6 |
| `explain Ordering.API Ordering.Domain` | 0 | 449 344 328 | 328 | 344 | 449 | 374 |
| `update --force` (spec restored) | 0 | 302 276 280 | 276 | 280 | 302 | 286 |
| `verify` | 0 | 280 282 276 | 276 | 280 | 282 | 279 |
| `verify --strict` | 0 | 279 459 302 | 279 | 302 | 459 | 347 |
| `report` | 0 | 278 291 276 | 276 | 278 | 291 | 282 |
| `report --format json` | 0 | 281 272 279 | 272 | 279 | 281 | 277 |
| `spec --schema` | 0 | 6 5 5 | 5 | 5 | 6 | 5 |
| `help` | 0 | 4 4 4 | 4 | 4 | 4 | 4 |

Total of medians: 3552 ms across 17 commands.

Notes: all verbs run at the repo root (archspec 0.6.81 honours the spec's
language pin everywhere); `update` runs with the reconciled spec saved
and restored around each run (its seed drops excluded_sources); times are warm page-cache runs.
