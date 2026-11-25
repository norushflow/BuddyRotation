#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
[[ $# == 2 && $1 == --output-dir ]]
out=$(realpath -m -- "$2")
./tools/check.sh
version=$(awk '/^## Version:/ {print $3}' BuddyRotation.toc)
mkdir -p -- "$out"
stage=$(mktemp -d -- "$out/.buddyrotation.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
mapfile -t files < <(grep -v '^#' BuddyRotation.toc)
mkdir "$stage/BuddyRotation"
cp -- BuddyRotation.toc "${files[@]}" "$stage/BuddyRotation/"
(cd "$stage" && zip -qr package.zip BuddyRotation && unzip -tq package.zip)
ln -- "$stage/package.zip" "$out/BuddyRotation-$version-forever.zip"
