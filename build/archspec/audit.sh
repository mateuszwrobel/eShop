#!/usr/bin/env bash
# archspec audit runner — runs the audit recipe (archspec help workflow) and
# times every command (warm-up + ARCHSPEC_RUNS measured runs), writing
# docs/archspec/performance.md / performance.json and the audit artefacts.
#
#   ./build/archspec/audit.sh            # audit mode: regenerate all artefacts, then time
#   ./build/archspec/audit.sh --check    # CI mode: same timing, artefact freshness gates
#                                        # (--check variants) + `verify --strict` as the gate
#
# Tunables: ARCHSPEC_RUNS (measured runs per command, default 3).
# Optional one-time setup for agent sessions: `archspec skill install`.
#
# Notes:
#   * depgraph/inspect run against src/ on purpose: the repo-root package.json
#     (Playwright) hijacks language auto-detection for those verbs (archspec
#     0.6.69); the repo-root commands read the language pin from the spec.
#   * `update` overwrites architecture.spec.toml, so it is measured once with
#     the reconciled spec saved and restored around it — it never lands.
#   * `update --force` in the timing loop is the seed step of the recipe, not
#     the CI gate; the gate is `verify --strict`.
set -u
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RUNS=${ARCHSPEC_RUNS:-3}
WARMUP=1
MODE=audit
[ "${1:-}" = "--check" ] && MODE=check

# ---------------------------------------------------------------- toolchain
resolve_dotnet() {
  local cand
  for cand in "${DOTNET:-dotnet}" "$HOME/.dotnet/dotnet"; do
    if "$cand" msbuild tools/archspec/ArchspecTools.csproj -t:_ResolveArchspecPath \
        -getProperty:ArchspecPath -nologo -v:q >/dev/null 2>&1; then
      DOTNET_BIN=$cand; return 0
    fi
  done
  echo "error: no dotnet SDK satisfying global.json (try installing the pinned SDK or set DOTNET=...)" >&2
  exit 1
}
resolve_dotnet
"$DOTNET_BIN" restore tools/archspec/ArchspecTools.csproj -v:q --nologo >/dev/null || {
  echo "error: restore of tools/archspec/ArchspecTools.csproj failed" >&2; exit 1; }
ARCHSPEC=$("$DOTNET_BIN" msbuild tools/archspec/ArchspecTools.csproj \
  -t:_ResolveArchspecPath -getProperty:ArchspecPath -nologo -v:q | tail -n1)
[ -x "$ARCHSPEC" ] || chmod +x "$ARCHSPEC" 2>/dev/null
VERSION=$("$ARCHSPEC" --version 2>/dev/null || echo unknown)

mkdir -p docs/archspec
ROWS=()        # display rows
JSON=()        # json entries
FAILED=()      # gate failures (check mode)

ms_now() { date +%s%3N; }

median() { sort -n <<<"$1" | awk 'BEGIN{c=0} {a[c++]=$1} END{print (c%2)? a[int(c/2)] : (a[int(c/2)-1]+a[int(c/2)])/2}'; }

# run_once <cmd...> — one timed invocation, echoes rc:ms
run_once() {
  local t0 t1 rc
  t0=$(ms_now); "$@" >/dev/null 2>&1; rc=$?; t1=$(ms_now)
  echo "$rc:$((t1 - t0))"
}

