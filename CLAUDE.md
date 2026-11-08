# CLAUDE.md — wielki-luk-tokio-palau (nakładka na wielki-luk.pl)

## Czym jest ten folder

Statyczne strony serwisu **wielki-luk.pl**, które nie pochodzą z bazy Astro:
`/tokio-palau/` (plan Tokio → Palau → Seul, 4–23.11.2026, powrót rano 23.11), `/tokio-palau/mapa/`, `/palau/`
oraz nowa strona główna PL `home/index.html` („dwa zegary”). Szczegóły plików są w `README.md`.

## Jak trafia na produkcję (stan 7.11.2026) — TO REPO JEST ARCHIWALNE

**Nakładka z tego repo NIE trafia już na wielki-luk.pl.** Od 3.11.2026 plan Tokio–Palau–Seul żyje w projekcie Astro
`barszczxl2/wielki-luk-web` jako statyczne pliki `public/podroze/tokio-palau-seul/{index.html,mapa/index.html}`,
a produkcja to `https://wielki-luk.pl/podroze/tokio-palau-seul/` (stare `/tokio-palau/`, `/tokio-palau/mapa/`, `/palau/` mają 301).
Cron na VPS buduje z czystego `git archive HEAD` tamtego projektu, więc `scripts/apply-on-vps.sh` z tego repo kopiuje pliki
w miejsce, którego build nie widzi, i wywala się na brakującym `HomePage.astro`. Push na `main` tutaj niczego nie publikuje.

**Publikacja = commit + `git push origin main` w `wielki-luk-web`** (cron `deploy-from-git.sh` co 10 min; natychmiast na VPS:
`FORCE=1 /root/wielki-luk-web/scripts/deploy-from-git.sh`). Zmiany zrobione tutaj trzeba przenieść ręcznie do tamtych plików
(ta sama struktura HTML, inna ścieżka; uwaga na rozjazdy, np. nocleg: tam RS Hotel Matsugaya 4-25-7, tu RS Hotel, ale wciąż pod adresem Kojima 1-1-2).
Szczegóły i zasady: `CLAUDE.md` w `wielki-luk-web`. Ostatnie przeniesienie: 16e5cdb → wielki-luk-web 7747775 (7.11.2026).

## Powiązane

- Baza Astro: `~/Developer/wielki-luk-web` (źródło prawdy: VPS `/root/wielki-luk-web`). Zobacz tamtejszy CLAUDE.md.
- Stan na 2026-11-02: 4 strony z tego repo są identyczne bajt w bajt z domeną.

## Weryfikacja

Brak testów. Po buildzie porównaj z domeną, np.
`curl -s -o /tmp/x.html https://wielki-luk.pl/tokio-palau/ && cmp public/tokio-palau/index.html /tmp/x.html`.
