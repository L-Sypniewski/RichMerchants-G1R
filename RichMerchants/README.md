# Rich Merchants — native port (Gothic 1 Remake ModKit)

> Native AngelScript port of **Rich Merchants More Ore - Arrows - Bolts -
> Configurable** by **tailwindtom**
> ([Nexus Mods #161](https://www.nexusmods.com/gothic1remake/mods/161),
> v1.0.2). No original code is included; see the repo's `NOTICE.md`.

Multiplies every trader's stock of **ore**, **arrows** and **bolts**
(default **x3**) so merchants stay useful as buyers and sellers for longer.
Covers all traders, all chapter restocks and all difficulty presets, and
leaves every other stock item and all dynamic pricing untouched.

## Configure

In-game: **Settings → Game → "Rich Merchants"** — three sliders, top to
bottom: **ore / arrows / bolts** (unlabeled on build 106 — a game-build
binding limit; values are clamped to 0–100 when read, defaults 3.0).

- **Changed values apply from the next game launch** — stock tables are
  compiled during script load, so a new game started in the same session as
  the change uses the previous values.
- 0 sets the entry to 0 (expected to remove the item from stock;
  untested); values < 1.0 reduce below vanilla (the original's OnlyRaise
  guarantee holds for ≥ 1.0).
- The first-boot defaults (3.0) live in `Script/RichMerchants/Settings.as`
  if you ever want to change what a fresh install starts with.

## How it behaves

- Stock entries for the three items are scaled with the original mod's exact
  rounding: `RoundToInt(RoundToInt(vanilla * difficultyMult) * multiplier)`.
- Difficulty presets still apply first (Easy: ore & arrows x1.5; Hard: ore
  x0.8), exactly like vanilla.
- For multipliers >= 1.0 nothing is ever reduced below vanilla (the
  original's `OnlyRaise` guarantee). Multipliers < 1.0 *do* reduce.
- **New games** get boosted stock immediately. **Existing saves**: trader
  stock is serialized *inside the save* (current + baseline + fired events),
  so an existing save keeps its accumulated vanilla stock until the next
  chapter transition — that chapter's additions then arrive x3. Full x3
  totals need a new game. (The UE4SS original patched live memory and could
  re-base a running save; the ModKit exposes no accessor to live trader
  state.)

Full vanilla-vs-boosted reference table and port notes:
<https://github.com/L-Sypniewski/RichMerchants-G1R>
