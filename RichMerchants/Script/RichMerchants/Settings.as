// RichMerchants — in-game settings (EXPERIMENT v2, 2026-11-20).
//
// v1 (withdrawn): sliders rendered + persisted, but a HandleReadyForPlay
// re-base of the CDO m_ItemsByDifficulty TMaps did not affect initial stock
// (suspected: too late, and/or TMap .Add replace-semantics on struct copies
// silently no-op). v2 changes BOTH suspects:
//   - applies at HandleNewGameStarted (earlier than world-ready), and
//   - writes through the native UTraderConfig::AddTraderItem — the exact
//     function that built the stock tables during class registration —
//     instead of manual TMap surgery.
// Applied at most once per world instance (idempotence guard) so accumulate
// semantics cannot double-apply within a session.
//
// Build 106: only `Value` is bound on FModUserSettingsFloat — sliders render
// unlabeled (order: top = ore, middle = arrows, bottom = bolts). Values are
// clamped to [0, 100] when applied.

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
