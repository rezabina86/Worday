#!/usr/bin/env python3
"""
DailySort word-list + dictionary builder.

Reproducible, offline-first pipeline that turns raw corpora into the shippable data:
  - ANSWERS: fair, singular, common, defined 5-letter words (the daily-word pool)
  - VALID:   a broad, clean set of legit 5-letter words (offline `isValid` service)
  - DEFS:    definitions for a superset (ANSWERS + every word an existing install may
             already hold in history) so a solved word never reveals a blank meaning

Sources (all permissively/attribution licensed — see data/PROVENANCE.md):
  - wordfreq   -> frequency-ranked candidates + Zipf difficulty threshold
  - WordNet    -> lemmas, POS, glosses, and morphy-based plural detection
  - Hunspell   -> authoritative en_US validity gate (via spylls)
  - blocklist  -> curated slur/offensive exclusions
  - common.json (the OLD shipped list) -> guarantees offline coverage of legacy history

NEVER hand-edit the generated artifacts — always regenerate:
    tools/.venv/bin/python tools/build_wordlist.py
"""

from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from pathlib import Path

from wordfreq import zipf_frequency, top_n_list
from nltk.corpus import wordnet as wn
from spylls.hunspell import Dictionary

# ── Tuning constants ──────────────────────────────────────────────────────────
ANSWERS_ZIPF = 3.0          # "Balanced": recognizable to a general audience (~1.5-2k)
CANDIDATE_POOL = 300_000    # how deep into the frequency list to draw candidates
WORD_RE = re.compile(r"^[a-z]{5}$")

# Genuine 5-letter singular/mass nouns that END in -s but are NOT plurals. WordNet's
# morphy and the stem check can't tell these from plurals, so we curate them (plan §3.3).
SINGULAR_S_ALLOW = {
    "aegis", "alias", "atlas", "basis", "bogus", "bonus", "chaos", "corps", "crocus",
    "ethos", "fetus", "focus", "genus", "kudos", "locus", "logos", "lotus", "lupus",
    "minus", "mucus", "nexus", "oasis", "pious", "sinus", "virus", "abyss", "bliss",
    "gauss", "gross", "tress", "cress", "dross", "abbess",
}

# ── Paths ─────────────────────────────────────────────────────────────────────
TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
HUNSPELL = TOOLS / "data" / "hunspell" / "en_US"
BLOCKLIST_FILE = TOOLS / "data" / "blocklist.txt"
OLD_COMMON = REPO / "Worday" / "Common" / "Resources" / "common.json"
OUT = TOOLS / "out"
AUDIT = OUT / "audit"


# ── Helpers ───────────────────────────────────────────────────────────────────
def is_five(w: str) -> bool:
    return bool(WORD_RE.match(w))


def load_blocklist() -> set[str]:
    words = set()
    for line in BLOCKLIST_FILE.read_text().splitlines():
        line = line.split("#", 1)[0].strip().lower()
        if is_five(line):
            words.add(line)
    return words


def load_old_common() -> set[str]:
    data = json.loads(OLD_COMMON.read_text())
    return {w.lower() for w in data.get("commonWords", []) if is_five(w.lower())}


def wordnet_lemmas() -> set[str]:
    return {l.lower() for l in wn.all_lemma_names() if is_five(l.lower())}


def has_common_sense(w: str) -> bool:
    """True if WordNet has at least one *non-proper* sense for `w`. A synset with
    instance_hypernyms() is a proper-noun instance (e.g. 'james' -> Jesse James);
    a word with only those is a proper noun, not a common word."""
    return any(not s.instance_hypernyms() for s in wn.synsets(w))


def inflection_base(w: str):
    """Return (pos, base) if WordNet knows `w` as an inflected form of a *different*
    base (plural noun / conjugated verb), else None. This is the core plural filter."""
    for pos in (wn.NOUN, wn.VERB):
        base = wn.morphy(w, pos)
        if base and base != w:
            return (pos, base)
    return None


def depluralized_stem(w: str, is_word) -> str | None:
    """If `w` looks like the plural of a valid singular, return that singular, else None.
    Catches plurals WordNet lists as their own lemma (acres, deeds, elves, roads) which
    morphy misses. `is_word(x)` is the validity oracle (Hunspell ∪ WordNet)."""
    if not w.endswith("s") or w.endswith("ss"):
        return None
    if w.endswith("ies") and is_word(w[:-3] + "y"):           # ponies -> pony
        return w[:-3] + "y"
    if w.endswith("ves"):                                     # elves -> elf, knives -> knife
        for stem in (w[:-3] + "f", w[:-3] + "fe"):
            if is_word(stem):
                return stem
    if w.endswith("es") and is_word(w[:-2]):                  # boxes -> box, heroes -> hero
        return w[:-2]
    if is_word(w[:-1]):                                       # acres -> acre, roads -> road
        return w[:-1]
    return None


