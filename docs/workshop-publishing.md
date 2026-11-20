# Steam Workshop publishing runbook

The upload itself is an **in-game manual step** (the game uploads through its
own Steamworks session; there is no CLI/API for mod packages). Everything
that *can* be declarative lives in this repo.

## Before uploading (all in-repo, PR-reviewed)

1. `RichMerchants/GothicMod.json` is the metadata source the upload UI reads:
   `name`, `title`, `author` (carries the original-author attribution),
   `description`, `projectWebsiteURL` (→ Nexus Mods #161), `modVersion`.
2. Copy the Workshop item description verbatim from
  [`docs/workshop-description.md`](workshop-description.md) — it carries the
   attribution banner; do not publish without it.
3. For UPDATES: bump `modVersion` in `GothicMod.json` first (merge to
   master), then upload — the Workshop shows the version.

## Upload (interactive, ~5 minutes)

```bash
cd "…/Gothic 1 Remake/G1R/Binaries/Win64" && \
STEAM_COMPAT_DATA_PATH=…/compatdata/1297900 \
STEAM_COMPAT_CLIENT_INSTALL_PATH=…/Steam \
"…/Proton - Experimental/proton" run ./G1R-Win64-Shipping.exe \
  -ModManagementUI -no-intro-cinematic
```

Steam must be logged in (the game publishes under the logged-in account —
L-Sypniewski). In the game's Mod Manager:

1. Select **RichMerchants** → **Prepare Steam Workshop Item** → note the
   **Item ID** it returns.
2. Paste the description from `docs/workshop-description.md`; set visibility
   (public), tags ( gameplay / economy — whatever the UI offers).
3. **Upload to SteamWorkshop**.
4. Record the Item ID below and in `README.md` (PR).

## Item record

| | |
|---|---|
| Workshop Item ID | _(fill after first upload)_ |
| URL | `https://steamcommunity.com/sharedfiles/filedetails/?id=<ID>` |
| First published | _(fill)_ |
| Last version uploaded | _(fill, e.g. 1.2.0)_ |

## Notes

- Local `G1R/Mods/` symlinks are NOT uploaded content — the upload packages
  the `RichMerchants/` directory from the mods directory it is installed in;
  keep the symlink pointing at the repo master checkout so the uploaded
  content is exactly what's on master.
- The dev-only `RichMerchantsTestTool` is a separate package — never upload
  it (its GothicMod.json says so, and it isn't part of the RichMerchants
  package directory).
- If the game ever writes Workshop metadata back into the package (e.g. an
  ID file), commit it via PR so the repo stays the source of truth.
