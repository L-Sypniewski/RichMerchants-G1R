# Rich Merchants - native port (Gothic 1 Remake ModKit)

> Native AngelScript port of **Rich Merchants More Ore - Arrows - Bolts -
> Configurable** by **tailwindtom**
> ([Nexus Mods #161](https://www.nexusmods.com/gothic1remake/mods/161),
> v1.0.2). No original code is included; see the repo's `NOTICE.md`.

**Steam Workshop**: <https://steamcommunity.com/sharedfiles/filedetails/?id=3844276160>
**Source & issues**: <https://github.com/L-Sypniewski/RichMerchants-G1R>

Multiplies every trader's stock of **ore**, **arrows** and **bolts**
(default **x3**) so merchants stay useful as buyers and sellers for longer.
Covers all traders, all chapter restocks and all difficulty presets, and
leaves every other stock item and all dynamic pricing untouched.

Since v1.3.0, the 12 traders that never restock in vanilla (BaalKagan,
BaalIsidro, Malon, Silas, Jeremiah, Dexter, Graham, Mordrag, Alberto, Glen,
Santino, Viper) also get vanilla-style chapter restocks (CH2-CH6, each
granting roughly a third to a half of their initial stock, matching the
vanilla restock curve).

## Configure

In-game: **Settings → Game → "Rich Merchants"** - three labeled sliders,
top to bottom: **ore / arrows / bolts** (English and Polish labels; other
languages fall back to English). Slider range 1.0–100.0, step 0.5,
defaults 3.0.

- **Changed values apply from the next game launch** - stock tables are
  compiled during script load, so a new game started in the same session as
  the change uses the previous values.
- The slider minimum is 1.0 (never below vanilla). Sub-1.0 values are only
  reachable by hand-editing `GameUserSettings.ini`; a code-side clamp still
  applies there.
- Translations live in `Story/Conversation/text/*.textdb.yaml` (EN + PL
  provided); adding a language = adding one YAML line per label.
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
  chapter transition - that chapter's additions then arrive x3. Full x3
  totals need a new game. (The UE4SS original patched live memory and could
  re-base a running save; the ModKit exposes no accessor to live trader
  state.)
- The v1.3.0 restocks for the 12 vanilla no-restock traders follow the same
  rule: new games replenish from chapter 2 onward; an existing save picks
  them up from its next chapter transition.

Full vanilla-vs-boosted reference table and port notes:
<https://github.com/L-Sypniewski/RichMerchants-G1R>
