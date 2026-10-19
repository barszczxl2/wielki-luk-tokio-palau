#!/bin/bash
# Wgrywa podstronę /tokio-palau/ do źródeł wielki-luk.pl na VPS i publikuje.
# Uruchom na VPS (jako root):  bash scripts/apply-on-vps.sh
# Źródła strony: /root/wielki-luk-web (Astro). Cron codziennie o 05:36 UTC robi
# npm run build + vercel deploy --prod, więc po tym kroku podstrona zostaje na stałe.
set -e
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DST="${WIELKI_LUK_DIR:-/root/wielki-luk-web}"

[ -d "$DST/src" ] || { echo "Nie ma $DST/src — ustaw WIELKI_LUK_DIR"; exit 1; }

mkdir -p "$DST/public/tokio-palau"
cp -r "$SRC/public/tokio-palau/." "$DST/public/tokio-palau/"
echo "skopiowano public/tokio-palau ($(ls "$DST/public/tokio-palau/img" | wc -l) zdjęć)"

python3 "$SRC/scripts/patch-homepage.py" "$DST/src/components/HomePage.astro" "$SRC/patch/showcase-card.html"
python3 "$SRC/scripts/patch-sitemap.py" "$DST/public/sitemap.xml"

cd "$DST"
if [ "${NO_DEPLOY:-0}" = "1" ]; then echo "NO_DEPLOY=1 — bez publikacji"; exit 0; fi
/usr/bin/npm run build >/dev/null 2>&1 && echo "build OK"
/usr/bin/vercel deploy --prod --yes >/dev/null 2>&1 && echo "OK: https://wielki-luk.pl/tokio-palau/"
