// RichMerchants — native AngelScript port of the UE4SS Lua mod
// "Rich Merchants More Ore - Arrows - Bolts - Configurable"
// by tailwindtom (Nexus Mods #161, v1.0.2):
// https://www.nexusmods.com/gothic1remake/mods/161
//
// WHAT IT DOES (identical goals to the original):
//   Multiplies every trader's stock of ore (ItMi_Orenugget), arrows
//   (ItAm_Arrow) and bolts (ItAm_Bolt) — default x3 — so merchants stay
//   useful as buyers and sellers for longer.
//
// HOW IT WORKS:
//   Every vanilla trader config (UBaalKaganTraderConfig, USharkyTraderConfig,
//   …, UQuestDealerTraderConfig — 30 script classes in total, 28 of which
//   carry ore/arrow/bolt stock) derives from the SCRIPT class
//   UTraderConfigBase, and stocks every item — including the chapter-gated
//   restocks ("OnWorldStart", "StoryG1R_EnteredChapter_N") — through its
//   helper UTraderConfigBase::AddTraderItemAllDifficulties(item, count, event).
//
//   This class uses ReplaceParentClass (inheritance injection) to take
//   UTraderConfigBase's place in the hierarchy: every trader config now
//   inherits from THIS class, so its stock entries run through the override
//   below, which scales the count for the three target items before handing
//   off to the vanilla per-difficulty math. One hook covers all traders,
//   all chapters and all difficulty presets — no vanilla tables are copied
//   and nothing outside these three item classes is touched.
//
// MATH (matches the original Lua bit-for-bit):
//   The Lua mod computed  round(live_default * multiplier)  per trader, where
//   live_default was the trader's difficulty-adjusted vanilla amount,
//   i.e. RoundToInt(count * difficultyCategoryMultiplier). The override below
//   applies exactly that order:
//       boosted = RoundToInt(RoundToInt(count * difficultyMult) * multiplier)
//   so Easy (ore x1.5) and Hard (ore x0.8) still apply first, like vanilla.
//
// SEMANTIC DIFFERENCE vs the UE4SS original (config seed vs live patch):
//   The Lua mod rewrote the LIVE stock maps of already-instantiated traders a
//   few seconds after each level load — existing saves got boosted stock
//   immediately. This port scales the stock CONFIG the game seeds traders
//   from: new games get boosted stock immediately; EXISTING saves see the
//   boost when the game next (re)builds a trader's stock (world start / chapter
//   transitions). Multiplier x1.0 for an item disables the boost for it.

UCLASS(meta = (ReplaceParentClass))
class UTraderConfigBase_RichMerchants : UTraderConfigBase
{
    // ---- CONFIGURATION ------------------------------------------------------
    // Multipliers live in the in-game settings: Settings -> Game ->
    // "Rich Merchants" — three labeled sliders (EN/PL, EN fallback), top to
    // bottom: ore / arrows / bolts. Defaults 3.0 each (the original mod's
    // values). CHANGED VALUES APPLY FROM THE NEXT GAME LAUNCH — stock
    // tables are compiled during script load. Slider range 1.0-100 (step
    // 0.5); the [0,100] read-time clamp below remains as a guard for
    // hand-edited GameUserSettings.ini values.
    // -------------------------------------------------------------------------

    // Reads the persisted settings CDO during class-default execution — the
    // same registration phase that builds the stock tables (cross-class CDO
    // reads in default statements are vanilla-proven, e.g.
    // Player/PlayerConfig.as, Camera/CameraConfig.as). VERIFIED IN-GAME
    // (build 106, 2026-11-20): with sliders persisted at 5.0 a new game
    // seeded Sharky at exactly 23x5 = 115 ore. Changed slider values apply
    // from the NEXT game launch (stock tables are compiled during script
    // load); a null/unloaded settings CDO falls back to the mod default 3.0.
    // Item dispatch FIRST: non-target items must always return 1.0 (never
    // touched), even on a null/unloaded settings CDO — the 3.0 fallback
    // applies only to the three target items.
    float GetRichMerchantsMultiplier(TSubclassOf<UItemDefinition> item)
    {
        bool bIsOre = item == UItMi_Orenugget::StaticClass();
        bool bIsArrow = item == UItAm_Arrow::StaticClass();
        bool bIsBolt = item == UItAm_Bolt::StaticClass();
        if (!bIsOre && !bIsArrow && !bIsBolt)
            return 1.0f;

        URichMerchantsUserSettings Settings = URichMerchantsUserSettings.DefaultObject;
        if (Settings == nullptr)
            return 3.0f;

        float Value = 3.0f;
        if (bIsOre)
            Value = Settings.OreMultiplier.Value;
        else if (bIsArrow)
            Value = Settings.ArrowMultiplier.Value;
        else
            Value = Settings.BoltMultiplier.Value;

        if (Value < 0.0f)
            Value = 0.0f;
        if (Value > 100.0f)
            Value = 100.0f;
        return Value;
    }

    // Replicates UTraderConfigBase::AddTraderItemAllDifficulties (the vanilla
    // difficulty math) with the mod's multiplier applied after the difficulty
    // rounding — see MATH above. All called functions are inherited vanilla
    // members; AddTraderItem is the native UTraderConfig entry point.
    void AddTraderItemAllDifficulties(TSubclassOf<UItemDefinition> item, int count, FString event) override
    {
        float Mult = GetRichMerchantsMultiplier(item);
        int category = GetCategoryForItem(item);
        int countEasy = RoundToInt(RoundToInt(float(count) * GetTraderCategoryMultiplier(UResourcesDifficultySettings_Easy::StaticClass(), category)) * Mult);
        int countStandard = RoundToInt(RoundToInt(float(count) * GetTraderCategoryMultiplier(UResourcesDifficultySettings_Standard::StaticClass(), category)) * Mult);
        int countHard = RoundToInt(RoundToInt(float(count) * GetTraderCategoryMultiplier(UResourcesDifficultySettings_Hard::StaticClass(), category)) * Mult);
        if (countEasy < 0) countEasy = 0;
        if (countStandard < 0) countStandard = 0;
        if (countHard < 0) countHard = 0;
        AddTraderItem(item, countEasy, event, UResourcesDifficultySettings_Easy::StaticClass());
        AddTraderItem(item, countStandard, event, UResourcesDifficultySettings_Standard::StaticClass());
        AddTraderItem(item, countHard, event, UResourcesDifficultySettings_Hard::StaticClass());
    }
}
