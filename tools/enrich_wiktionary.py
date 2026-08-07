#!/usr/bin/env python3
"""
Wiktionary enrichment fetcher for DailySort (Phase 3).

Fills definition gaps WordNet can't cover (function words, colloquialisms, modern
terms) by fetching per-word structured data from kaikki.org (wiktextract output).
Parsed results are cached to tools/data/wiktionary/<word>.json so `build_wordlist.py`
can consume them offline and the artifact stays reproducible without re-fetching.

Wiktionary content is CC BY-SA — every def sourced here carries source="wiktionary"
and obliges the in-app attribution (see data/PROVENANCE.md). Run AFTER build_wordlist.py
has emitted the audit gap lists:

    tools/.venv/bin/python tools/enrich_wiktionary.py            # fill current gaps
    tools/.venv/bin/python tools/enrich_wiktionary.py word ...   # fetch specific words
"""
from __future__ import annotations

import json
import sys
import time
import urllib.request
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
CACHE = TOOLS / "data" / "wiktionary"
RAW = TOOLS / "data" / "wiktionary_raw"
AUDIT = TOOLS / "out" / "audit"
UA = "DailySort-wordlist-builder/1.0 (offline dictionary build; contact via repo)"

# senses tagged like these are not good "primary" meanings for a daily game
SKIP_TAGS = {"obsolete", "archaic", "dated", "rare", "offensive", "vulgar",
             "slur", "derogatory", "misspelling", "alternative spelling"}
POS_MAP = {"noun": "noun", "verb": "verb", "adj": "adjective", "adv": "adverb",
           "pron": "pronoun", "det": "determiner", "conj": "conjunction",
           "prep": "preposition", "intj": "interjection", "num": "numeral",
           "article": "determiner", "particle": "particle"}
# preference order when a word has several parts of speech
POS_RANK = ["noun", "verb", "adj", "adv", "pron", "det", "conj", "prep",
            "num", "intj", "particle", "article"]


def fetch_raw(word: str) -> list[dict]:
    raw_file = RAW / f"{word}.jsonl"
    if raw_file.exists():                        # reparse offline from cached raw
        body = raw_file.read_text()
    else:
        fc, tc = word[0], word[:2]
        url = f"https://kaikki.org/dictionary/English/meaning/{fc}/{tc}/{word}.jsonl"
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=20) as r:
            body = r.read().decode("utf-8")
    return [json.loads(line) for line in body.splitlines() if line.strip()]


def _glossed_senses(entry: dict) -> list[dict]:
    return [s for s in entry.get("senses", [])
            if (s.get("glosses") or s.get("raw_glosses"))]


def _pick_from(entry: dict, allow_tagged: bool) -> dict | None:
    pos = POS_MAP.get(entry.get("pos", ""), entry.get("pos", ""))
    for sense in entry.get("senses", []):
        tags = {t.lower() for t in sense.get("tags", [])}
        if not allow_tagged and tags & SKIP_TAGS:
            continue
        glosses = sense.get("glosses") or sense.get("raw_glosses")
        if not glosses or not glosses[0].strip():
            continue
        out = {"pos": pos, "definition": glosses[0].strip(), "source": "wiktionary"}
        for ex in sense.get("examples", []):
            if ex.get("text"):
                out["example"] = ex["text"].strip()
                break
        return out
    return None


def best_sense(entries: list[dict]) -> dict | None:
    """Pick the best (pos, definition, example) across a word's Wiktionary entries.
    Rank entries by richness (# glossed senses) then POS preference, so a modal's
    verb entry beats a one-off nonce-noun entry (could/shall). Fall back to
    archaic/rare senses only if nothing else exists (thine, shalt, quoth)."""
    def rank(e):
        p = e.get("pos", "")
        return (-len(_glossed_senses(e)),
                POS_RANK.index(p) if p in POS_RANK else len(POS_RANK))

    ordered = sorted(entries, key=rank)
    for allow_tagged in (False, True):
        for entry in ordered:
            picked = _pick_from(entry, allow_tagged)
            if picked:
                return picked
    return None


def enrich(word: str) -> dict | None:
    cache_file = CACHE / f"{word}.json"
    if cache_file.exists():
        return json.loads(cache_file.read_text())
    try:
        entries = fetch_raw(word)
    except Exception as e:                       # network / 404 — record and move on
        print(f"  {word}: fetch failed ({e})")
        return None
    (RAW).mkdir(parents=True, exist_ok=True)
    (RAW / f"{word}.jsonl").write_text(
        "\n".join(json.dumps(e) for e in entries) + "\n")
    result = best_sense(entries)
    if result is None:
        print(f"  {word}: no usable sense")
        return None
    result = {"word": word, **result}
    cache_file.write_text(json.dumps(result, indent=2) + "\n")
    return result


def gap_words() -> list[str]:
    words = set()
    for name in ("answers_missing_definition.txt", "history_missing_definition.txt"):
        f = AUDIT / name
        if f.exists():
            words |= {w.strip() for w in f.read_text().split() if w.strip()}
    return sorted(words)


def main(argv: list[str]) -> int:
    CACHE.mkdir(parents=True, exist_ok=True)
    words = argv[1:] or gap_words()
    if not words:
        print("No gap words — run build_wordlist.py first.")
        return 1
    print(f"Enriching {len(words)} words from Wiktionary (kaikki.org)…")
    ok = 0
    for w in words:
        r = enrich(w)
        if r:
            ok += 1
            if not (CACHE / f"{w}.json").exists():
                pass
        time.sleep(0.2)                          # be polite to kaikki
    print(f"Done: {ok}/{len(words)} enriched. Cache: {CACHE}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
