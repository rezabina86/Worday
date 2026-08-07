#!/usr/bin/env python3
"""
Pack the generated artifacts into the single app resource the game bundles:
`Worday/Common/Resources/dictionary.json`.

Schema (decoded by `WordDatabase`):
    { "version": 1,
      "answers": ["abbey", ...],                       // daily-word pool
      "valid":   ["aahed", ...],                        // offline isValid set (superset)
      "definitions": { "abbey": {"pos": "noun", "definition": "..."}, ... } }

Examples/frequency/source stay in the tools artifacts (attribution/analysis) but are
omitted here — the runtime meaning model needs only pos + definition, keeping the bundle
lean for instant launch.

    tools/.venv/bin/python tools/build_bundle.py
"""
from __future__ import annotations

import json
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
OUT = TOOLS / "out"
DEST = TOOLS.parent / "Worday" / "Common" / "Resources" / "dictionary.json"

# POS values the app's WordMeaningModel.Meaning.PartOfSpeech understands.
KNOWN_POS = {"noun", "verb", "adjective", "adverb", "pronoun", "preposition",
             "conjunction", "interjection", "numeral", "article", "determiner",
             "contraction"}


def main() -> int:
    answers = [e["word"] for e in json.loads((OUT / "answers.json").read_text())]
    valid = json.loads((OUT / "valid.json").read_text())
    raw_defs = json.loads((OUT / "definitions.json").read_text())

    definitions = {}
    for word, e in raw_defs.items():
        pos = e["pos"]
        if pos not in KNOWN_POS:
            raise SystemExit(f"POS '{pos}' ({word}) not in the app enum — align first.")
        definitions[word] = {"pos": pos, "definition": e["definition"]}

    bundle = {
        "version": 1,
        "answers": sorted(answers),
        "valid": sorted(valid),
        "definitions": dict(sorted(definitions.items())),
    }
    # compact separators — this is a shipped asset, not a human-edited file
    DEST.write_text(json.dumps(bundle, ensure_ascii=False, separators=(",", ":")) + "\n")

    size_kb = DEST.stat().st_size / 1024
    print(f"Wrote {DEST}")
    print(f"  answers={len(answers)} valid={len(valid)} definitions={len(definitions)}")
    print(f"  size={size_kb:.0f} KB")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
