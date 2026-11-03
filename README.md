# wielki-luk.pl — podstrona Tokio · Palau · Seul (5–23.11.2026)

Statyczna podstrona planu podróży dla serwisu wielki-luk.pl (Astro, Vercel).

```
public/tokio-palau/index.html   strona (plan dni, mapa, zakupy, noclegi, formalności)
public/tokio-palau/mapa/        mapa interaktywna: Tokio, Palau, Seul (#tokio / #palau / #seul)
public/palau/                   strona wyprawy z zegarem (adaptacja Kimi)
public/tokio-palau/img/         28 zdjęć z Wikimedia Commons, zmniejszone do 1000 px
public/tokio-palau/img/attribution.json   autorzy i licencje zdjęć
home/index.html                 nowa strona główna PL: dwa zegary (Tokio–Palau–Seul, Bangkok–Ha Long), rozwijane podróże, linki do map
patch/showcase-card.html        karta podróży na starą stronę główną (zapasowo)
scripts/vercel-build.sh         Build Command projektu na Vercelu: pobiera to repo i dokleja nakładkę do każdego builda
scripts/apply-on-vps.sh         (opcjonalnie) wgranie nakładki do /root/wielki-luk-web na VPS + deploy
scripts/overlay-lib.sh          wspólne kroki nakładki dla obu skryptów powyżej
scripts/patch-homepage.mjs      dodaje kartę do HomePage.astro (idempotentnie)
scripts/patch-sitemap.mjs       dopisuje /palau/ i /tokio-palau/ do sitemap.xml (idempotentnie)
```

## Wdrożenie na Vercelu (domyślne)

W ustawieniach projektu `wielki-luk-web` jako Build Command:

```bash
curl -fsSL https://raw.githubusercontent.com/barszczxl2/wielki-luk-tokio-palau/main/scripts/vercel-build.sh -o /tmp/wlb.sh && bash /tmp/wlb.sh || npm run build
```

Skrypt pobiera `main` tego repo, kopiuje `public/tokio-palau` i `public/palau`, dodaje kartę do
`HomePage.astro`, dopisuje adresy do sitemapy, buduje i podmienia `dist/index.html` na `home/index.html`.
Gdy cokolwiek się nie uda, buduje stronę bez nakładki. Udany build kończy się w logu linią
`[nakładka tokio-palau] build z nakładką OK`.

## Wdrożenie przez VPS (opcjonalnie, jako root)

```bash
cd /root && rm -rf wielki-luk-tokio-palau && git clone https://github.com/barszczxl2/wielki-luk-tokio-palau.git && bash wielki-luk-tokio-palau/scripts/apply-on-vps.sh
```

Skrypt kopiuje `public/tokio-palau` i `public/palau`, dodaje kartę do `src/components/HomePage.astro`
(tylko dla `lang === 'pl'`), dopisuje adresy do `public/sitemap.xml`, buduje i publikuje.
Jest idempotentny — można go uruchamiać wielokrotnie.

## Licencje zdjęć

Wszystkie zdjęcia pochodzą z Wikimedia Commons na licencjach CC BY / CC BY-SA / CC0 / domena publiczna.
Autor i licencja są podane w podpisie każdego zdjęcia na stronie oraz w `img/attribution.json`.
