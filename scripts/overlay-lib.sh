#!/bin/bash
# Wspólne kroki nakładki Tokio–Palau, używane przez vercel-build.sh (Vercel) i apply-on-vps.sh (VPS).
# Wczytaj przez:  source "<repo>/scripts/overlay-lib.sh"
# Wszystkie funkcje przyjmują:  SRC = katalog tego repozytorium,  DST = katalog projektu wielki-luk-web.
# Komunikaty "[nakładka tokio-palau] ..." są sprawdzane automatycznie w logu builda — nie zmieniaj ich treści.

log() { echo "[nakładka tokio-palau] $*"; }

# Kopiuje public/tokio-palau i (jeśli jest) public/palau do projektu.
overlay_copy_public() {
  local src="$1" dst="$2"
  mkdir -p "$dst/public/tokio-palau"
  cp -r "$src/public/tokio-palau/." "$dst/public/tokio-palau/" \
    && log "skopiowano public/tokio-palau ($(ls "$dst/public/tokio-palau/img" | wc -l) plików img)"
  if [ -d "$src/public/palau" ]; then
    mkdir -p "$dst/public/palau"
    cp -r "$src/public/palau/." "$dst/public/palau/" && log "skopiowano public/palau"
  fi
}

# Dodaje kartę podróży do HomePage.astro (idempotentnie). Zwraca kod wyjścia patch-homepage.mjs.
overlay_patch_homepage() {
  local src="$1" dst="$2"
  node "$src/scripts/patch-homepage.mjs" "$dst/src/components/HomePage.astro" "$src/patch/showcase-card.html"
}

# Dopisuje /palau/ i /tokio-palau/ do sitemap.xml (idempotentnie). Zwraca kod wyjścia patch-sitemap.mjs.
overlay_patch_sitemap() {
  local src="$1" dst="$2"
  node "$src/scripts/patch-sitemap.mjs" "$dst/public/sitemap.xml"
}

# Po udanym `npm run build`: podmienia stronę główną PL (dist/index.html) na home/index.html z dwoma zegarami.
overlay_replace_home() {
  local src="$1" dst="$2"
  if [ -f "$src/home/index.html" ] && [ -f "$dst/dist/index.html" ]; then
    cp -f "$src/home/index.html" "$dst/dist/index.html" && log "strona główna PL podmieniona (dwa zegary)"
  else
    log "UWAGA: nie podmieniono strony głównej (brak home/index.html albo dist/index.html)"
  fi
}
