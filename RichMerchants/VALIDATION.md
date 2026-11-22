# Validation - RichMerchants native port

Environment: Ubuntu + Steam Proton (Proton Experimental), game build
`Build106_CL176207` (`G1R/Version/version.txt`), game install at
`~/.local/share/Steam/steamapps/common/Gothic 1 Remake/`. Shipped vanilla
trader scripts verified content-identical to the G1R-Modkit sources
(`diff` after CRLF normalization on `TraderConfigBase.as`,
`TradersGeneric.as`, `TradersData.as`).

Method note: the shipping build writes no log files and opens no diagnostics
port. Validation therefore uses exit-code semantics of
`-as-exit-on-error`: **exit 3 = script compile error (game self-exits);
still running at a `timeout` (exit 124) = clean compile**, calibrated here
with a fresh negative control. The game was installed as a symlink at
`G1R/Mods/RichMerchants`. Before every run: confirmed no other game instance
running and scrubbed `Mods.ini` (the game persists enabled mods there and
auto-loads them - a known confounder). Proton's `Xalia/SDL "No displays
available"` noise in the launcher output is benign and appears on every
launch, clean or failing.

| # | Mod content | Flags / isolation | Result | Conclusion |
|---|---|---|---|---|
| 1 | **Negative control**: copy of the package as `RichMerchantsNegTest` with `const float OreMultiplier = "three";` (type error), run from `/tmp/opencode/g1r-negtest` via `-ModsDirectory` | `-as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchantsNegTest`, `Mods.ini` absent | **self-exited, exit 3** | harness compiles the mod's scripts and aborts on error - runs 2–4 meaningful |
| 2 | RichMerchants (real, symlinked `G1R/Mods/RichMerchants`) | `-as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchants`, `Mods.ini` absent | alive at 240 s (**124**) | full-recompile path: `ReplaceParentClass` on `UTraderConfigBase` + function override compiles clean |
| 3 | RichMerchants (real) | `-as-exit-on-error -Mods=RichMerchants` (no recompile flag), `Mods.ini` absent | alive at 240 s (**124**) | default boot path (precompiled vanilla + freshly compiled mod) also clean |
| 4 | RichMerchants + **two other enabled mods** (multi-mod; both via `Mods.ini`) | `-as-exit-on-error -as-ignore-precompiled-data -Mods=RichMerchants` | alive ≥ 235 s (**124**) | coexists with other enabled packages (incl. their own `ReplaceParentClass` uses); the settings page's multi-mod safety is proven separately by run 5 and by the 2026-11-20 interactive sessions |

Run-4 note: one of the co-installed mods uses `ReplaceParentClass` (on item
classes), the other registers an IngameTools panel; neither interacts
with `UTraderConfigBase`, and all three packages compiled together cleanly.

| # | Mod content | Flags / isolation | Result | Conclusion |
|---|---|---|---|---|
| 5 | **Settings-page probe** (2026-11-20): copy of the package as `RichMerchantsSettingsTest` + `UGothicModExt_UserSettings` page (3 x `FModUserSettingsFloat(Value = 3.0f)`), temp `-ModsDirectory` | `-as-exit-on-error -as-ignore-precompiled-data`, **two other enabled mods via `Mods.ini`** (the exact build-102 crash scenario) | alive ≥ 235 s (**124**) | **the build-102 "settings page + second mod" crash is fixed on build 106** - settings pages are multi-mod-safe again |
| 6 | **v1.1.0 first iteration** (Settings.as + TraderStockRebase.as with `UUClassFunctionLibrary::FindClassFromName` + baked table) | isolated, full recompile | **exit 3** | compile error - bisected below |
| 7–12 | Bisection probes P2b/P3/P4/P5/P6 (temp packages) | same harness | see below | failures isolated to two engine quirks; two earlier probes (P1, P2) were invalid (probe-construction mistakes: dangling `ApplySettings()` call; dead code referencing removed locals) and are excluded |

### v1.1.0 bisection (each row one isolated compile run)

