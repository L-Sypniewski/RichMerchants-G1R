// RichMerchants - chapter restocks for the 12 one-time traders (v1.3.0).
//
// WHAT IT DOES:
//   12 of the 28 ore/arrow/bolt traders have NO chapter restock entries in
//   vanilla - their "OnWorldStart" seed is everything they ever get. This
//   file gives them vanilla-style chapter restocks ("StoryG1R_EnteredChapter_
//   2".."StoryG1R_EnteredChapter_6"), so they replenish on every chapter
//   entry like Wolf, Torik or Darrion already do.
//
//   Traders covered (the 12 vanilla no-restock configs that carry ore/ammo):
//     BaalKagan, BaalIsidro, Malon, Silas, Jeremiah, Dexter, Graham,
//     Mordrag, Alberto, Glen, Santino, Viper
//   The two demo/quest configs (DemoHunter, QuestDealer) are deliberately
//   NOT covered: neither is bound to a regular world NPC.
//
// HOW THE AMOUNTS WERE CHOSEN (vanilla-tapered, data-derived):
//   Across all vanilla traders that DO restock, the median ratio of a
//   chapter restock to the same trader's own initial stock is
//     CH2 0.32  CH3 0.29  CH4 0.55  CH5 0.43  CH6 0.33   (ore; n=11..4)
//   rounded here to a smooth  30% / 30% / 55% / 45% / 35%  curve. Each new
//   entry is  round(trader's total initial stock x chapter factor) , so a
//   trader restocks roughly a third to a half of what he started with -
//   never more. Two traders have story-inflated seeds (Dexter 113 = the sum
//   of his three "OnWorldStart" ore entries 64+23+26; Viper 204), and their
//   restocks scale proportionally, mirroring how vanilla treats large seeds.
//
// HOW IT WORKS:
//   Each class below uses ReplaceParentClass to take one leaf vanilla
//   trader config's place in the hierarchy. Replacing a class ADDS to it:
//   every inherited default (unique name, region, type, the full original
//   stock) still executes unchanged - only the new restock entries are
//   added. The new entries are `default AddTraderItemAllDifficulties(...)`
//   statements, exactly the vanilla idiom, so they dispatch through the
//   mod's shared-base override (RichMerchantsStock.as): the amounts below
//   are VANILLA-equivalent values - difficulty category multipliers and the
//   ore/arrow/bolt sliders apply on top, identical to every other entry.
//
// SAVE SEMANTICS (honest):
//   New games: these traders now restock on every chapter entry.
//   Existing saves: stock is serialized in the save (live items, baseline,
//   fired-event log), so new entries reach a save only through events that
//   have not fired yet - i.e. from the NEXT chapter transition onward,
//   exactly like the boost itself. Whether chapters that passed before the
//   mod was installed can retro-catch-up on load depends on whether the
//   save logged chapter events for traders that had no entries for them -
//   native-side behavior we cannot read from script; treat "next chapter
//   onward" as the guarantee.
//
//   Chapters in which a trader is absent from the world (e.g. Old Mine
//   NPCs late in the story) simply leave the granted stock unclaimed.

UCLASS(meta = (ReplaceParentClass))
class UBaalKaganTraderConfig_RichMerchants : UBaalKaganTraderConfig
{
    // seed: 18 ore
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  5, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  5, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 10, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  8, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  6, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UBaalIsidroTraderConfig_RichMerchants : UBaalIsidroTraderConfig
{
    // seed: 21 ore
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  6, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  6, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 12, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  9, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  7, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UMalonTraderConfig_RichMerchants : UMalonTraderConfig
{
    // seed: 15 ore
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  5, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  5, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  8, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  7, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  5, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class USilasTraderConfig_RichMerchants : USilasTraderConfig
{
    // seed: 14 ore, 12 arrows
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      4, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      4, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 8, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      7, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 6, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      5, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 5, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      4, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UJeremiahTraderConfig_RichMerchants : UJeremiahTraderConfig
{
    // seed: 14 ore, 12 arrows
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      4, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      4, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 8, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      7, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 6, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      5, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 5, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      4, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UDexterTraderConfig_RichMerchants : UDexterTraderConfig
{
    // seed: 113 ore (64+23+26 across three "OnWorldStart" entries), 18 arrows
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 34, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       5, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 34, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       5, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 62, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      10, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 51, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       8, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 40, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       6, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UGrahamTraderConfig_RichMerchants : UGrahamTraderConfig
{
    // seed: 9 ore
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 3, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 3, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 5, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 3, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UMordragTraderConfig_RichMerchants : UMordragTraderConfig
{
    // seed: 24 ore, 22 arrows
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  7, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       7, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  7, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       7, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 13, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      12, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 11, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      10, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  8, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       8, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UAlbertoTraderConfig_RichMerchants : UAlbertoTraderConfig
{
    // seed: 32 ore, 26 arrows, 12 bolts
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 10, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       8, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        4, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 10, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       8, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        4, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 18, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      14, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        7, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 14, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      12, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        5, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 11, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),       9, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        4, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UGlenTraderConfig_RichMerchants : UGlenTraderConfig
{
    // seed: 12 ore
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 7, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 5, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 4, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class USantinoTraderConfig_RichMerchants : USantinoTraderConfig
{
    // seed: 42 ore, 32 arrows, 24 bolts
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 13, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      10, "StoryG1R_EnteredChapter_2");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        7, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 13, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      10, "StoryG1R_EnteredChapter_3");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        7, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 23, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      18, "StoryG1R_EnteredChapter_4");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),       13, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 19, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      14, "StoryG1R_EnteredChapter_5");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),       11, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 15, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Arrow::StaticClass(),      11, "StoryG1R_EnteredChapter_6");
    default AddTraderItemAllDifficulties(UItAm_Bolt::StaticClass(),        8, "StoryG1R_EnteredChapter_6");
}

UCLASS(meta = (ReplaceParentClass))
class UViperTraderConfig_RichMerchants : UViperTraderConfig
{
    // seed: 204 ore (story-inflated; restocks scale proportionally)
    ////-- CH2 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  61, "StoryG1R_EnteredChapter_2");
    ////-- CH3 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  61, "StoryG1R_EnteredChapter_3");
    ////-- CH4 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(), 112, "StoryG1R_EnteredChapter_4");
    ////-- CH5 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  92, "StoryG1R_EnteredChapter_5");
    ////-- CH6 --////
    default AddTraderItemAllDifficulties(UItMi_Orenugget::StaticClass(),  71, "StoryG1R_EnteredChapter_6");
}
