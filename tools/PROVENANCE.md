# DailySort word-list & dictionary — provenance

Everything the app bundles under the offline dictionary is generated from the sources
below by the scripts in this folder. **Never hand-edit the generated artifacts** — change
a source or a rule and regenerate (see [Regeneration](#regeneration)).

## Generated artifacts
| file | what |
|---|---|
| `out/answers.json` | daily-word pool — singular, fair, defined 5-letter words (~1,940) |
| `out/valid.json` | broad clean 5-letter set for the offline `isValid` service (~7,070) |
| `out/definitions.json` | `pos`/`definition`/`example`/`frequency`/`source` for answers + every legacy-history word (~3,500) |
| `out/dictionary.sqlite` | bundled read-only DB packing all of the above (~500 KB) |

## Sources, versions & licenses
| source | version | used for | license | obligation |
|---|---|---|---|---|
| **wordfreq** | 3.1.1 | frequency-ranked candidates; Zipf difficulty threshold | MIT / data CC-BY-SA & others | credit (code MIT) |
| **Princeton WordNet** | 3.0 (via nltk 3.9.1 `wordnet`) | lemmas, POS, glosses, `morphy` plural detection | WordNet License (permissive) | **retain copyright notice on all copies; do not use "Princeton" in advertising** |
| **Hunspell en_US** | wooorm/dictionaries (SCOWL-derived) | authoritative validity gate (via `spylls` 0.1.7) | permissive (MIT-like / SCOWL) | credit |
| **Wiktionary** (via kaikki.org / wiktextract) | fetched at build time | definition fill for words WordNet lacks (function words, colloquialisms, modern terms) | **CC BY-SA 4.0** (dual with GFDL) | **attribution + share-alike** |
| **LDNOOBW** | github.com/LDNOOBW | seed for the offensive blocklist | CC-BY-4.0 | credit |

Every definition row carries a `source` column (`wordnet` or `wiktionary`) so obligations
are traceable per entry.

## In-app attribution (required — CC BY-SA)
The app must show, on an acknowledgements screen:

> **Dictionary data**
> Definitions include content from **Wiktionary** (https://www.wiktionary.org),
> available under the Creative Commons Attribution-ShareAlike License (CC BY-SA 4.0).
> Definitions and lexical data also derive from **Princeton WordNet**
> (https://wordnet.princeton.edu). WordNet 3.0 Copyright 2006 by Princeton University.
> All rights reserved.
> Word validity uses **Hunspell/SCOWL** spell-check data. Frequency data from **wordfreq**.

Because the Wiktionary-derived definition strings are CC BY-SA, the *derived dataset we
ship* (`definitions.json` / `dictionary.sqlite`) is redistributable under CC BY-SA 4.0.
This does **not** encumber the app's source code — only the definition dataset.

## Regeneration
```bash
python3 -m venv tools/.venv
tools/.venv/bin/python -m pip install -r tools/requirements.txt
tools/.venv/bin/python -c "import nltk; nltk.download('wordnet'); nltk.download('omw-1.4')"
# Hunspell en_US (one-time): tools/data/hunspell/en_US.{dic,aff}  (see build_wordlist.py header)

tools/.venv/bin/python tools/build_wordlist.py     # 1) filter -> answers/valid/definitions + audit
tools/.venv/bin/python tools/enrich_wiktionary.py  # 2) fetch Wiktionary fills for gap words (cached)
tools/.venv/bin/python tools/build_wordlist.py     # 3) re-run so fills land in definitions.json
tools/.venv/bin/python tools/build_sqlite.py       # 4) pack the bundled SQLite
```
The Wiktionary fetch caches parsed results to `tools/data/wiktionary/` (committed), so
steps 1/3/4 are fully reproducible offline; step 2 only re-hits the network for new gaps.

## Schedule note
DailySort assigns the daily word **randomly per device** (not a global date→word map) and
persists played words in SwiftData; regenerating this list does not retroactively change
any player's history. The definition set is a **superset** covering every word an existing
install may already hold, so a solved/historical word never reveals a blank meaning offline.
