#!/bin/bash
# Build wielki-luk.pl na Vercelu z nakładką: podstrona /tokio-palau/ + karta na stronie głównej.
# Ustawione jako Build Command projektu wielki-luk-web, więc działa też dla codziennych
# wdrożeń z VPS (cron 05:36 UTC), które nie mają tych plików w źródłach.
# Zasada: nakładka nigdy nie może zepsuć builda — przy błędzie budujemy stronę bez niej.
set -u
REPO_TGZ="https://codeload.github.com/barszczxl2/wielki-luk-tokio-palau/tar.gz/refs/heads/main"
HOME_ASTRO="src/components/HomePage.astro"
log() { echo "[nakładka tokio-palau] $*"; }

tmp="$(mktemp -d)"
if curl -fsSL "$REPO_TGZ" | tar xz -C "$tmp" --strip-components=1; then
  [ -f "$HOME_ASTRO" ] && cp -f "$HOME_ASTRO" "$tmp/HomePage.astro.bak"
  mkdir -p public/tokio-palau
  cp -r "$tmp/public/tokio-palau/." public/tokio-palau/ && log "skopiowano public/tokio-palau ($(ls public/tokio-palau/img | wc -l) plików img)"
  node "$tmp/scripts/patch-homepage.mjs" "$HOME_ASTRO" "$tmp/patch/showcase-card.html" || log "karta na stronie głównej pominięta"
  node "$tmp/scripts/patch-sitemap.mjs" public/sitemap.xml || log "sitemap pominięta"
  if npm run build; then
    log "build z nakładką OK"
    exit 0
  fi
  log "build z nakładką NIE powiódł się — przywracam HomePage.astro i buduję bez karty"
  [ -f "$tmp/HomePage.astro.bak" ] && cp -f "$tmp/HomePage.astro.bak" "$HOME_ASTRO"
else
  log "nie udało się pobrać nakładki z GitHuba — buduję bez niej"
fi
npm run build
