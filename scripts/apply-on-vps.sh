#!/bin/bash
# OPCJONALNE: wgrywa nakładkę (/tokio-palau/, /palau/, karta na stronie głównej, sitemap) do źródeł
# wielki-luk.pl na VPS (/root/wielki-luk-web) i publikuje.
# Od 11.2026 produkcja stoi na VPS Hostinger (Caddy), cron 05:35 UTC: /etc/cron.d/wielki-luk-news
# → /root/wielki-luk-web/scripts/daily-refresh.sh. Ten skrypt = ręczne wdrożenie nakładki poza cronem.
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
if [ "${NO_DEPLOY:-0}" = "1" ]; then echo "NO_DEPLOY=1 — tylko wgrane, bez builda"; exit 0; fi
# Produkcja od 11.2026: VPS Hostinger, Caddy serwuje zbudowany katalog — wystarczy build.
npm run build >/dev/null 2>&1 && echo "build OK — Caddy serwuje nową wersję: https://wielki-luk.pl/tokio-palau/"
# Vercel tylko na wyraźne życzenie (WITH_VERCEL=1); domyślnie pomijany, bo domena nie wskazuje na Vercel.
if [ "${WITH_VERCEL:-0}" = "1" ]; then /usr/bin/vercel deploy --prod --yes >/dev/null 2>&1 && echo "Vercel: OK"; fi
