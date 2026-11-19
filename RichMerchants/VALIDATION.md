# Validation — RichMerchants native port

Environment: Ubuntu + Steam Proton (Proton Experimental), game build
`Build106_CL176207` (`G1R/Version/version.txt`), game install at
`~/.local/share/Steam/steamapps/common/Gothic 1 Remake/`. Shipped vanilla
trader scripts verified content-identical to the G1R-Modkit sources
(`diff` after CRLF normalization on `TraderConfigBase.as`,
`TradersGeneric.as`, `TradersData.as`).

Method note: the shipping build writes no log files and opens no diagnostics
port (established during the BalancedTraders port, see that repo's
VALIDATION.md). Validation therefore uses exit-code semantics of
`-as-exit-on-error`: **exit 3 = script compile error (game self-exits);
still running at a `timeout` (exit 124) = clean compile**, calibrated here
with a fresh negative control. The game was installed as a symlink at
`G1R/Mods/RichMerchants`. Before every run: confirmed no other game instance
running and scrubbed `Mods.ini` (the game persists enabled mods there and
auto-loads them — a known confounder). Proton's `Xalia/SDL "No displays
available"` noise in the launcher output is benign and appears on every
launch, clean or failing.

| # | Mod content | Flags / isolation | Result | Conclusion |
|---|---|---|---|---|
| 1 | **Negative control**: copy of the package as `RichMerchantsNegTest` with `const float OreMultiplier = "three";` (type error), run from `/tmp/opencode/g1r-negtest` via `-ModsDirectory` | `-as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchantsNegTest`, `Mods.ini` absent | **self-exited, exit 3** | harness compiles the mod's scripts and aborts on error — runs 2–4 meaningful |
| 2 | RichMerchants (real, symlinked `G1R/Mods/RichMerchants`) | `-as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchants`, `Mods.ini` absent | alive at 240 s (**124**) | full-recompile path: `ReplaceParentClass` on `UTraderConfigBase` + function override compiles clean |
| 3 | RichMerchants (real) | `-as-exit-on-error -Mods=RichMerchants` (no recompile flag), `Mods.ini` absent | alive at 240 s (**124**) | default boot path (precompiled vanilla + freshly compiled mod) also clean |
| 4 | RichMerchants + **BalancedTraders + EconomyProbe** (multi-mod; the other two via `Mods.ini`) | `-as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchants` | alive ≥ 235 s (**124**) | coexists with other enabled packages (incl. BalancedTraders' own `ReplaceParentClass` uses); no settings-page crash possible — this mod registers none |

Run-4 note: BalancedTraders also uses `ReplaceParentClass` (on item
classes) and EconomyProbe registers an IngameTools panel; neither interacts
with `UTraderConfigBase`, and all three packages compiled together cleanly.

### What is and is not proven

Proven by the runs above:

- The package compiles in both boot paths (fresh recompile and precompiled
  vanilla), alone and alongside two other enabled mods.
- The negative control proves the harness would have caught a script error
  in exactly this package shape.

NOT yet machine-proven (no logs, no human in-game session during
validation):

- **Runtime dispatch**: that the 30 vanilla trader-config classes' `default
  AddTraderItemAllDifficulties(...)` statements actually dispatch through
  this override when their class defaults execute. This follows from the
  documented inheritance-injection mechanism (the mod loader re-parents the
  class hierarchy before scripts compile — Script Hooking docs of the
  G1R-Modkit — and AngelScript method calls dispatch to the most-derived
  implementation), but a human in-game check (open any trader, e.g. Sharky:
  vanilla CH1 ore 23 → expect 69 on Standard) is the final confirmation.
- Actual in-trade stock amounts and behavior on existing saves (predicted:
  new games boosted immediately; existing saves on world start / chapter
  transitions).

### Reproduce

```bash
cd "…/Gothic 1 Remake/G1R/Binaries/Win64"
timeout 240 env \
  STEAM_COMPAT_DATA_PATH=…/compatdata/1297900 \
  STEAM_COMPAT_CLIENT_INSTALL_PATH=…/Steam \
  "…/Proton - Experimental/proton" run ./G1R-Win64-Shipping.exe \
  -as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchants
# 3 = compile error; 124 = clean
```

Scrub `…/compatdata/1297900/pfx/drive_c/users/steamuser/AppData/Local/G1R/Saved/Mods.ini`
before isolated runs; kill orphaned `G1R-Win64-Shipping.exe` by PID between
runs (the `timeout` only kills the Proton wrapper).
