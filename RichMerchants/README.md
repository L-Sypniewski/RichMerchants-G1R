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

Open `Script/RichMerchants/RichMerchantsStock.as` in any text editor and
edit the three constants near the top:

```angelscript
const float OreMultiplier   = 3.0f; // ore    (ItMi_Orenugget)
const float ArrowMultiplier = 3.0f; // arrows (ItAm_Arrow)
const float BoltMultiplier  = 3.0f; // bolts  (ItAm_Bolt)
```

`2.0` = double, `1.0` = leave that item untouched. The game recompiles the
scripts on launch — no extra tooling needed. (There is intentionally no
in-game settings page: a current game build crashes when a modded settings
page coexists with a second enabled mod.)

## How it behaves

- Stock entries for the three items are scaled with the original mod's exact
  rounding: `RoundToInt(RoundToInt(vanilla * difficultyMult) * multiplier)`.
- Difficulty presets still apply first (Easy: ore & arrows x1.5; Hard: ore
  x0.8), exactly like vanilla.
- For multipliers >= 1.0 nothing is ever reduced below vanilla (the
  original's `OnlyRaise` guarantee). Multipliers < 1.0 *do* reduce.
- **New games** get boosted stock immediately. **Existing saves** get it when
  the game next (re)builds a trader's stock (world start / chapter
  transitions) — the UE4SS original patched live state instead and applied to
  existing saves immediately. Same destination, different route.

Full vanilla-vs-boosted reference table and port notes:
<https://github.com/L-Sypniewski/RichMerchants-G1R>
