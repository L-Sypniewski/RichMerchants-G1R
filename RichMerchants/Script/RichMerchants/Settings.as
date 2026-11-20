// RichMerchants — in-game settings (v1.1.0).
//
// The seed override (RichMerchantsStock.as) reads these persisted values
// DURING script-class registration — the same phase that builds the stock
// tables — so the sliders drive trader stock directly, with zero runtime
// writes (all runtime application mechanisms are proven dead on build 106;
// the registration-time read is verified in-game: sliders at 5.0 -> Sharky
// chapter-1 ore exactly 23 x 5 = 115 on a new game).
//
// Build 106: only `Value` is bound on FModUserSettingsFloat — sliders render
// unlabeled (order top to bottom: ore / arrows / bolts). Values apply from
// the next game launch; range 0-100 (clamped when read).

UCLASS(Config = GameUserSettings)
class URichMerchantsUserSettings : UGothicModExt_UserSettings
{
    default CategoryName = FText::FromString("Rich Merchants");

    UPROPERTY(Config)
    FModUserSettingsFloat OreMultiplier = FModUserSettingsFloat(Value = 3.0f);

    UPROPERTY(Config)
    FModUserSettingsFloat ArrowMultiplier = FModUserSettingsFloat(Value = 3.0f);

    UPROPERTY(Config)
    FModUserSettingsFloat BoltMultiplier = FModUserSettingsFloat(Value = 3.0f);
}
