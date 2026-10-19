#!/usr/bin/env python3
"""Dodaje kartę podróży Tokio–Palau do src/components/HomePage.astro (idempotentnie).

Użycie: patch-homepage.py <HomePage.astro> <showcase-card.html>
Karta trafia tuż za pierwszym elementem <a class="showcase ...>...</a>.
Jeśli komponent ma prop `lang`, karta pokazuje się tylko na polskiej stronie.
"""
import re
import sys
from pathlib import Path

astro = Path(sys.argv[1])
card = Path(sys.argv[2]).read_text(encoding="utf-8").strip()
src = astro.read_text(encoding="utf-8")

if "tokio-palau" in src:
    print("HomePage.astro: karta już jest — pomijam")
    sys.exit(0)

m = re.search(r'<a\s+class="showcase', src)
if not m:
    sys.exit("HomePage.astro: nie znalazłem <a class=\"showcase\"> — dodaj kartę ręcznie z patch/showcase-card.html")
end = src.find("</a>", m.start())
if end < 0:
    sys.exit("HomePage.astro: brak </a> po karcie showcase")
end += len("</a>")

parts = src.split("---", 2)
frontmatter = parts[1] if len(parts) >= 3 else ""
has_lang = re.search(r"\blang\b", frontmatter) is not None
insert = ("\n{lang === 'pl' && (\n" + card + "\n)}\n") if has_lang else ("\n" + card + "\n")

astro.write_text(src[:end] + insert + src[end:], encoding="utf-8")
print(f"HomePage.astro: dodano kartę ({'tylko PL' if has_lang else 'wszystkie języki'})")
