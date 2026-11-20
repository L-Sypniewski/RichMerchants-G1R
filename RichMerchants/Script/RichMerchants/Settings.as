// RichMerchants — in-game settings (localized, v1.2.0).
//
// The seed override (RichMerchantsStock.as) reads these persisted values
// DURING script-class registration — the same phase that builds the stock
// tables — so the sliders drive trader stock directly, with zero runtime
// writes (all runtime application mechanisms are proven dead on build 106;
// the registration-time read is verified in-game: sliders at 5.0 -> Sharky
// chapter-1 ore exactly 23 x 5 = 115 on a new game).
//
// Localization: the slider labels resolve through the package's TextDB
// (Story/Conversation/text/*.textdb.yaml, mounted via Config/Game.ini) with
// LocText() — the same pattern as the ModKit's conversation examples. EN is
// the fallback for every language without a translation (the game's
// language sets fall back to english); polish is provided. The category
// name is deliberately NOT localized — it is the mod's name and must match
// its Workshop / mod-manager identity in every language.
//
// Labeling: the rich FModUserSettingsFloat ctor args (DisplayText / Min /
// Max / StepSize — the official ModKit Example-Settings form) compile and
// label the rows on build 106 (visually verified in the settings menu).

UCLASS(Config = GameUserSettings)
class URichMerchantsUserSettings : UGothicModExt_UserSettings
{
    default CategoryName = FText::FromString("Rich Merchants");

    UPROPERTY(Config)
    FModUserSettingsFloat OreMultiplier = FModUserSettingsFloat(
        Value = 3.0f,
        DefaultValue = 3.0f,
        DisplayText = LocText("RichMerchants_OreMultiplier"),
        MinValue = 1.0f,
        MaxValue = 100.0f,
        StepSize = 0.5f);

    UPROPERTY(Config)
    FModUserSettingsFloat ArrowMultiplier = FModUserSettingsFloat(
        Value = 3.0f,
        DefaultValue = 3.0f,
        DisplayText = LocText("RichMerchants_ArrowMultiplier"),
        MinValue = 1.0f,
        MaxValue = 100.0f,
        StepSize = 0.5f);

    UPROPERTY(Config)
    FModUserSettingsFloat BoltMultiplier = FModUserSettingsFloat(
        Value = 3.0f,
        DefaultValue = 3.0f,
        DisplayText = LocText("RichMerchants_BoltMultiplier"),
        MinValue = 1.0f,
        MaxValue = 100.0f,
        StepSize = 0.5f);
}
