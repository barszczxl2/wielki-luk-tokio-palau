# wielki-luk.pl — instrukcja wdrażania poprawek (dla agenta AI lub człowieka)

Stan na 3.11.2026. Właściciel: Jan (barszczxl2). Czytaj do końca, zanim coś zmienisz.

## 1. Jak zbudowana jest strona

Są DWA źródła, których nie wolno mylić:

| Co | Gdzie | Kto zarządza |
|---|---|---|
| Serwis Astro (Bangkok–Ha Long, wersje FR/EL, layout, CSS `/_astro/`) | VPS właściciela, katalog `/root/wielki-luk-web`; codziennie o 05:36 UTC cron robi `vercel deploy --prod` | **nie ruszaj z tego repo** |
| **Nakładka** (overlay): strona główna PL, `/tokio-palau/`, `/tokio-palau/mapa/`, `/palau/` | to repo: `https://github.com/barszczxl2/wielki-luk-tokio-palau` (branch `main`) | tu wprowadzasz poprawki |

Przy każdym buildzie na Vercelu skrypt `scripts/vercel-build.sh` pobiera `main` tego repo jako tarball z `codeload.github.com`, kopiuje pliki do projektu Astro, buduje i **podmienia `dist/index.html`** na `home/index.html`. Czyli: cokolwiek jest w `main`, ląduje na produkcji przy następnym buildzie. Nie ma stagingu.

```
home/index.html                   strona główna PL (dwa zegary, rozwijane podróże, linki do map) — czysty HTML/CSS/JS, bez builda
public/tokio-palau/index.html     plan Tokio–Palau–Seul (dni, zakupy, noclegi, formalności, pakowanie) — czysty HTML
public/tokio-palau/mapa/index.html mapa Leaflet; dane w obiekcie `var D = {tokio, palau, seul}` w <script>
public/tokio-palau/img/           zdjęcia (Wikimedia Commons, licencje w attribution.json)
public/palau/                     strona-wizytówka wyprawy (SPA React/Vite zbudowana przez Kimi, hash-router: /palau/#/plan, #/zakupy, #/noclegi, #/praktyczne, #/seul; trasa #/tokio przekierowuje do /tokio-palau/#tokio)
public/palau/assets/index-*.js    zminifikowany bundle — edytuj TYLKO podmianą literalnych stringów, nie przebudowuj
patch/showcase-card.html          zapasowa karta na starą stronę główną (nieużywana, gdy działa home/index.html)
scripts/vercel-build.sh           build na Vercelu — zmieniaj tylko, jeśli wiesz, co robisz; musi ZAWSZE kończyć się działającym buildem (ma fallback do `npm run build`)
scripts/patch-homepage.mjs        dokleja kartę do HomePage.astro (zapasowe)
scripts/patch-sitemap.mjs         dopisuje /palau/ i /tokio-palau/ do sitemap.xml
```

## 2. Zasady

1. **Jeden plan, jedna prawda.** Plan dni obowiązujący jest w `public/tokio-palau/index.html` (sekcje `#tokio`, `#palau`, `#seul`) i w danych mapy `D` w `public/tokio-palau/mapa/index.html`. Każda zmiana dat, godzin, miejsc musi trafić do OBU plików, a jeśli dotyczy całej wyprawy (daty wylotu/powrotu, liczba nocy) — także do `home/index.html` i stringów w `public/palau/assets/index-*.js`.
2. **Daty wyprawy:** wylot 4.11.2026 22:40 (standby), Tokio 5–10.11 (6 nocy, Asakusa), Palau 11–19.11, Seul 20–23.11 (3 noce, Myeongdong), powrót rano 23.11. Razem 20 dni.
3. **Styl tekstów:** rzeczowo, konkretnie, po polsku, bez marketingowego „neonowego labiryntu”, bez wykrzykników, bez emoji w zdaniach (emoji tylko jako ikony w etykietach). Ceny w ¥ i zł obok siebie (kurs NBP, 1 JPY ≈ 0,025 zł, 1 KRW ≈ 0,003 zł, 1 USD ≈ 3,92 zł). Nazwy japońskie i koreańskie w transkrypcji łacińskiej, stacje metra z numerami (G19, M08, Line 4 424).
4. **Nie ruszaj:** wersji FR i EL, plików w `/_astro/`, niczego poza tym repo. Nie dodawaj zewnętrznych skryptów poza już używanymi (Leaflet z cdnjs, Google Fonts, Esri/OSM tiles, Vercel Insights).
5. **Po każdej zmianie w mapie** sprawdź składnię JS (polecenie niżej). Błąd składni = pusta mapa na produkcji.
6. Nie commituj sekretów. Token Vercela trzymaj w zmiennej środowiskowej, nigdy w repo.

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