# timed <label> <gate-exit-classes> <cmd...> — warm-up + RUNS measured runs.
# gate classes: allowed final exit codes, e.g. "0" or "0,1".
timed() {
  local label=$1 gates=$2; shift 2
  local i rc out times=() last_rc=0
  for ((i=0; i<WARMUP; i++)); do run_once "$@" >/dev/null; done
  for ((i=0; i<RUNS; i++)); do
    out=$(run_once "$@"); last_rc=${out%%:*}; times+=("${out#*:}")
  done
  local list min max mean runs
  list=$(printf '%s\n' "${times[@]}"); runs=$(IFS=,; echo "${times[*]}")
  min=$(sort -n <<<"$list" | head -1); max=$(sort -n <<<"$list" | tail -1)
  mean=$(awk -v n=${#times[@]} '{s+=$1} END{printf "%.0f", s/n}' <<<"$list")
  ROWS+=("| \`$label\` | $last_rc | ${times[*]} | $min | $(median "$list") | $max | $mean |")
  JSON+=("{\"command\":\"$label\",\"runs\":[$runs],\"exit\":$last_rc}")
  if [[ ",$gates," != *",$last_rc,"* ]]; then FAILED+=("$label (exit $last_rc)"); fi
  printf '%-46s exit=%s  min=%sms med=%sms max=%sms\n' "$label" "$last_rc" "$min" "$(median "$list")" "$max"
}

# timed_update — update is destructive to the spec AND, in archspec <= 0.6.69,
# hijacked by the root package.json (Playwright) during driver auto-detection,
# so the Node manifests are moved aside for the timed invocation only.
timed_update() {
  local tmp; tmp=$(mktemp)
  cp architecture.spec.toml "$tmp"
  local i rc out times=() last_rc=0
  local pkg_json="" pkg_lock=""
  for ((i=0; i<WARMUP+RUNS; i++)); do
    cp "$tmp" architecture.spec.toml
    mv -f package.json /tmp/.archspec-pkgjson.$$ 2>/dev/null && pkg_json=1
    mv -f package-lock.json /tmp/.archspec-pkglock.$$ 2>/dev/null && pkg_lock=1
    if [ $i -lt $WARMUP ]; then
      run_once "$ARCHSPEC" update --force >/dev/null
    else
      out=$(run_once "$ARCHSPEC" update --force); last_rc=${out%%:*}; times+=("${out#*:}")
    fi
    [ -n "$pkg_json" ] && mv -f /tmp/.archspec-pkgjson.$$ package.json
    [ -n "$pkg_lock" ] && mv -f /tmp/.archspec-pkglock.$$ package-lock.json
  done
  cp "$tmp" architecture.spec.toml; rm -f "$tmp"
  local list min max mean runs
  list=$(printf '%s\n' "${times[@]}"); runs=$(IFS=,; echo "${times[*]}")
  min=$(sort -n <<<"$list" | head -1); max=$(sort -n <<<"$list" | tail -1)
  mean=$(awk -v n=${#times[@]} '{s+=$1} END{printf "%.0f", s/n}' <<<"$list")
  ROWS+=("| \`update --force\` (spec restored) | $last_rc | ${times[*]} | $min | $(median "$list") | $max | $mean |")
  JSON+=("{\"command\":\"update --force\",\"runs\":[$runs],\"exit\":$last_rc}")
  if [[ ",0," != *",$last_rc,"* ]]; then FAILED+=("update (exit $last_rc)"); fi
  printf '%-46s exit=%s  min=%sms med=%sms max=%sms\n' "update --force (spec restored)" "$last_rc" "$min" "$(median "$list")" "$max"
}

echo "== archspec audit ($MODE mode, $RUNS runs/command) =="
echo "binary: $ARCHSPEC ($VERSION)"

# ------------------------------------------------ 1. regenerate canonical artefacts
# Audit mode refreshes the artefacts so every measured run below times a warm,
# deterministic command against the current tree. Check mode deliberately does
# NOT regenerate — the --check gates must compare committed bytes against the
# current tree, which is the diagram/artefact freshness contract.
if [ "$MODE" = audit ]; then
  "$ARCHSPEC" scan >/dev/null
  "$ARCHSPEC" inspect src --output docs/archspec/inspect.mmd >/dev/null
  "$ARCHSPEC" depgraph modules src --output docs/archspec/depgraph-modules.mmd >/dev/null
  "$ARCHSPEC" depgraph ledger src --output docs/archspec/depgraph-ledger.md >/dev/null
  "$ARCHSPEC" depgraph api-usage src --output docs/archspec/api-usage.md >/dev/null
  "$ARCHSPEC" diagram >/dev/null
  "$ARCHSPEC" diagram --source scan docs/archspec/scan.json --tiers modules \
    --output docs/archspec/diagram-scan-modules.mmd >/dev/null
  "$ARCHSPEC" report >/dev/null
  "$ARCHSPEC" report --format json --output docs/archspec/report.json >/dev/null
fi

# ------------------------------------------------ 2. timed commands (recipe order)
if [ "$MODE" = "check" ]; then
  timed "scan --check"                0 "$ARCHSPEC" scan --check
  timed "inspect src --check"         0 "$ARCHSPEC" inspect src --output docs/archspec/inspect.mmd --check
  timed "depgraph modules --check"    0 "$ARCHSPEC" depgraph modules src --output docs/archspec/depgraph-modules.mmd --check
  timed "depgraph ledger --check"     0 "$ARCHSPEC" depgraph ledger src --output docs/archspec/depgraph-ledger.md --check
  timed "diagram --check"             0 "$ARCHSPEC" diagram --check
  timed "report --check"              0 "$ARCHSPEC" report --check
  timed "verify"                      0,1 "$ARCHSPEC" verify
  timed "verify --strict"             0 "$ARCHSPEC" verify --strict
else
  timed "doctor"                      0 "$ARCHSPEC" doctor
  timed "scan"                        0 "$ARCHSPEC" scan
  timed "scan --check"                0 "$ARCHSPEC" scan --check
  timed "inspect src"                 0 "$ARCHSPEC" inspect src --output docs/archspec/inspect.mmd
  timed "depgraph modules src"        0 "$ARCHSPEC" depgraph modules src --output docs/archspec/depgraph-modules.mmd
  timed "depgraph ledger src"         0 "$ARCHSPEC" depgraph ledger src --output docs/archspec/depgraph-ledger.md
  timed "depgraph api-usage src"      0 "$ARCHSPEC" depgraph api-usage src --output docs/archspec/api-usage.md
  timed "diagram"                     0 "$ARCHSPEC" diagram
  timed "diagram --source scan"       0 "$ARCHSPEC" diagram --source scan docs/archspec/scan.json --tiers modules --output docs/archspec/diagram-scan-modules.mmd
  timed "explain Ordering.API Ordering.Domain" 0,1 "$ARCHSPEC" explain Ordering.API Ordering.Domain
  timed_update
  timed "verify"                      0,1 "$ARCHSPEC" verify
  timed "verify --strict"             0,1 "$ARCHSPEC" verify --strict
  timed "report"                      0,1 "$ARCHSPEC" report
  timed "report --format json"        0,1 "$ARCHSPEC" report --format json --output docs/archspec/report.json
  timed "spec --schema"               0 "$ARCHSPEC" spec --schema
  timed "help"                        0 "$ARCHSPEC" help
fi

# ------------------------------------------------ 3. performance report
TOTAL=$(printf '%s\n' "${ROWS[@]}" | awk -F'|' '{gsub(/ /,"",$6); s+=$6} END{print s}')
{
  echo "# archspec performance — eShop"
  echo
  echo "| field | value |"
  echo "| --- | --- |"
  echo "| generated | $(date -u +%Y-%m-%dT%H:%M:%SZ) |"
  echo "| archspec | $VERSION |"
  echo "| git | $(git rev-parse --short HEAD 2>/dev/null || echo n/a) |"
  echo "| host | $(uname -sr) / ${HOSTNAME:-n/a} |"
  echo "| runs | $RUNS measured + $WARMUP warm-up per command |"
  echo "| mode | $MODE |"
  echo
  echo "| command | exit | runs (ms) | min | median | max | mean |"
  echo "| --- | --- | --- | --- | --- | --- | --- |"
  printf '%s\n' "${ROWS[@]}"
  echo
  echo "Total of medians: ${TOTAL} ms across ${#ROWS[@]} commands."
  echo
  echo "Notes: \`depgraph\`/\`inspect\` run on \`src/\` (root \`package.json\` hijacks"
  echo "auto-detection in $VERSION); \`update\` runs with the reconciled spec saved"
  echo "and the Node manifests moved aside (restored after each run); times are warm page-cache runs."
} > docs/archspec/performance.md
json_body=""
for ((i=0;i<${#JSON[@]};i++)); do
  [ "$i" -gt 0 ] && json_body+=",
    "
  json_body+="${JSON[i]}"
done
printf '{\n  "generated": "%s",\n  "archspec": "%s",\n  "commands": [\n    %s\n  ]\n}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$VERSION" "$json_body" \
  > docs/archspec/performance.json

echo
echo "wrote docs/archspec/performance.md ($RUNS runs x ${#ROWS[@]} commands, total of medians ${TOTAL} ms)"

# On GitHub Actions, surface the timing table in the job summary too.
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat docs/archspec/performance.md >>"$GITHUB_STEP_SUMMARY"
fi

# ------------------------------------------------ 4. gate summary
if [ "$MODE" = "check" ]; then
  if [ ${#FAILED[@]} -gt 0 ]; then
    echo "FAILED gates:"; printf '  - %s\n' "${FAILED[@]}"
    exit 1
  fi
  echo "gates green: artefacts fresh, verify --strict clean"
fi