POS_NAME = {"n": "noun", "v": "verb", "a": "adjective", "s": "adjective", "r": "adverb"}

DEF_CAP = 160  # keep meaning cards short; longer glosses trim to a clean boundary


def tidy_definition(text: str) -> str:
    """Reduce a gloss to one concise, card-friendly clause. Prefer the first sentence;
    if still long, cut at the last word boundary before the cap with an ellipsis."""
    text = " ".join(text.split()).strip()
    first = text.split(". ")[0].strip().rstrip(".")
    text = first if 0 < len(first) <= DEF_CAP else text
    if len(text) > DEF_CAP:
        text = text[:DEF_CAP].rsplit(" ", 1)[0].rstrip(",;:") + "…"
    return text


def primary_definition(w: str):
    """First (most frequent) WordNet sense -> (pos, definition, example|None).
    WordNet orders synsets by frequency; glosses pack sense; example clauses via `;`."""
    syns = wn.synsets(w)
    if not syns:
        return None
    syn = syns[0]
    gloss = syn.definition().strip()
    # keep the primary clause only; trim trailing "; ..." elaborations
    definition = gloss.split(";")[0].strip()
    if not definition:
        definition = gloss
    examples = syn.examples()
    example = examples[0].strip() if examples else None
    return (POS_NAME.get(syn.pos(), syn.pos()), definition, example)


