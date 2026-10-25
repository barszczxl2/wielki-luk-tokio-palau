#!/usr/bin/env node
// Dodaje kartę podróży Tokio–Palau do src/components/HomePage.astro (idempotentnie).
// Użycie: node patch-homepage.mjs <HomePage.astro> <showcase-card.html>
// Karta trafia tuż za pierwszym elementem <a class="showcase ...>...</a>.
// Jeśli komponent ma prop `lang`, karta pokazuje się tylko na polskiej stronie.
import { readFileSync, writeFileSync } from 'node:fs';

const [, , astroPath, cardPath] = process.argv;
if (!astroPath || !cardPath) {
  console.error('użycie: patch-homepage.mjs <HomePage.astro> <showcase-card.html>');
  process.exit(2);
}
const src = readFileSync(astroPath, 'utf8');
const card = readFileSync(cardPath, 'utf8').trim();

if (src.includes('tokio-palau')) {
  console.log('HomePage.astro: karta już jest — pomijam');
  process.exit(0);
}
const m = /<a\s+class="showcase/.exec(src);
if (!m) {
  console.error('HomePage.astro: nie znalazłem <a class="showcase"> — karta nie dodana');
  process.exit(1);
}
const end = src.indexOf('</a>', m.index);
if (end < 0) {
  console.error('HomePage.astro: brak </a> po karcie showcase');
  process.exit(1);
}
const cut = end + '</a>'.length;
const parts = src.split('---');
const frontmatter = parts.length >= 3 ? parts[1] : '';
const hasLang = /\blang\b/.test(frontmatter);
const insert = hasLang ? `\n{lang === 'pl' && (\n${card}\n)}\n` : `\n${card}\n`;
writeFileSync(astroPath, src.slice(0, cut) + insert + src.slice(cut), 'utf8');
console.log(`HomePage.astro: dodano kartę (${hasLang ? 'tylko PL' : 'wszystkie języki'})`);
