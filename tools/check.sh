#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
while IFS= read -r file; do luac -p "$file"; done < <(grep -v '^#' BuddyRotation.toc)
lua tests/startup.lua
echo 'BuddyRotation OK'
