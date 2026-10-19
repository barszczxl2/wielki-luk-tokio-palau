#!/usr/bin/env python3
"""Dopisuje /tokio-palau/ do public/sitemap.xml (idempotentnie)."""
import sys
from pathlib import Path

p = Path(sys.argv[1])
if not p.exists():
    print("sitemap.xml: brak pliku — pomijam")
    sys.exit(0)
s = p.read_text(encoding="utf-8")
if "tokio-palau" in s:
    print("sitemap.xml: wpis już jest — pomijam")
    sys.exit(0)
entry = "  <url><loc>https://wielki-luk.pl/tokio-palau/</loc><lastmod>2026-10-19</lastmod><changefreq>weekly</changefreq></url>\n"
if "</urlset>" not in s:
    sys.exit("sitemap.xml: brak </urlset>")
p.write_text(s.replace("</urlset>", entry + "</urlset>"), encoding="utf-8")
print("sitemap.xml: dodano /tokio-palau/")
