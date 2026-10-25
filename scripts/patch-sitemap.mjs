#!/usr/bin/env node
// Dopisuje /tokio-palau/ do public/sitemap.xml (idempotentnie).
import { existsSync, readFileSync, writeFileSync } from 'node:fs';

const p = process.argv[2];
if (!p || !existsSync(p)) {
  console.log('sitemap.xml: brak pliku — pomijam');
  process.exit(0);
}
const s = readFileSync(p, 'utf8');
if (s.includes('tokio-palau')) {
  console.log('sitemap.xml: wpis już jest — pomijam');
  process.exit(0);
}
if (!s.includes('</urlset>')) {
  console.error('sitemap.xml: brak </urlset>');
  process.exit(1);
}
const entry =
  '  <url><loc>https://wielki-luk.pl/tokio-palau/</loc><lastmod>2026-10-25</lastmod><changefreq>weekly</changefreq></url>\n';
writeFileSync(p, s.replace('</urlset>', entry + '</urlset>'), 'utf8');
console.log('sitemap.xml: dodano /tokio-palau/');
