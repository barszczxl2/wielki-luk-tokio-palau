# wielki-luk.pl — instrukcja wdrażania poprawek (dla agenta AI lub człowieka)

Stan na 3.11.2026. Właściciel: Jan (barszczxl2). Czytaj do końca, zanim coś zmienisz.

## 1. Jak zbudowana jest strona

Są DWA źródła, których nie wolno mylić:

| Co | Gdzie | Kto zarządza |
|---|---|---|
| Serwis Astro (strona główna, Bangkok–Ha Long, wersje FR/EL, layout, CSS `/_astro/`) | VPS Hostinger właściciela, katalog `/root/wielki-luk-web`, serwowany przez Caddy; codziennie ok. 05:35 UTC cron buduje stronę | **nie ruszaj z tego repo** |
| **Nakładka** (overlay): strona główna PL, `/tokio-palau/`, `/tokio-palau/mapa/`, `/palau/` | to repo: `https://github.com/barszczxl2/wielki-luk-tokio-palau` (branch `main`) | tu wprowadzasz poprawki |

Przy codziennym buildzie na VPS nakładka z `main` tego repo jest kopiowana do projektu Astro (`public/tokio-palau`, `public/palau`). Czyli: cokolwiek jest w `main`, ląduje na produkcji przy następnym buildzie. Nie ma stagingu. (`scripts/vercel-build.sh` to pozostałość po Vercelu — nieużywany na produkcji.)

```
home/index.html                   strona główna PL (v3: jasna szata, licznik, łuk trasy) — ta sama wersja, co na produkcji; NIE jest wdrażana przez cron, zmiany w niej trzeba ręcznie przenieść do projektu Astro na VPS
public/tokio-palau/index.html     plan Tokio–Palau–Seul (dni, zakupy, noclegi, formalności, pakowanie) — czysty HTML
public/tokio-palau/mapa/index.html mapa Leaflet; dane w obiekcie `var D = {tokio, palau, seul}` w <script>
public/tokio-palau/img/           zdjęcia (Wikimedia Commons, licencje w attribution.json)
public/palau/                     strona-wizytówka wyprawy (SPA React/Vite zbudowana przez Kimi, hash-router: /palau/#/plan, #/zakupy, #/noclegi, #/praktyczne, #/seul; trasa #/tokio przekierowuje do /tokio-palau/#tokio)
public/palau/assets/index-*.js    zminifikowany bundle — edytuj TYLKO podmianą literalnych stringów, nie przebudowuj
patch/showcase-card.html          zapasowa karta na starą stronę główną (nieużywana, gdy działa home/index.html)
scripts/apply-on-vps.sh + overlay-lib.sh   skrypty używane przez cron na VPS (kopiują nakładkę do projektu Astro) — zmieniaj tylko przez PR
scripts/vercel-build.sh           pozostałość po Vercelu, nieużywana
scripts/patch-homepage.mjs        dokleja kartę do HomePage.astro (zapasowe)
scripts/patch-sitemap.mjs         dopisuje /palau/ i /tokio-palau/ do sitemap.xml
```

## 2. Zasady

1. **Jeden plan, jedna prawda.** Plan dni obowiązujący jest w `public/tokio-palau/index.html` (sekcje `#tokio`, `#palau`, `#seul`) i w danych mapy `D` w `public/tokio-palau/mapa/index.html`. Każda zmiana dat, godzin, miejsc musi trafić do OBU plików, a jeśli dotyczy całej wyprawy (daty wylotu/powrotu, liczba nocy) — także do `home/index.html` i stringów w `public/palau/assets/index-*.js`.
2. **Daty wyprawy:** wylot 4.11.2026 22:40 (standby), Tokio 5–10.11 (6 nocy, Asakusa), Palau 11–19.11, Seul 20–23.11 (3 noce, Myeongdong), powrót rano 23.11. Razem 20 dni.
3. **Styl tekstów:** rzeczowo, konkretnie, po polsku, bez marketingowego „neonowego labiryntu”, bez wykrzykników, bez emoji w zdaniach (emoji tylko jako ikony w etykietach). Ceny w ¥ i zł obok siebie (kurs NBP, 1 JPY ≈ 0,025 zł, 1 KRW ≈ 0,003 zł, 1 USD ≈ 3,92 zł). Nazwy japońskie i koreańskie w transkrypcji łacińskiej, stacje metra z numerami (G19, M08, Line 4 424).
4. **Nie ruszaj:** wersji FR i EL, plików w `/_astro/`, niczego poza tym repo. Nie dodawaj zewnętrznych skryptów poza już używanymi (Leaflet z cdnjs, Google Fonts, Esri/OSM tiles, Vercel Insights).
5. **Po każdej zmianie w mapie** sprawdź składnię JS (polecenie niżej). Błąd składni = pusta mapa na produkcji.
6. Nie commituj sekretów (klucze SSH do VPS, tokeny).

## 3. Jak wprowadzić poprawkę

```bash
git clone https://github.com/barszczxl2/wielki-luk-tokio-palau.git
cd wielki-luk-tokio-palau
# ... edycja plików ...

# test składni mapy (musi wypisać "syntax ok")
node -e "const h=require('fs').readFileSync('public/tokio-palau/mapa/index.html','utf8');const m=h.match(/<script>\n\(function\(\)\{([\s\S]*)\}\)\(\);\n<\/script>/);new Function(m[1]);console.log('syntax ok')"
# test bundla /palau/ po podmianie stringów
node --check public/palau/assets/index-*.js

# podgląd lokalny (mapa potrzebuje internetu do kafelków i Leafleta)
cd public && python3 -m http.server 8765   # http://localhost:8765/tokio-palau/mapa/  oraz /palau/
# strona główna: python3 -m http.server 8766 w katalogu home/

git add -A
git commit -m "Krótki opis po polsku"
git push origin main
```

