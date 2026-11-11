# archspec audit

Architecture conformance for this solution, checked with
[archspec](https://github.com/mateuszwrobel/archspec) — installed from NuGet as a
tools-only package (`Directory.Packages.props` → `archspec`), exposed by
`tools/archspec/ArchspecTools.csproj` as `$(ArchspecPath)`.

## Layout

| Path | What |
| --- | --- |
| `architecture.spec.toml` | the audit contract (boundaries, `depend_on`, `no_cycles`, exempt ledger) |
| `archspec.toml` | artifact destinations (`docs/archspec/`) |
| `build/archspec/audit.sh` | audit runner: regenerates + times every command; `--check` = CI gate |
| `docs/archspec/` | committed artifacts: diagrams, model JSON, ledger, API usage, report, timings |
| `.github/workflows/architecture.yml` | CI: `verify --strict` + artifact-freshness gates, timings in the job summary |

## Daily use

```bash
# does the tree match the contract?  (exit 0/1; --strict also demands full coverage)
dotnet msbuild tools/archspec/ArchspecTools.csproj -t:ArchspecVerify

# full local audit: regenerate docs/archspec/* and re-time every command
./build/archspec/audit.sh

# exactly what CI runs (no regeneration, freshness gates must pass)
./build/archspec/audit.sh --check
```

After changing architecture, run `./build/archspec/audit.sh` and commit the
updated `docs/archspec/` diff — CI fails if committed diagrams/artifacts drift
from the tree.

Tunables: `ARCHSPEC_RUNS` (measured runs per command, default 3), `DOTNET`
(override the SDK resolver when `global.json` needs a pinned SDK elsewhere).

`depgraph`/`inspect` target `src/` on purpose: the root `package.json` hijacks
driver auto-detection in archspec 0.6.69 (archspec#38).
