# CLAUDE.md — wielki-luk-tokio-palau (nakładka na wielki-luk.pl)

## Czym jest ten folder

Statyczne strony serwisu **wielki-luk.pl**, które nie pochodzą z bazy Astro:
`/tokio-palau/` (plan Tokio → Palau → Seul, 4–23.11.2026, powrót rano 23.11), `/tokio-palau/mapa/`, `/palau/`
oraz nowa strona główna PL `home/index.html` („dwa zegary”). Szczegóły plików są w `README.md`.

## Jak trafia na produkcję

Build Command projektu Vercel `wielki-luk-web` to:
`curl .../wielki-luk-tokio-palau/main/scripts/vercel-build.sh | bash` z fallbackiem na `npm run build`.
Każdy build bazy (w tym codzienny cron z VPS o 05:36 UTC) pobiera **gałąź `main` tego repo**:

1. kopiuje `public/tokio-palau` i `public/palau` do bazy,
2. `scripts/patch-homepage.mjs` dodaje kartę do `HomePage.astro`, a `scripts/patch-sitemap.mjs` dopisuje adresy do sitemapy,
3. `npm run build`, a potem `home/index.html` nadpisuje `dist/index.html`.

**Push na `main` = zmiana na produkcji przy następnym buildzie.** Nie pushuj nieprzetestowanych zmian.
`scripts/apply-on-vps.sh` to starsza ścieżka (wgranie na VPS). Główną ścieżką jest dziś `vercel-build.sh`.

**Uwaga (stan 3.11.2026):** Build Command NIE jest zapisany na stałe w ustawieniach projektu (API zwraca 403 na zmianę ustawień).
Redeploy z panelu albo deploy z VPS buduje bez nakładki (404 na podstronach, stara strona główna). Działa tylko redeploy przez API
z `projectSettings.buildCommand` w treści żądania — pełna procedura, weryfikacja i zasady edycji: `docs/WDROZENIA.md`.
Zadanie cykliczne właściciela o 05:52 UTC naprawia poranny deploy z crona.

## Powiązane

- Baza Astro: `~/Developer/wielki-luk-web` (źródło prawdy: VPS `/root/wielki-luk-web`). Zobacz tamtejszy CLAUDE.md.
- Stan na 2026-11-02: 4 strony z tego repo są identyczne bajt w bajt z domeną.

## Weryfikacja

Brak testów. Po buildzie porównaj z domeną, np.
`curl -s -o /tmp/x.html https://wielki-luk.pl/tokio-palau/ && cmp public/tokio-palau/index.html /tmp/x.html`.