## 4. Jak wdrożyć na produkcję

### Wariant A — natychmiast (Vercel API, potrzebny token)
Token: właściciel tworzy go w Vercel → Account Settings → Tokens (scope: team `barszczxl2's projects`) i przekazuje poza repo.

```bash
export VERCEL_TOKEN=...   # od właściciela
TEAM=team_4CxGxNBx6xi22MtCK8AftsOc
PROJECT=prj_oAIcPYPZXQysuXAAdTH4PkGFLcM6

# 1) id ostatniego wdrożenia produkcyjnego
LAST=$(curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v6/deployments?projectId=$PROJECT&teamId=$TEAM&target=production&limit=1" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['deployments'][0]['uid'])")

# 2) redeploy Z NADPISANYM BUILD COMMAND (bez tego nakładka się nie zbuduje!)
curl -s -X POST -H "Authorization: Bearer $VERCEL_TOKEN" -H "Content-Type: application/json" \
  "https://api.vercel.com/v13/deployments?teamId=$TEAM&forceNew=1" \
  -d "{\"name\":\"wielki-luk-web\",\"project\":\"wielki-luk-web\",\"deploymentId\":\"$LAST\",\"target\":\"production\",\"projectSettings\":{\"framework\":\"astro\",\"buildCommand\":\"curl -fsSL https://raw.githubusercontent.com/barszczxl2/wielki-luk-tokio-palau/main/scripts/vercel-build.sh -o /tmp/wlb.sh && bash /tmp/wlb.sh || npm run build\"}}" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('id'),d.get('url'),d.get('readyState'))"
```

Build trwa 1–3 min. Potem:
```bash
# stan i aliasy (ma być READY i alias wielki-luk.pl)
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" "https://api.vercel.com/v13/deployments/<ID>?teamId=$TEAM" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['readyState'],d.get('alias'))"
# w logu builda MUSI być linia: [nakładka tokio-palau] build z nakładką OK
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" "https://api.vercel.com/v3/deployments/<ID>/events?teamId=$TEAM" | grep -o "nakładka tokio-palau[^\"]*"
# kontrola na żywo
curl -s https://wielki-luk.pl/ | grep -c "Dwa zegary"
curl -s https://wielki-luk.pl/tokio-palau/mapa/ | grep -c "seul:{"
```

Ważne: **`projectSettings.buildCommand` w każdym wywołaniu jest obowiązkowy.** Ustawienie „Build Command” w panelu projektu nie jest zapisane na stałe (API zwraca 403 na zmianę ustawień projektu), więc zwykły „Redeploy” z panelu albo deploy z VPS buduje stronę BEZ nakładki — podstrony znikają, wraca stara strona główna. Jeśli tak się stanie, wykonaj krok 2 powyżej.

### Wariant B — bez tokena (czekanie)
Wystarczy `git push`. Codziennie o 05:36 UTC VPS robi deploy bez nakładki, a o 05:52 UTC zadanie cykliczne właściciela sprawdza log i robi redeploy z nakładką. Zmiany są na produkcji następnego ranka ok. 06:00 UTC (07:00 w Warszawie). Właściciel może też poprosić Claude'a o natychmiastowy redeploy.

## 5. Gdy coś pójdzie nie tak

- **404 na /tokio-palau/ albo stara strona główna** → wdrożenie bez nakładki; zrób redeploy z wariantu A.
- **Pusta mapa** → błąd składni w `D`; sprawdź testem z p. 3, popraw, push, redeploy.
- **Build ERROR** → `vercel-build.sh` ma fallback: jeśli build z nakładką padnie, buduje bez niej (strona działa, ale bez podstron). Zobacz log eventów, popraw przyczynę.
- **Cofnięcie zmiany** → `git revert <sha>`, push, redeploy. Nie używaj „Rollback” w panelu Vercela — przywróci wdrożenie, ale kolejny cron i tak zbuduje z `main`.

## 6. Czego NIE robić

- Nie zmieniaj `vercel-build.sh` tak, żeby mógł zwrócić błąd — zawsze ma kończyć się działającym buildem.
- Nie przebudowuj SPA `/palau/` od zera bez zgody właściciela; podmieniaj stringi w bundlu.
- Nie dopisuj nowych etapów ani zakupów „od siebie”. Plan ustala właściciel; agent wdraża.
- Nie publikuj danych osobowych, numerów rezerwacji, numerów biletów.