def main() -> int:
    OUT.mkdir(exist_ok=True)
    AUDIT.mkdir(parents=True, exist_ok=True)

    print("Loading corpora…", flush=True)
    hunspell = Dictionary.from_files(str(HUNSPELL))
    blocklist = load_blocklist()
    answers_exclude = {w for w in (
        line.split("#", 1)[0].strip().lower()
        for line in (TOOLS / "data" / "answers_exclude.txt").read_text().splitlines())
        if is_five(w)}
    old_common = load_old_common()
    wn_lemmas = wordnet_lemmas()

    def is_word(x: str) -> bool:
        return hunspell.lookup(x) or x in wn_lemmas or bool(wn.synsets(x))

    # 1) Candidate universe: frequency list ∪ WordNet lemmas ∪ legacy list ─────────
    freq_candidates = {w for w in top_n_list("en", CANDIDATE_POOL) if is_five(w)}
    candidates = freq_candidates | wn_lemmas | old_common
    print(f"  candidates: {len(candidates)}", flush=True)

    # 2) Validity + proper-noun gate → VALID tier ─────────────────────────────────
    valid, dropped_invalid, dropped_proper, dropped_blocked = set(), [], [], []
    for w in sorted(candidates):
        if w in blocklist:
            dropped_blocked.append(w)
            continue
        lower_ok = hunspell.lookup(w)
        common_wn = has_common_sense(w)
        # proper noun: not a lowercase word and no common WordNet sense, yet attested
        # capitalized (Hunspell) or only as a WordNet instance -> drop it.
        if not lower_ok and not common_wn and (
                hunspell.lookup(w.capitalize()) or wn.synsets(w)):
            dropped_proper.append(w)
            continue
        if not (lower_ok or common_wn):
            dropped_invalid.append(w)
            continue
        valid.add(w)
    print(f"  VALID: {len(valid)}  (invalid {len(dropped_invalid)}, "
          f"proper {len(dropped_proper)}, blocked {len(dropped_blocked)})", flush=True)

    # 3) Plural / inflection removal + frequency threshold → ANSWERS ───────────────
    removed_plurals, kept_ending_s, excluded = [], [], []
    answers_pool = set()
    for w in sorted(valid):
        if w in answers_exclude:                       # curated proper-noun/awkward drop
            excluded.append(w)
            continue
        infl = inflection_base(w)                       # morphy: aches->ache, women->woman
        stem = None if w in SINGULAR_S_ALLOW else depluralized_stem(w, is_word)
        # false-positive guard: a word with its OWN independent meaning (abode -> verb
        # abide, but also a noun) is kept when only morphy flags it and its stem is invalid.
        own_meaning = w in wn_lemmas and has_common_sense(w)
        if infl and not stem and own_meaning and infl[0] == "v":
            pass                                        # keep abode, mould, etc.
        elif infl or stem:
            reason = f"morphy:{infl[0]}:{infl[1]}" if infl else f"stem:{stem}"
            removed_plurals.append(f"{w}\t-> {reason}")
            continue
        if w.endswith("s") and not w.endswith("ss"):
            kept_ending_s.append(w)                     # survivors -> mandatory audit
        answers_pool.add(w)

    # frequency threshold for fairness
    answers = {w for w in answers_pool if zipf_frequency(w, "en") >= ANSWERS_ZIPF}
    print(f"  ANSWERS pool (singular): {len(answers_pool)} -> "
          f"zipf>={ANSWERS_ZIPF}: {len(answers)}", flush=True)

    # 4) Definitions: coverage gate over the superset (ANSWERS ∪ legacy history) ────
    # existing installs may hold ANY old_common word in SwiftData history; it must
    # still resolve to a meaning offline. Define answers + valid old_common words.
    def_targets = answers | (old_common & valid)
    wiktionary_cache = TOOLS / "data" / "wiktionary"
    definitions, no_definition = {}, []
    for w in sorted(def_targets):
        entry = None
        d = primary_definition(w)               # 1) WordNet gloss (preferred base)
        if d is not None:
            pos, definition, example = d
            entry = {"pos": pos, "definition": tidy_definition(definition),
                     "source": "wordnet"}
            if example:
                entry["example"] = example
        else:                                   # 2) Wiktionary fill (CC BY-SA)
            wf = wiktionary_cache / f"{w}.json"
            if wf.exists():
                wd = json.loads(wf.read_text())
                entry = {"pos": wd["pos"], "definition": tidy_definition(wd["definition"]),
                         "source": "wiktionary"}
                if wd.get("example"):
                    entry["example"] = wd["example"]
        if entry is None:
            no_definition.append(w)
            continue
        entry["frequency"] = round(zipf_frequency(w, "en"), 3)
        definitions[w] = entry

    # ANSWERS must have a definition (hard invariant) — drop the undefined ones now,
    # they are re-homed via Wiktionary in the enrichment phase (audit list emitted).
    answers_defined = {w for w in answers if w in definitions}
    answers_no_def = sorted(answers - answers_defined)

    # ── Emit artifacts ────────────────────────────────────────────────────────
    answers_out = [
        {"word": w, **definitions[w]} for w in sorted(answers_defined)
    ]
    (OUT / "answers.json").write_text(json.dumps(answers_out, indent=2) + "\n")
    (OUT / "valid.json").write_text(
        json.dumps(sorted(valid), indent=2) + "\n")
    (OUT / "definitions.json").write_text(
        json.dumps(definitions, indent=2, sort_keys=True) + "\n")

    # ── Audit lists (mandatory manual review — plan §3.3 / §6) ─────────────────
    (AUDIT / "removed_as_plural.txt").write_text("\n".join(removed_plurals) + "\n")
    (AUDIT / "kept_ending_in_s.txt").write_text("\n".join(sorted(kept_ending_s)) + "\n")
    (AUDIT / "dropped_proper_or_invalid.txt").write_text(
        "PROPER:\n" + "\n".join(dropped_proper) +
        "\n\nINVALID (sample 300):\n" + "\n".join(dropped_invalid[:300]) + "\n")
    (AUDIT / "blocked.txt").write_text("\n".join(sorted(dropped_blocked)) + "\n")
    (AUDIT / "excluded_from_answers.txt").write_text("\n".join(sorted(excluded)) + "\n")
    (AUDIT / "answers_missing_definition.txt").write_text(
        "\n".join(answers_no_def) + "\n")
    (AUDIT / "history_missing_definition.txt").write_text(
        "\n".join(sorted(set(no_definition) & old_common)) + "\n")

    # ── Report ─────────────────────────────────────────────────────────────────
    legacy_uncovered = sorted((old_common & valid) - set(definitions))
    report = {
        "answers_total": len(answers_defined),
        "answers_missing_definition": len(answers_no_def),
        "valid_total": len(valid),
        "definitions_total": len(definitions),
        "legacy_common_total": len(old_common),
        "legacy_common_valid": len(old_common & valid),
        "legacy_common_dropped_invalid_or_plural_ok": len(old_common - valid),
        "legacy_uncovered_by_definition": len(legacy_uncovered),
        "removed_as_plural": len(removed_plurals),
        "kept_ending_in_s": len(kept_ending_s),
        "dropped_proper": len(dropped_proper),
        "excluded_from_answers": len(excluded),
        "blocked": len(dropped_blocked),
        "avg_definition_len": round(
            sum(len(e["definition"]) for e in definitions.values()) /
            max(1, len(definitions)), 1),
        "answers_zipf_threshold": ANSWERS_ZIPF,
    }
    (OUT / "report.json").write_text(json.dumps(report, indent=2) + "\n")

    print("\n── REPORT ──")
    for k, v in report.items():
        print(f"  {k:42} {v}")
    print(f"\nArtifacts in {OUT}")
    print(f"Audit lists in {AUDIT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
