#!/usr/bin/env bash
#
# Sync the asset-packagist mirror from upstream.
#
# Reads the wanted package list from bin/packages.dist.txt, resolves each
# package's current sha256 from upstream, downloads any missing provider
# files into p/, prunes stale ones, and regenerates packages.json.
#
# Config: RAW_BASE (the public URL of this mirror) is read from .env, so the
# repo can be deployed behind any server (GitHub raw, nginx, ...).
#
# Usage: ./bin/sync.sh   (or: make sync)
#
set -euo pipefail

CDN="https://cdn.asset-packagist.org"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"   # .../bin
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"          # repo root
CONFIG="$SCRIPT_DIR/packages.dist.txt"
CACHE_DIR="$ROOT/.cache"
PUBLIC_DIR="$ROOT/public"                      # web root: packages.json, p/, index.html
OUT="$PUBLIC_DIR/packages.json"

for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: '$bin' is required" >&2; exit 1; }
done
[ -f "$CONFIG" ] || { echo "error: config not found: $CONFIG" >&2; exit 1; }

# Load .env (RAW_BASE etc.); fall back to this repo's GitHub raw URL.
if [ -f "$ROOT/.env" ]; then
  set -a; . "$ROOT/.env"; set +a
fi
# Default is root-relative ("/p/..."), like upstream. Used verbatim, so a custom
# RAW_BASE must include its own trailing slash, e.g. "https://host/public/".
RAW_BASE="${RAW_BASE:-/}"

mkdir -p "$CACHE_DIR"

# 1. Read the wanted packages: strip comments, grab each "namespace/name" token.
PACKAGES=$(sed -E 's/#.*$//' "$CONFIG" | grep -oE '[A-Za-z0-9._-]+/[A-Za-z0-9._-]+' || true)
[ -n "$PACKAGES" ] || { echo "error: no packages found in $CONFIG" >&2; exit 1; }

# 2. Fetch the tiny upstream packages.json to learn the current provider-latest hash.
echo "==> fetching upstream index"
PL_HASH=$(curl -fsSL "$CDN/packages.json" \
  | jq -r '.["provider-includes"]["p/provider-latest/%hash%.json"].sha256')
[ -n "$PL_HASH" ] && [ "$PL_HASH" != "null" ] \
  || { echo "error: could not read provider-latest hash from upstream" >&2; exit 1; }

# 3. Download the big provider-latest.json only when the hash changed (cache by hash).
PL_FILE="$CACHE_DIR/provider-latest-$PL_HASH.json"
if [ -f "$PL_FILE" ]; then
  echo "==> provider-latest cached ($PL_HASH)"
else
  echo "==> downloading provider-latest ($PL_HASH)"
  # Download to a temp file and move into place atomically, so an interrupted
  # download never leaves a half-written cache file behind.
  curl -fSL "$CDN/p/provider-latest/$PL_HASH.json" -o "$PL_FILE.part"
  mv "$PL_FILE.part" "$PL_FILE"
fi

# 4. Resolve each wanted package and download its provider file if we don't have it yet.
PAIRS="$(mktemp)"        # "name<TAB>hash" per line
VALID="$(mktemp)"        # absolute paths of the files we want to keep
trap 'rm -f "$PAIRS" "$VALID"' EXIT
echo "==> syncing packages"
while IFS= read -r pkg; do
  [ -n "$pkg" ] || continue
  hash=$(jq -r --arg p "$pkg" '.providers[$p].sha256 // empty' "$PL_FILE")
  if [ -z "$hash" ]; then
    echo "  ! not found upstream: $pkg" >&2
    continue
  fi
  dest="$PUBLIC_DIR/p/$pkg/$hash.json"
  if [ -f "$dest" ]; then
    echo "  = $pkg ($hash)"
  else
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$CDN/p/$pkg/$hash.json" -o "$dest"
    echo "  + $pkg ($hash)"
  fi
  printf '%s\t%s\n' "$pkg" "$hash" >> "$PAIRS"
  printf '%s\n' "$dest" >> "$VALID"
done <<EOF
$PACKAGES
EOF

# 5. Prune stale provider files: any p/**/*.json not in the keep-set is removed.
echo "==> pruning stale files"
if [ -d "$PUBLIC_DIR/p" ]; then
  find "$PUBLIC_DIR/p" -type f -name '*.json' | while IFS= read -r f; do
    if ! grep -qxF "$f" "$VALID"; then
      echo "  - $f"
      rm -f "$f"
    fi
  done
  find "$PUBLIC_DIR/p" -type d -empty -delete
fi

# 6. Regenerate packages.json with the flattened providers map (no 18MB file for Composer).
PROVIDERS=$(jq -R -s '
  split("\n") | map(select(length > 0) | split("\t"))
  | map({ (.[0]): { sha256: .[1] } }) | add // {}
' "$PAIRS")

jq -n \
  --arg url "${RAW_BASE}p/%package%/%hash%.json" \
  --argjson providers "$PROVIDERS" \
  '{
     "providers-url": $url,
     "providers": $providers,
     "available-package-patterns": ["bower-asset/*", "npm-asset/*"]
   }' > "$OUT.tmp"
mv "$OUT.tmp" "$OUT"

echo "==> wrote $OUT (providers-url base: $RAW_BASE)"
echo "Done. Review the diff and commit."