Po pushu odczekaj ok. 1–2 min, aż `codeload.github.com` poda nowy tarball:
```bash
curl -fsSL https://codeload.github.com/barszczxl2/wielki-luk-tokio-palau/tar.gz/refs/heads/main | tar xz -O --wildcards '*/home/index.html' | grep -c "TWÓJ_NOWY_TEKST"
```

## 4. Jak wdrożyć na produkcję (stan 3.11.2026 — HOSTINGER, nie Vercel)

**Domena wielki-luk.pl wskazuje na VPS Hostinger (187.124.166.64, serwer Caddy). Vercel jest nieaktualny** — projekt tam istnieje, ale nikt go nie ogląda; nie używaj API Vercela.

Jak to działa dziś (z nagłówków `Last-Modified` i opisów PR #1/#2):
- Na VPS leży projekt Astro `/root/wielki-luk-web` (źródło strony głównej, Bangkok–Ha Long, FR/EL).
- Codziennie ok. **05:35 UTC** cron na VPS buduje stronę i dokleja nakładkę z gałęzi `main` tego repo (`scripts/apply-on-vps.sh` / `overlay-lib.sh`): kopiuje `public/tokio-palau` i `public/palau`. **Nie kopiuje `home/`** — strona główna na produkcji jest zarządzana w projekcie Astro na VPS (aktualnie wersja z PR #2 „jasna szata, licznik, łuk trasy”).
- Czyli: **push na `main` = zmiana na wielki-luk.pl następnego ranka ok. 06:35 czasu warszawskiego.** Dotyczy `/tokio-palau/`, `/tokio-palau/mapa/`, `/palau/`.

Wdrożenie natychmiastowe: tylko z dostępem SSH do VPS (ma go właściciel): wejść na VPS i uruchomić ten sam skrypt, który odpala cron (`crontab -l` pokaże ścieżkę; w repo odpowiada mu `scripts/apply-on-vps.sh`). Agent bez SSH czeka na cron.

Weryfikacja po wdrożeniu (z dowolnego komputera):
```bash
curl -sI https://wielki-luk.pl/tokio-palau/ | grep -i last-modified     # data ostatniego builda
curl -s https://wielki-luk.pl/tokio-palau/mapa/ | grep -c "seul:{"       # 1 = mapa z Seulem
curl -s https://wielki-luk.pl/palau/assets/index-L67O7rc1.js | grep -c "function WLR"   # 1 = przekierowanie /tokio aktywne
```

## 5. Gdy coś pójdzie nie tak

- **404 na /tokio-palau/** → cron na VPS nie dokleił nakładki; sprawdź log crona na VPS i uruchom `apply-on-vps.sh` ręcznie.
- **Pusta mapa** → błąd składni w `D`; sprawdź testem z p. 3, popraw, push, redeploy.
- **Cofnięcie zmiany** → `git revert <sha>`, push; wejdzie przy następnym cronie (albo ręcznie na VPS).

## 6. Czego NIE robić

- Nie zmieniaj `apply-on-vps.sh` tak, żeby mógł przerwać build na VPS.
- Nie przebudowuj SPA `/palau/` od zera bez zgody właściciela; podmieniaj stringi w bundlu.
- Nie dopisuj nowych etapów ani zakupów „od siebie”. Plan ustala właściciel; agent wdraża.
- Nie publikuj danych osobowych, numerów rezerwacji, numerów biletów.

## 7. Raportowanie zmian — OBOWIĄZKOWE przy każdej poprawce

Właściciel i inni agenci (m.in. Claude) poznają Twoje zmiany z dwóch miejsc: **historii gita** i pliku **`docs/ZMIANY.md`**. Bez wpisu w `ZMIANY.md` poprawka jest uznana za nieudokumentowaną.

Procedura:
1. **Treść** (teksty, daty, ceny, punkty na mapie, stringi w `/palau/`): commit prosto na `main`.
   **Skrypty** (`scripts/*`), `CLAUDE.md`, struktura plików: osobna gałąź `kimi/<temat>` i Pull Request — merguje właściciel lub Claude.
2. W **tym samym commicie** dopisz wpis na górze `docs/ZMIANY.md` według szablonu z tego pliku (data, kto, co, pliki, jak sprawdzone, co wejdzie na produkcję i kiedy).
3. Komunikat commita po polsku, jedno zdanie co i gdzie, np. `Mapa: Seul 22.11 — Gwangjang przed DDP`. Na końcu dopisz linię `Agent: Kimi` (albo swoją nazwę).
4. Po pushu zwróć właścicielowi (do wklejenia w czacie) dokładnie to:
   - SHA commita i link `https://github.com/barszczxl2/wielki-luk-tokio-palau/commit/<sha>`,
   - skopiowany wpis z `docs/ZMIANY.md`,
   - wynik testów składni z sekcji 3 (dosłownie: `syntax ok` / wynik `node --check`),
   - zdanie: „na produkcji po cronie ok. 06:35 (Warszawa) dnia …” albo „wymaga ręcznego wdrożenia na VPS, bo dotyczy `home/`”.
5. Nie zwracasz całych plików HTML/JS w czacie — od tego jest repo. Jeśli zmiana jest duża, dołącz `git diff --stat`.

Zasada czytania dla agentów: zanim coś zmienisz, przeczytaj `git log --oneline -20` i pierwsze 5 wpisów `docs/ZMIANY.md`, żeby nie cofnąć cudzej świeżej poprawki.
