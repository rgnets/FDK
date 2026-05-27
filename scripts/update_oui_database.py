#!/usr/bin/env python3
"""Regenerate assets/mac_unified.csv from the live IEEE OUI registries.

Downloads MA-L (24-bit), MA-M (28-bit), and MA-S (36-bit) assignment
listings and merges them into the unified format the FDK app loads at
startup. Run whenever a scanned MAC's OUI resolves to "Unknown" because
the bundled snapshot predates that assignment.

    python3 scripts/update_oui_database.py
"""

import csv
import io
import sys
import urllib.request
from pathlib import Path

SOURCES = [
    ("https://standards-oui.ieee.org/oui/oui.csv", "MA-L", 24),
    ("https://standards-oui.ieee.org/oui28/mam.csv", "MA-M", 28),
    ("https://standards-oui.ieee.org/oui36/oui36.csv", "MA-S", 36),
]

OUT_PATH = Path(__file__).resolve().parent.parent / "assets" / "mac_unified.csv"


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "FDK-OUI-Update/1.0"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read().decode("utf-8", errors="replace")


def parse(body: str, registry: str, bits: int):
    reader = csv.reader(io.StringIO(body))
    header = next(reader, None)
    if not header or header[:3] != ["Registry", "Assignment", "Organization Name"]:
        raise SystemExit(f"unexpected header for {registry}: {header}")
    for row in reader:
        if len(row) < 3:
            continue
        assignment = row[1].replace("-", "").replace(":", "").upper()
        name = row[2].strip()
        reserved = "true" if name == "IEEE Registration Authority" else "false"
        yield assignment, str(bits), name, registry, reserved


def main() -> int:
    rows = []
    for url, registry, bits in SOURCES:
        print(f"fetching {registry} from {url}")
        body = fetch(url)
        before = len(rows)
        rows.extend(parse(body, registry, bits))
        print(f"  -> {len(rows) - before} entries")

    rows.sort(key=lambda r: (r[0], int(r[1])))

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUT_PATH.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh, quoting=csv.QUOTE_MINIMAL, lineterminator="\n")
        writer.writerow(["prefix", "prefix_bits", "manufacturer", "registry_type", "is_ieee_reserved"])
        writer.writerows(rows)
    print(f"wrote {len(rows)} entries to {OUT_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
