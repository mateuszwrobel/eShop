# archspec performance — eShop

| field | value |
| --- | --- |
| generated | 2026-11-11T20:05:23Z |
| archspec | archspec 0.6.69 |
| git | 913acea |
| host | Linux 6.18.49-1-MANJARO / matman |
| runs | 1 measured + 1 warm-up per command |
| mode | check |

| command | exit | runs (ms) | min | median | max | mean |
| --- | --- | --- | --- | --- | --- | --- |
| `scan --check` | 0 | 247 | 247 | 247 | 247 | 247 |
| `inspect src --check` | 0 | 191 | 191 | 191 | 191 | 191 |
| `depgraph modules --check` | 0 | 198 | 198 | 198 | 198 | 198 |
| `depgraph ledger --check` | 0 | 196 | 196 | 196 | 196 | 196 |
| `diagram --check` | 1 | 1 | 1 | 1 | 1 | 1 |
| `report --check` | 0 | 234 | 234 | 234 | 234 | 234 |
| `verify` | 0 | 238 | 238 | 238 | 238 | 238 |
| `verify --strict` | 0 | 240 | 240 | 240 | 240 | 240 |

Total of medians: 1545 ms across 8 commands.

Notes: `depgraph`/`inspect` run on `src/` (root `package.json` hijacks
auto-detection in archspec 0.6.69); `update` runs with the reconciled spec saved
and the Node manifests moved aside (restored after each run); times are warm page-cache runs.
