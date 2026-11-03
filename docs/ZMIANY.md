# ZMIANY — dziennik poprawek nakładki wielki-luk.pl

Najnowsze na górze. Każdy agent (Claude, Kimi, inny) dopisuje wpis w tym samym commicie, w którym robi zmianę.
Produkcja = VPS Hostinger; cron publikuje `main` codziennie ok. 05:35 UTC (06:35 Warszawa). `home/` cron NIE publikuje.

## Szablon (skopiuj)

```
## RRRR-MM-DD HH:MM — <Agent> — <tytuł jednym zdaniem>
- Co: <1–3 zdania, co się zmieniło i dlaczego (kto zlecił)>
- Pliki: <lista ścieżek>
- Sprawdzone: <syntax ok mapy / node --check / podgląd lokalny / nic>
- Produkcja: <po cronie DD.MM ok. 06:35 | wymaga ręcznego wdrożenia na VPS (home/) | już wdrożone ręcznie>
- Commit: <sha>
```

---

## 2026-11-03 16:30 — Claude — Merge PR #1 i #2, dokumentacja wdrożeń na Hostingerze, dziennik zmian
- Co: Zmergowane PR #1 (overlay-lib.sh, apply-on-vps.sh kopiuje też /palau/) i PR #2 (home/index.html = strona główna v3, zgodna z produkcją). `docs/WDROZENIA.md` i `CLAUDE.md` opisują produkcję na VPS Hostinger (Caddy, cron ~05:35 UTC), Vercel oznaczony jako nieaktualny. Nowy plik `docs/ZMIANY.md` i sekcja 7 w WDROZENIA.md (obowiązek raportowania).
- Pliki: docs/WDROZENIA.md, docs/ZMIANY.md, CLAUDE.md, scripts/*, home/index.html
- Sprawdzone: `bash -n` skryptów OK; mergowalność bez konfliktów
- Produkcja: skrypty — po cronie 4.11 ok. 06:35; home/ — bez zmian na produkcji (już jest v3)
- Commit: (ten)

## 2026-11-03 15:52 — Claude — Bez Tokyo Banana na liście zakupów /palau/
- Co: Usunięte 4 wzmianki „Tokyo Banana” (lista zakupów, plan 10.11, mapa trasy, kalkulator bagażu) na zlecenie właściciela.
- Pliki: public/palau/assets/index-L67O7rc1.js
- Sprawdzone: node --check OK
- Produkcja: po cronie 4.11 ok. 06:35
- Commit: 3dcf8f1

## 2026-11-03 15:4x — Claude — /palau/#/tokio przekierowuje do planu /tokio-palau/#tokio
- Co: Teksty o Tokio ze strony Kimi (własny, sprzeczny plan dni) wycięte przez przekierowanie trasy SPA do jedynego obowiązującego planu.
- Pliki: public/palau/assets/index-L67O7rc1.js (komponent WLR zamiast e9)
- Sprawdzone: node --check OK, test Playwright (przekierowanie działa, inne trasy bez zmian)
- Produkcja: po cronie 4.11 ok. 06:35
- Commit: b009a22

## 2026-11-03 15:47 — (PR #3, agent właściciela) — Zegary dworcowe retro
- Co: Tablica odjazdów z odliczaniem na stronie planu, mini-tablica w panelu mapy, chip na /palau/. Same dodatki, bez bibliotek.
- Pliki: public/tokio-palau/index.html, public/tokio-palau/mapa/index.html, public/palau/index.html
- Sprawdzone: wg opisu PR — node --check, zrzuty Chromium
- Produkcja: już na wielki-luk.pl (build 3.11 05:35 UTC)
- Commit: baa396a

## 2026-11-02 — Claude — Dziennik podróży: Traveler's Notebook, SELPHY z Polski; goshuin-chō; Mexico 66; bez LEGO i bez aparatu analogowego
- Co: 6.11 Hands Shinjuku (TN Regular + wkłady 003/025, Pigma Micron), 10.11 TRAVELER'S FACTORY STATION; 7.11 Sensō-ji goshuin-chō z Wielką Falą; 8.11 Onitsuka Tiger Mexico 66; usunięte LEGO i Contax.
- Pliki: public/tokio-palau/index.html, public/tokio-palau/mapa/index.html, home/index.html (nieaktualne po PR #2), public/palau/assets/index-L67O7rc1.js
- Produkcja: na wielki-luk.pl od 3.11 05:35 UTC
- Commity: ddb30c1, 993a6e3, 1e8f30b, a79d1df, 9ba04d4

## 2026-11-01 — Claude — Seul 20–23.11 (powrót rano 23.11), mapa Seulu, 20 dni wyprawy
- Co: Region Seul na mapie (metro linie 1–4 + AREX), 22.11 Seongsu/Gwangjang/DDP, 23.11 wylot o świcie; wszystkie daty 4–23.11.
- Pliki: public/tokio-palau/mapa/index.html, public/tokio-palau/index.html, public/palau/assets/*.js
- Produkcja: na wielki-luk.pl
- Commity: 82eb333, 8bc8268
