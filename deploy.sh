#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="/Users/jojyalex/Documents/sourcecode/house/app/dist"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMIT_MESSAGE="${1:-Update built application}"

if [[ ! -d "$SOURCE_DIR" ]]; then
  printf 'Source directory does not exist: %s\n' "$SOURCE_DIR" >&2
  exit 1
fi

if ! git -C "$REPO_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  printf 'Destination is not a Git repository: %s\n' "$REPO_DIR" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  printf 'rsync is required but was not found on PATH.\n' >&2
  exit 1
fi

rsync -a --exclude='.DS_Store' "$SOURCE_DIR/" "$REPO_DIR/"

git -C "$REPO_DIR" add -A

if git -C "$REPO_DIR" diff --cached --quiet; then
  printf 'No changes to commit.\n'
  exit 0
fi

git -C "$REPO_DIR" commit -m "$COMMIT_MESSAGE"
git -C "$REPO_DIR" push
