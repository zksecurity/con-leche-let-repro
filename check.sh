#!/usr/bin/env bash
# Usage: CON_LECHE=/path/to/con-leche ./check.sh
set -u
: "${CON_LECHE:?set CON_LECHE to the con-leche binary}"
lake build >/dev/null || exit 1
SP="$(lean --print-libdir):.lake/build/lib/lean"
for m in Repro.ViaLemma Repro.ViaHave Repro.ViaBeta; do
  echo "== $m"
  /usr/bin/time "$CON_LECHE" --olean --search-path="$SP" -- "$m" 2>&1 | tail -3
done
