#!/bin/sh
# Copy the canonical .swift-format into a consumer repo, so every package formats identically.
#
# Usage:   scripts/sync-config.sh /path/to/consumer-repo
# The reusable CI workflow runs the equivalent diff and fails on drift.
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
canonical="$here/.swift-format"

dest="${1:-}"
if [ -z "$dest" ] || [ ! -d "$dest" ]; then
    printf 'usage: sync-config.sh <consumer-repo-dir>\n' >&2
    exit 2
fi

cp "$canonical" "$dest/.swift-format"
printf 'synced .swift-format -> %s/.swift-format\n' "$dest"