| Probe | Tested | Exit | Finding |
|---|---|---|---|
| P2b | `Settings.as` + top-level struct + `TArray<struct>` + 115 literal calls + subsystem shell | **124** | settings page, struct, array, literals all compile |
| P3 | + `UUClassFunctionLibrary::FindClassFromName` + `UClass.GetDefaultObject()` + `Cast<UTraderConfigBase>` + typed foreach + settings read | 3 | failure inside this set |
| P4 | P3 minus the settings read (literal 3.0) | 3 | settings read exonerated |
| P5 | `UUClassFunctionLibrary::FindClassFromName(n"USharkyTraderConfig")` alone | 3 | **the `UUClassFunctionLibrary::` receiver does not compile** - shipped scripts use `UClass::` receivers (`UClass::GetAllSubclassesOf(...)`, `UClass::FindAllClassesInheritingFrom(...)`) |
| P6 | settings CDO via `StaticClass().Get().DefaultObject` + Cast | 3 | **`.Get()` (→ `UClass`) has no `.DefaultObject`** - `.DefaultObject` is a `TSubclassOf` property; `UClassName.DefaultObject` directly works |

First v1.1.0 candidate (v1 - later WITHDRAWN): the seed override captures every vanilla stock entry into a per-CDO `TArray` while class defaults execute; a subsystem walks `UClass::GetAllSubclassesOf(UTraderConfigBase::StaticClass())`, reads `URichMerchantsUserSettings.DefaultObject`, and re-bases `m_ItemsByDifficulty` entries to `RoundToInt(RoundToInt(base x difficultyMult) x setting)`. The shipped design is the v3 registration-time read (see the IN-GAME VERIFICATION section). Also fixed via the in-game error screen (human-read diagnostic): `DrawImGuiWindow` in a `UIngameTool` subclass requires `UFUNCTION(BlueprintOverride)` ("A function with the same name and parameters already exists in C++").

### IN-GAME VERIFICATION (2026-11-20, human sessions, build 106)

