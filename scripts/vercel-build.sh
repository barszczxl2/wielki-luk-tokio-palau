#!/bin/bash
# Build wielki-luk.pl na Vercelu z nakładką: /tokio-palau/, /palau/ i nowa strona główna PL (home/index.html).
# Ustawione jako Build Command projektu wielki-luk-web, więc działa też dla codziennych
# wdrożeń z VPS (cron 05:36 UTC), które nie mają tych plików w źródłach.
# Zasada: nakładka nigdy nie może zepsuć builda — przy błędzie budujemy stronę bez niej.
# Kroki nakładki są w scripts/overlay-lib.sh (wspólne z apply-on-vps.sh).
set -u
REPO_TGZ="https://codeload.github.com/barszczxl2/wielki-luk-tokio-palau/tar.gz/refs/heads/main"
HOME_ASTRO="src/components/HomePage.astro"
log() { echo "[nakładka tokio-palau] $*"; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if curl -fsSL "$REPO_TGZ" | tar xz -C "$tmp" --strip-components=1 && [ -f "$tmp/scripts/overlay-lib.sh" ]; then
  # shellcheck source=scripts/overlay-lib.sh
  source "$tmp/scripts/overlay-lib.sh"
  [ -f "$HOME_ASTRO" ] && cp -f "$HOME_ASTRO" "$tmp/HomePage.astro.bak"
  overlay_copy_public "$tmp" "."
  overlay_patch_homepage "$tmp" "." || log "karta na stronie głównej pominięta"
  overlay_patch_sitemap "$tmp" "." || log "sitemap pominięta"
  if npm run build; then
    overlay_replace_home "$tmp" "."
    log "build z nakładką OK"
    exit 0
  fi
  log "build z nakładką NIE powiódł się — przywracam HomePage.astro i buduję bez karty"
  [ -f "$tmp/HomePage.astro.bak" ] && cp -f "$tmp/HomePage.astro.bak" "$HOME_ASTRO"
else
  log "nie udało się pobrać nakładki z GitHuba — buduję bez niej"
fi
npm run build
