// RichMerchantsTestTool - DEV-ONLY helper (not part of the shipped mod
// package; not for Steam Workshop). One IngameTools button that teleports
// the player next to a trader so the Rich Merchants stock boost can be
// verified quickly on a fresh new game.
//
// Teleport recipe copied verbatim from the live-verified EconomyProbe tool
// (BalancedTraders-G1R): button schedules a 0.1 s timer; the UFUNCTION timer
// callback runs on the game thread OUTSIDE the ImGui draw loop (teleports
// from the draw context hard-freeze the game - proven on build 106) and uses
// the vanilla GASCharacterStateMixins idiom (floor trace + capsule half
// height + CharacterState.Teleport).
//
// ImGui bindings available to mods are limited (Text/TextDisabled/Separator/
// Button/Checkbox/SameLine) - only those are used. No #if WITH_IMGUI guard:
// the define is never set for mod scripts (guard would strip the class).
//
// Launch required: -ingametools (plus -console for `ImGui.ToggleInput` if
// the mouse is captured; opening the game inventory also frees the cursor).

class URichMerchantsTestTool : UIngameTool
{
	default Category = "RichMerchants";
	default MenuPath = "RichMerchants.Teleport";
	default Title = "RM Test: Teleport";
	default bIsWindowOpen = false;

	FString LastStatus = "ready - start a NEW GAME, then click.";

	FName TargetName = n"NC_ORG_Sharky_843";
	FString TargetLabel = "Sharky (NC blacksmith)";

	private void SetupTeleport(FName CharacterUniqueName, FString Label)
	{
		AGothicCharacterState Target = AGothicCharacterState::FindByUniqueName(CharacterUniqueName);
		if (!IsValid(Target))
		{
			LastStatus = f"{Label}: NOT found (not spawned yet? get closer / enter the region)";
			return;
		}

		TargetName = CharacterUniqueName;
		TargetLabel = Label;
		System::SetTimer(this, n"DoDeferredTeleport", 0.1f, false);
		LastStatus = f"{Label}: teleport scheduled...";
	}

	UFUNCTION()
	void DoDeferredTeleport()
	{
		AGothicCharacterState Target = AGothicCharacterState::FindByUniqueName(TargetName);
		AGothicCharacterState PlayerCS = AGothicPlayerState::LocalPlayerState;
		if (!IsValid(Target) || !IsValid(PlayerCS))
		{
			LastStatus = "teleport aborted (target or player gone)";
			return;
		}

		FVector SpotLocation = Target.GetActorLocation();
		SpotLocation.X += 150.0f;

		AGothicCharacter Character = PlayerCS.GetCharacter();
		FHitResult Hit;
		if (IsValid(Character) && MagicScript::FindFloorAtLocation(SpotLocation, Hit, Character, ECollisionChannel::IKTrace, -200, 10))
		{
			SpotLocation.Z = Hit.ImpactPoint.Z;
			SpotLocation.Z += Character.CapsuleComponent.ScaledCapsuleHalfHeight;
		}

		bool bMoved = PlayerCS.Teleport(SpotLocation, FRotator(0.0f, 0.0f, 0.0f));
		LastStatus = bMoved
			? f"teleported to {TargetLabel} - trade and check stock"
			: "Teleport returned false (invalid target spot?)";
	}

	UFUNCTION(BlueprintOverride)
	void DrawImGuiWindow()
	{
		ImGui::Text("Verify RichMerchants stock on a NEW GAME (Standard):");
		ImGui::Text("Sharky CH1: ore 69 (vanilla 23), arrows 30 (vanilla 10)");
		ImGui::Text("Torik CH1: ore 135, arrows 84, bolts 48");
		ImGui::Separator();
		if (ImGui::Button("Teleport to Sharky"))
			SetupTeleport(n"NC_ORG_Sharky_843", "Sharky (NC blacksmith)");
		ImGui::SameLine();
		if (ImGui::Button("Teleport to Torik"))
			SetupTeleport(n"BC_BAN_Torik_864", "Torik (BC banker)");
		ImGui::Separator();
		ImGui::Text(LastStatus);
	}
}
