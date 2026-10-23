#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodejs_24 jq

set -euo pipefail

version=$(npm view rea-agents version)
echo "version: $version"

# Regenerate package.json (runtime dependencies only) and its lock file
cd "$(dirname "${BASH_SOURCE[0]}")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -sL "$(npm view rea-agents@"$version" dist.tarball)" | tar xz -C "$tmp"
jq 'del(.devDependencies, .scripts)' "$tmp/package/package.json" > package.json
rm -f package-lock.json
npm install --package-lock-only --ignore-scripts

# Then bump `version` in package.nix and refresh both hashes
