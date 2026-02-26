#!/usr/bin/env bash
# Assembles docs/spec.md from all .cue sources in the dialectics repo.
# Usage: bash scripts/build-spec.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO_ROOT/docs/index.md"

mkdir -p "$REPO_ROOT/docs"

# Extract title from first // comment line of a .cue file
title_from() {
  head -1 "$1" | sed 's|^// *||'
}

# Emit a file as a markdown section (heading level passed as $1)
emit() {
  local level="$1" file="$2"
  local title
  title="$(title_from "$file")"
  printf '%s %s\n\n' "$level" "$title"
  printf '```cue\n'
  cat "$file"
  printf '\n```\n\n'
}

{
  cat <<'INTRO'
# Dialectics Spec

Machine-readable specification for the Riverline Dialectics framework.
Each section contains a CUE file defining either the kernel, a governance
layer, or a dialectical protocol.

INTRO

  # Kernel
  printf '## Kernel\n\n'
  emit "###" "$REPO_ROOT/dialectics.cue"

  # Governance
  printf '## Governance\n\n'
  emit "###" "$REPO_ROOT/governance/routing.cue"
  emit "###" "$REPO_ROOT/governance/recording.cue"

  # Adversarial Protocols
  printf '## Adversarial Protocols\n\n'
  for f in cffp cdp cbp hep atp emp; do
    emit "###" "$REPO_ROOT/protocols/adversarial/${f}.cue"
  done

  # Evaluative Protocols
  printf '## Evaluative Protocols\n\n'
  for f in aap ifa rcp cgp ptp ovp; do
    emit "###" "$REPO_ROOT/protocols/evaluative/${f}.cue"
  done

  # Exploratory Protocols
  printf '## Exploratory Protocols\n\n'
  emit "###" "$REPO_ROOT/protocols/exploratory/adp.cue"

} > "$OUT"

echo "wrote $OUT ($(wc -l < "$OUT" | tr -d ' ') lines)"
