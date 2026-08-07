#!/usr/bin/env python3
"""
Pack the generated JSON artifacts into a bundled read-only SQLite database.

One table serves both on-device needs:
  - offline `isValid(word)`   -> SELECT 1 FROM words WHERE word = ?
  - the daily-word pool       -> SELECT word FROM words WHERE is_answer = 1
  - meaning on solve/history  -> SELECT definition,... FROM words WHERE word = ?

Rows = the full VALID set (7k). `is_answer` flags the fair/defined daily pool; the
definition columns are populated for answers + every legacy-history word (the superset
that guarantees an offline meaning), and NULL for valid-but-not-defined guess words.

    tools/.venv/bin/python tools/build_sqlite.py
"""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
OUT = TOOLS / "out"
DB = OUT / "dictionary.sqlite"


def main() -> int:
    valid = set(json.loads((OUT / "valid.json").read_text()))
    answers = {e["word"] for e in json.loads((OUT / "answers.json").read_text())}
    definitions = json.loads((OUT / "definitions.json").read_text())

    if DB.exists():
        DB.unlink()
    con = sqlite3.connect(DB)
    con.execute("PRAGMA journal_mode = DELETE;")        # no -wal alongside a bundled file
    con.execute("""
        CREATE TABLE words (
            word       TEXT PRIMARY KEY NOT NULL,        -- 5-letter, lowercase
            is_answer  INTEGER NOT NULL DEFAULT 0,       -- eligible as the daily word
            pos        TEXT,                             -- part of speech (if defined)
            definition TEXT,
            example    TEXT,
            frequency  REAL,
            source     TEXT                              -- 'wordnet' | 'wiktionary'
        ) WITHOUT ROWID;
    """)

    rows = []
    for w in sorted(valid):
        d = definitions.get(w)
        rows.append((
            w,
            1 if w in answers else 0,
            d["pos"] if d else None,
            d["definition"] if d else None,
            d.get("example") if d else None,
            d["frequency"] if d else None,
            d["source"] if d else None,
        ))
    con.executemany(
        "INSERT INTO words (word,is_answer,pos,definition,example,frequency,source) "
        "VALUES (?,?,?,?,?,?,?)", rows)
    con.execute("CREATE INDEX idx_is_answer ON words(is_answer);")
    con.commit()
    con.execute("VACUUM;")
    con.commit()

    n_valid = con.execute("SELECT COUNT(*) FROM words").fetchone()[0]
    n_ans = con.execute("SELECT COUNT(*) FROM words WHERE is_answer=1").fetchone()[0]
    n_def = con.execute(
        "SELECT COUNT(*) FROM words WHERE definition IS NOT NULL").fetchone()[0]
    con.close()

    size_kb = DB.stat().st_size / 1024
    print(f"Wrote {DB}")
    print(f"  rows (VALID): {n_valid}")
    print(f"  answers:      {n_ans}")
    print(f"  with defs:    {n_def}")
    print(f"  size:         {size_kb:.0f} KB")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
