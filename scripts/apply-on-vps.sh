#!/bin/bash
# OPCJONALNE: wgrywa podstronę /tokio-palau/ do źródeł wielki-luk.pl na VPS (/root/wielki-luk-web).
# Od 25.10.2026 nie jest to konieczne — Build Command projektu na Vercelu (scripts/vercel-build.sh)
# dokleja podstronę i kartę przy każdym wdrożeniu, także tym z crona na VPS.
# Uruchom na VPS (jako root):  bash scripts/apply-on-vps.sh
set -e
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DST="${WIELKI_LUK_DIR:-/root/wielki-luk-web}"

[ -d "$DST/src" ] || { echo "Nie ma $DST/src — ustaw WIELKI_LUK_DIR"; exit 1; }

mkdir -p "$DST/public/tokio-palau"
cp -r "$SRC/public/tokio-palau/." "$DST/public/tokio-palau/"
echo "skopiowano public/tokio-palau ($(ls "$DST/public/tokio-palau/img" | wc -l) plików img)"

node "$SRC/scripts/patch-homepage.mjs" "$DST/src/components/HomePage.astro" "$SRC/patch/showcase-card.html"
node "$SRC/scripts/patch-sitemap.mjs" "$DST/public/sitemap.xml"

cd "$DST"
if [ "${NO_DEPLOY:-0}" = "1" ]; then echo "NO_DEPLOY=1 — bez publikacji"; exit 0; fi
/usr/bin/npm run build >/dev/null 2>&1 && echo "build OK"
/usr/bin/vercel deploy --prod --yes >/dev/null 2>&1 && echo "OK: https://wielki-luk.pl/tokio-palau/"
