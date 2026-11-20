// RichMerchants — runtime application of the in-game settings.
// EXPERIMENT v2 (2026-11-20) — see Settings.as header for what changed vs
// the withdrawn v1.
//
// Mechanism: at HandleNewGameStarted (and, as fallback, HandleReadyForPlay;
// at most once per world instance) walk every trader config class
// (UClass::GetAllSubclassesOf(UTraderConfigBase::StaticClass()) -> CDO) and
// re-issue each captured vanilla stock entry through the NATIVE
// UTraderConfig::AddTraderItem(item, amount, chapter, difficulty) with
// amount = RoundToInt(RoundToInt(vanillaBase x difficultyMult) x setting).
//
// OUTCOME MATRIX this experiment distinguishes (new game, settings at 5.0,
// Sharky CH1 Standard, vanilla base 23):
//   115  -> AddTraderItem REPLACES per (item, event, difficulty): settings
//           work; ship with semantics "new games immediate, existing saves
//           at next chapter restock".
//   184  -> ACCUMULATES (69 seed + 115): usable via delta-writes against the
//           known seed values; ship with that adjustment.
//   69   -> post-boot AddTraderItem is ignored: hard platform limit on 106,
//           settings permanently withdrawn.

class URichMerchantsSubsystem : UGothicModExt_WorldSubsystem
{
    bool m_AppliedThisWorld = false;

    UFUNCTION(BlueprintOverride)
    void HandleNewGameStarted()
    {
        ApplySettings();
    }

    UFUNCTION(BlueprintOverride)
    void HandleReadyForPlay()
    {
        ApplySettings();
    }

    float GetClampedMultiplier(int itemId)
    {
        URichMerchantsUserSettings Settings = URichMerchantsUserSettings.DefaultObject;
        float Value = 1.0f;
        if (Settings != nullptr)
        {
            if (itemId == 0)
                Value = Settings.OreMultiplier.Value;
            else if (itemId == 1)
                Value = Settings.ArrowMultiplier.Value;
            else
                Value = Settings.BoltMultiplier.Value;
        }
        if (Value < 0.0f)
            Value = 0.0f;
        if (Value > 100.0f)
            Value = 100.0f;
        return Value;
    }

    void ApplySettings()
    {
        if (m_AppliedThisWorld)
            return;
        m_AppliedThisWorld = true;

        float OreMult = GetClampedMultiplier(0);
        float ArrowMult = GetClampedMultiplier(1);
        float BoltMult = GetClampedMultiplier(2);

        for (UClass TraderClass : UClass::GetAllSubclassesOf(UTraderConfigBase::StaticClass()))
        {
            UTraderConfigBase TraderCdo = Cast<UTraderConfigBase>(TraderClass.GetDefaultObject());
            if (TraderCdo == nullptr)
                continue;
            for (FRichMerchantsCapturedStock Entry : TraderCdo.m_VanillaStock)
            {
                float Mult = OreMult;
                if (Entry.ItemId == 1)
                    Mult = ArrowMult;
                else if (Entry.ItemId == 2)
                    Mult = BoltMult;

                TSubclassOf<UItemDefinition> ItemClass = UItMi_Orenugget::StaticClass();
                if (Entry.ItemId == 1)
                    ItemClass = UItAm_Arrow::StaticClass();
                else if (Entry.ItemId == 2)
                    ItemClass = UItAm_Bolt::StaticClass();

                int Category = TraderCdo.GetCategoryForItem(ItemClass);
                ApplyDifficulty(TraderCdo, UResourcesDifficultySettings_Easy::StaticClass(), Entry, ItemClass, Category, Mult);
                ApplyDifficulty(TraderCdo, UResourcesDifficultySettings_Standard::StaticClass(), Entry, ItemClass, Category, Mult);
                ApplyDifficulty(TraderCdo, UResourcesDifficultySettings_Hard::StaticClass(), Entry, ItemClass, Category, Mult);
            }
        }
    }

    // Re-issues one captured vanilla entry at the setting-scaled amount
    // through the native AddTraderItem (the same entry point that populated
    // the tables during class-default execution).
    void ApplyDifficulty(
        UTraderConfigBase TraderCdo,
        TSubclassOf<UDifficultySettings> DifficultyClass,
        FRichMerchantsCapturedStock Entry,
        TSubclassOf<UItemDefinition> ItemClass,
        int Category,
        float Mult)
    {
        float DifficultyMult = TraderCdo.GetTraderCategoryMultiplier(DifficultyClass, Category);
        int Target = TraderCdo.RoundToInt(float(TraderCdo.RoundToInt(float(Entry.BaseCount) * DifficultyMult)) * Mult);
        if (Target < 0)
            Target = 0;
        TraderCdo.AddTraderItem(ItemClass, Target, Entry.Event, DifficultyClass);
    }
}
