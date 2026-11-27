#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
[[ $# == 2 && $1 == --output-dir ]]
out=$(realpath -m -- "$2")
./tools/check.sh
version=$(awk '/^## Version:/ {print $3}' BuddyRotation.toc)
if [[ ! -s RELEASE_NOTES.md ]] ||
    [[ $(head -n 1 RELEASE_NOTES.md) != "# v$version" ]] ||
    ! grep -q '^- [^[:space:]]' RELEASE_NOTES.md; then
    printf 'RELEASE_NOTES.md must contain the v%s heading and at least one release note.\n' "$version" >&2
    exit 1
fi
mkdir -p -- "$out"
stage=$(mktemp -d -- "$out/.buddyrotation.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
mapfile -t files < <(grep -v '^#' BuddyRotation.toc)
mkdir "$stage/BuddyRotation"
cp -- BuddyRotation.toc "${files[@]}" "$stage/BuddyRotation/"
(cd "$stage" && zip -qr package.zip BuddyRotation && unzip -tq package.zip)
ln -- "$stage/package.zip" "$out/BuddyRotation-$version-forever.zip"
