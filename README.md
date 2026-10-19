# wielki-luk.pl — podstrona Tokio · Palau · Seul (5–23.11.2026)

Statyczna podstrona planu podróży dla serwisu wielki-luk.pl (Astro, Vercel).

```
public/tokio-palau/index.html   strona (plan dni, mapa, zakupy, noclegi, formalności)
public/tokio-palau/img/         28 zdjęć z Wikimedia Commons, zmniejszone do 1000 px
public/tokio-palau/img/attribution.json   autorzy i licencje zdjęć
patch/showcase-card.html        karta podróży na stronę główną
scripts/apply-on-vps.sh         wgranie do /root/wielki-luk-web na VPS + deploy
```

## Wdrożenie na stałe (VPS, jako root)

```bash
cd /root && rm -rf wielki-luk-tokio-palau && git clone https://github.com/barszczxl2/wielki-luk-tokio-palau.git && bash wielki-luk-tokio-palau/scripts/apply-on-vps.sh
```

Skrypt kopiuje `public/tokio-palau`, dodaje kartę do `src/components/HomePage.astro`
(tylko dla `lang === 'pl'`), dopisuje adres do `public/sitemap.xml`, buduje i publikuje.
Jest idempotentny — można go uruchamiać wielokrotnie.

## Licencje zdjęć

Wszystkie zdjęcia pochodzą z Wikimedia Commons na licencjach CC BY / CC BY-SA / CC0 / domena publiczna.
Autor i licencja są podane w podpisie każdego zdjęcia na stronie oraz w `img/attribution.json`.
