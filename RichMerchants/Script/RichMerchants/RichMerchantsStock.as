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

// ---- runtime hooks for the settings experiment (TraderStockRebase.as) ----
// Every stock entry passing through the override is ALSO captured in its
// VANILLA form (append-only, so duplicate (item, event) entries — e.g.
// Dexter's three "OnWorldStart" ore rows — are preserved exactly).

struct FRichMerchantsCapturedStock
{
    int ItemId;      // 0 = ore, 1 = arrow, 2 = bolt
    FString Event;   // restock event, e.g. "OnWorldStart"
    int BaseCount;   // vanilla base amount (pre-difficulty)
}

UCLASS(meta = (ReplaceParentClass))
class UTraderConfigBase_RichMerchants : UTraderConfigBase
{
    // ---- CONFIGURATION — edit these, the game recompiles on launch --------
    // Multiplier applied to every trader's vanilla stock of each item.
    //   2.0 = double, 3.0 = triple (original default), 1.0 = leave untouched.
    // Values < 1.0 reduce stock below vanilla (the original's OnlyRaise
    // guarantee only holds for multipliers >= 1.0).
    const float OreMultiplier   = 3.0f; // ore    (ItMi_Orenugget = buying money)
    const float ArrowMultiplier = 3.0f; // arrows (ItAm_Arrow)
    const float BoltMultiplier  = 3.0f; // bolts  (ItAm_Bolt)
    // -----------------------------------------------------------------------

    // Vanilla bases captured during class-default execution (see above).
    TArray<FRichMerchantsCapturedStock> m_VanillaStock;

    int GetRichMerchantsItemId(TSubclassOf<UItemDefinition> item)
    {
        if (item == UItMi_Orenugget::StaticClass())
            return 0;
        if (item == UItAm_Arrow::StaticClass())
            return 1;
        if (item == UItAm_Bolt::StaticClass())
            return 2;
        return -1;
    }

    float GetRichMerchantsMultiplier(TSubclassOf<UItemDefinition> item)
    {
        if (item == UItMi_Orenugget::StaticClass())
            return OreMultiplier;
        if (item == UItAm_Arrow::StaticClass())
            return ArrowMultiplier;
        if (item == UItAm_Bolt::StaticClass())
            return BoltMultiplier;
        return 1.0f;
    }

    // Replicates UTraderConfigBase::AddTraderItemAllDifficulties (the vanilla
    // difficulty math) with the mod's multiplier applied after the difficulty
    // rounding — see MATH above. All called functions are inherited vanilla
    // members; AddTraderItem is the native UTraderConfig entry point.
    void AddTraderItemAllDifficulties(TSubclassOf<UItemDefinition> item, int count, FString event) override
    {
        int ItemId = GetRichMerchantsItemId(item);
        if (ItemId >= 0)
        {
            FRichMerchantsCapturedStock Captured;
            Captured.ItemId = ItemId;
            Captured.Event = event;
            Captured.BaseCount = count;
            m_VanillaStock.Add(Captured);
        }

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
