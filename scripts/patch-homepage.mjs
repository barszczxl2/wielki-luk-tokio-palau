#!/usr/bin/env node
// Dodaje kartę podróży Tokio–Palau do src/components/HomePage.astro (idempotentnie).
// Użycie: node patch-homepage.mjs <HomePage.astro> <showcase-card.html>
// Karta trafia tuż przed pierwszym elementem <a class="showcase ...>.
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
// Karta Tokio–Palau idzie PRZED pierwszą kartą showcase (wyjazd jest bliżej).
const cut = m.index;
const parts = src.split('---');
const frontmatter = parts.length >= 3 ? parts[1] : '';
const hasLang = /\blang\b/.test(frontmatter);
const insert = hasLang ? `{lang === 'pl' && (\n${card}\n)}\n` : `${card}\n`;
writeFileSync(astroPath, src.slice(0, cut) + insert + src.slice(cut), 'utf8');
console.log(`HomePage.astro: dodano kartę (${hasLang ? 'tylko PL' : 'wszystkie języki'})`);