- **Stock boost verified end-to-end**: new game (Standard), teleported to
  Sharky (`NC_ORG_Sharky_843`) with the dev test tool - **ore 69 (vanilla 23),
  arrows 30 (vanilla 10)** at default 3.0 multipliers. Proves the central
  runtime assumption: vanilla trader configs' `default
  AddTraderItemAllDifficulties(...)` statements dispatch through the
  `ReplaceParentClass` override, the math matches bit-for-bit, trader
  instancing reads the boosted CDO, and the trade screen shows it.
- **Settings mechanism verified (v3, shipped in 1.1.0)**: with all three
  sliders persisted at 5.0 in `GameUserSettings.ini`
  (`OreMultiplier=(Value=5.000000)` etc.), a new game seeded Sharky at
  **exactly ore 115 = 23 x 5** - the seed override's registration-time read
  of `URichMerchantsUserSettings.DefaultObject.<X>Multiplier.Value` sees the
  persisted config during script-class registration. Verdict: **settings CAN
  drive compiled stock tables on build 106 - but only via a read during
  registration, never via a runtime write.**
- The experiment used a discriminating fallback (2.0) making one Sharky
  reading a three-valued oracle: 115 = config loaded at registration /
  69 = config loaded later / 46 = CDO null. Observed: 115. (E3 - slider set
  to a new value then re-verified - skipped: write side (slider→ini) and
  read side (ini→stock at registration) are independently proven.)
- Also observed: `-as-ignore-precompiled-data` validation launches render an
  unresponsive main menu for the full script-recompile duration (minutes) -
  they look like freezes on an interactive display; keep harness runs off
  the user's screen. One `UPROPERTY(meta=(DisplayName=...))` variant run
  ended in an abnormal (exit-1) session; the idiom is vanilla-proven
  elsewhere but was not isolated further and stays unused here.

### Settings experiment history (why v3 reads at registration)

| Version | Mechanism | Result |
|---|---|---|
| v1 | `HandleReadyForPlay` world subsystem re-basing CDO `m_ItemsByDifficulty` TMaps (keyed reads + `.Add` write-back on struct copies) | **dead** - sliders persisted 5.0, new game still seeded 3.0 stock (69/30) |
| v2 | `HandleNewGameStarted` + `HandleReadyForPlay` re-issuing captured vanilla entries through native `UTraderConfig::AddTraderItem` on trader CDOs (guarded once-per-world) | **dead** - same 69/30 outcome; post-registration native calls are ignored by the stock generator |
| v3 (shipped) | seed override reads the settings CDO **during class-default execution** (cross-class CDO reads in default statements are vanilla-proven: `Player/PlayerConfig.as`, `Camera/CameraConfig.as`) | **works** - 115 = 23 x 5 with sliders persisted at 5.0 |

v2 is preserved at the tip of the `archive/settings-v2` branch, v1 (the
`.as.disabled` pair) in that branch's parent commit; the v3 plan and
decision tree are in `.plans/richmerchants-settings-v3.md` (local,
gitignored).

### Engine facts established during this port (evidence: `Binds.Cache` + vanilla sources)

- **Trader stock is save-persisted**: `GameStateDataBaseSaveData.m_Traders`
  (`TArray<FTraderData>`) stores per-trader `m_TradersUniqueName`, live
  `m_Items`, baseline `m_DefaultItems` and fired-event log `m_GeneratedEvents`.
  On save load, live stock is restored from this, not rebuilt from config -
  config-side boosts only enter existing saves via not-yet-fired restock
  events (chapter transitions).
- `UTraderManager` binds only `GetCharacterOre`/`RemoveCharacterOre`;
  trading widgets (`UTradingBalance*`) are view-only; the save-data object
  has no script-accessible holder. Live trader stock is therefore NOT
  patchable from AngelScript - the UE4SS original's main advantage.
- **Settings-row labels work on build 106** (corrected 2026-11-20): the
  rich `FModUserSettingsFloat` ctor args (`DefaultValue`/`DisplayText`/
  `MinValue`/`MaxValue`/`StepSize`, the ModKit Example-Settings form)
  compile AND label the rows (compile probe exit 124; labels + EN/PL
  localization visually confirmed in-game by the user). The Binds.Cache
  property listing (only `Value`) does NOT reflect what the constructor
  accepts - never infer ctor-arg support from property listings. An earlier
  "unlabeled platform limit" claim derived from that inference was wrong.
  `LocText("<TextID>")` localizes labels through the package TextDB
  (`Story/Conversation/text/*.textdb.yaml` + `Config/Game.ini` mount point),
  with automatic fallback to english via the game's language sets.
- Useful reflection/class helpers - VERIFIED FORMS (build 106):
  `UClass::GetAllSubclassesOf(BaseClass)` and
  `UClass::FindAllClassesInheritingFrom(BaseClass)` (receiver must be
  `UClass::` - the `UUClassFunctionLibrary::` receiver does NOT compile
  despite the Binds.Cache attribution); `ScriptClassName.DefaultObject` and
  `UClassRef.GetDefaultObject()` both work, but `ClassRef.Get().DefaultObject`
  does not (`.DefaultObject` is a TSubclassOf property);
  `AGothicCharacterState::FindByUniqueName(FName)` for characters.

### What is and is not proven

Proven by the runs above and the 2026-11-20 human sessions:

- The package compiles in both boot paths (fresh recompile and precompiled
  vanilla), alone and alongside two other enabled mods.
- The negative control proves the harness would have caught a script error
  in exactly this package shape.
- **Settings drive stock - human-verified in-game (v1.1.0 mechanism)**:
  sliders persisted at 5.0 → new-game Sharky ore exactly 23x5 = **115**
  (registration-time read of the settings CDO; see the settings history
  table below).
- **Runtime dispatch - human-verified in-game**: the 30 vanilla
  trader-config classes' `default AddTraderItemAllDifficulties(...)`
  statements dispatch through the `ReplaceParentClass` override; Sharky's
  chapter-1 stock measured **69 ore / 30 arrows** (expected 23x3 / 10x3 on
  Standard), so the math is bit-exact end-to-end (override → CDO → trader
  instancing → trade screen).

Not (yet) verified:

- Chapter-restock additions on an existing save (predicted x3 per chapter
  entry; save-persisted accumulated stock stays vanilla - see the README's
  existing-saves section for the engine evidence).

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
