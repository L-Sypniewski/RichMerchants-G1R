#!/usr/bin/env python3
"""Dev aid: extract every trader's ore/arrow/bolt stock entries from the
vanilla G1R script sources and compute the RichMerchants-boosted amounts.

NOT part of the shipped mod package (the mod scales counts at runtime in
AngelScript; this script only produces the reference tables used in the
README and VALIDATION.md).

Usage:
    python3 tools/extract_trader_stock.py [--multiplier 3.0] \
        [--sources /path/to/G1R-Modkit/Script] [--out FILE.md]

Default sources path assumes the shallow G1R-Modkit clone sits next to this
repo (see AGENTS notes); override with --sources.

Rounding replicates the shipped AngelScript exactly:
    vanilla(difficulty) = RoundToInt(count * difficultyCategoryMultiplier)
    boosted(difficulty) = RoundToInt(vanilla(difficulty) * multiplier)
where RoundToInt(x) = int(x + 0.5) for x >= 0 — identical to the Lua mod's
math.floor(default * mult + 0.5) applied to the live per-difficulty default.
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path

TARGET_ITEMS = ("UItMi_Orenugget", "UItAm_Arrow", "UItAm_Bolt")

# UTraderConfigBase default category multipliers (vanilla, build 106).
# ore -> category 0, arrows/bolts -> category 1 (GetCategoryForItem).
CATEGORY_MULTIPLIERS = {
    "Easy": {"ore": 1.5, "arrows": 1.5},
    "Standard": {"ore": 1.0, "arrows": 1.0},
    "Hard": {"ore": 0.8, "arrows": 1.0},
}

SOURCES = (
    "Items/GenericItems/TradersGeneric.as",
    "LevelScripts/TradersData.as",
)

CLASS_RE = re.compile(r"^class\s+(U\w+TraderConfig)\s*:\s*UTraderConfigBase", re.M)
ENTRY_RE = re.compile(
    r"default\s+AddTraderItemAllDifficulties\(\s*(U\w+)::StaticClass\(\)\s*,"
    r"\s*(\d+)\s*,\s*\"(\w+)\"\s*\)"
)


def round_to_int(value: float) -> int:
    return int(value + 0.5)


@dataclass(frozen=True)
class Entry:
    trader: str
    item: str
    count: int
    event: str

    @property
    def chapter(self) -> str:
        if self.event == "OnWorldStart":
            return "CH1"
        m = re.search(r"Chapter_(\d+)$", self.event)
        return f"CH{m.group(1)}" if m else self.event

    @property
    def category(self) -> str:
        return "ore" if self.item == "UItMi_Orenugget" else "arrows"

    def vanilla(self, difficulty: str) -> int:
        return round_to_int(self.count * CATEGORY_MULTIPLIERS[difficulty][self.category])

    def boosted(self, difficulty: str, multiplier: float) -> int:
        return round_to_int(self.vanilla(difficulty) * multiplier)


def extract(sources_root: Path) -> list[Entry]:
    entries: list[Entry] = []
    for rel in SOURCES:
        text = (sources_root / rel).read_text(encoding="utf-8")
        # Split into per-class blocks so each entry is attributed correctly.
        matches = list(CLASS_RE.finditer(text))
        for i, m in enumerate(matches):
            trader = m.group(1)
            block = text[m.end(): matches[i + 1].start() if i + 1 < len(matches) else len(text)]
            for item, count, event in ENTRY_RE.findall(block):
                if item in TARGET_ITEMS:
                    entries.append(Entry(trader, item, int(count), event))
    return entries


def render(entries: list[Entry], multiplier: float) -> str:
    lines = [
        f"# Vanilla ore/arrow/bolt stock vs RichMerchants x{multiplier:g}",
        "",
        "Standard difficulty amounts. Easy = vanilla x1.5 (ore & arrows),",
        "Hard = vanilla x0.8 (ore only), applied by the game before the mod's",
        "multiplier (exactly as in the shipped AngelScript override).",
        "",
        "| Trader | Item | Stock per chapter (vanilla -> boosted) |",
        "|---|---|---|",
    ]
    by_trader_item: dict[tuple[str, str], list[Entry]] = {}
    for e in entries:
        by_trader_item.setdefault((e.trader, e.item), []).append(e)
    for (trader, item), group in by_trader_item.items():
        group.sort(key=lambda e: e.chapter)
        cells = ", ".join(
            f"{e.chapter}: {e.vanilla('Standard')}→{e.boosted('Standard', multiplier)}"
            for e in group
        )
        lines.append(f"| {trader[1:-12]} | {item[1:]} | {cells} |")
    total_v = sum(e.vanilla("Standard") for e in entries)
    total_b = sum(e.boosted("Standard", multiplier) for e in entries)
    lines += [
        "",
        f"Totals over all {len({e.trader for e in entries})} traders, "
        f"{len(entries)} stock entries: {total_v} -> {total_b} "
        f"(x{total_b / total_v:.3f}).",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--multiplier", type=float, default=3.0)
    ap.add_argument(
        "--sources",
        type=Path,
        default=Path(__file__).resolve().parent.parent.parent / "G1R-Modkit" / "Script",
    )
    ap.add_argument("--out", type=Path, default=None)
    args = ap.parse_args()

    entries = extract(args.sources)
    md = render(entries, args.multiplier)
    if args.out:
        args.out.write_text(md, encoding="utf-8")
        print(f"wrote {args.out} ({len(entries)} entries)")
    else:
        print(md)


if __name__ == "__main__":
    main()
