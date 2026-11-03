#!/bin/bash
# OPCJONALNE: wgrywa nakładkę (/tokio-palau/, /palau/, karta na stronie głównej, sitemap) do źródeł
# wielki-luk.pl na VPS (/root/wielki-luk-web) i publikuje.
# Od 25.10.2026 nie jest to konieczne — Build Command projektu na Vercelu (scripts/vercel-build.sh)
# dokleja nakładkę przy każdym wdrożeniu, także tym z crona na VPS.
# Uruchom na VPS (jako root):  bash scripts/apply-on-vps.sh
#   WIELKI_LUK_DIR=/inna/ścieżka  — inny katalog projektu
#   NO_DEPLOY=1                   — tylko wgraj i zbuduj, bez publikacji
set -eu
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DST="${WIELKI_LUK_DIR:-/root/wielki-luk-web}"
# shellcheck source=scripts/overlay-lib.sh
source "$SRC/scripts/overlay-lib.sh"

[ -d "$DST/src" ] || { echo "Nie ma $DST/src — ustaw WIELKI_LUK_DIR"; exit 1; }

overlay_copy_public "$SRC" "$DST"
overlay_patch_homepage "$SRC" "$DST"
overlay_patch_sitemap "$SRC" "$DST"

cd "$DST"
if [ "${NO_DEPLOY:-0}" = "1" ]; then echo "NO_DEPLOY=1 — bez publikacji"; exit 0; fi
/usr/bin/npm run build >/dev/null 2>&1 && echo "build OK"
/usr/bin/vercel deploy --prod --yes >/dev/null 2>&1 && echo "OK: https://wielki-luk.pl/tokio-palau/"
