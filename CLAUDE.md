# CLAUDE.md — wielki-luk-tokio-palau (nakładka na wielki-luk.pl)

## Czym jest ten folder

Statyczne strony serwisu **wielki-luk.pl**, które nie pochodzą z bazy Astro:
`/tokio-palau/` (plan Tokio → Palau → Seul, 4–23.11.2026, powrót rano 23.11), `/tokio-palau/mapa/`, `/palau/`
oraz nowa strona główna PL `home/index.html` („dwa zegary”). Szczegóły plików są w `README.md`.

## Jak trafia na produkcję (stan 3.11.2026)

**Produkcja = VPS Hostinger (187.124.166.64, Caddy). Vercel jest nieaktualny — nie używać.**
Codziennie ok. 05:35 UTC cron na VPS buduje projekt Astro `/root/wielki-luk-web` i dokleja nakładkę z gałęzi `main`
tego repo (`public/tokio-palau`, `public/palau`). Strona główna produkcji jest w projekcie Astro na VPS, nie w `home/`.

**Push na `main` = zmiana na wielki-luk.pl następnego ranka ok. 06:35 (Warszawa).** Nie pushuj nieprzetestowanych zmian.
Procedura, testy i weryfikacja: `docs/WDROZENIA.md`. Natychmiastowe wdrożenie wymaga SSH na VPS (właściciel).

## Powiązane

- Baza Astro: `~/Developer/wielki-luk-web` (źródło prawdy: VPS `/root/wielki-luk-web`). Zobacz tamtejszy CLAUDE.md.
- Stan na 2026-11-02: 4 strony z tego repo są identyczne bajt w bajt z domeną.

## Weryfikacja

Brak testów. Po buildzie porównaj z domeną, np.
`curl -s -o /tmp/x.html https://wielki-luk.pl/tokio-palau/ && cmp public/tokio-palau/index.html /tmp/x.html`.
