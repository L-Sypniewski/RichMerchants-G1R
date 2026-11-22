# Steam Workshop publishing runbook

The upload itself is an **in-game manual step** (the game uploads through its
own Steamworks session; there is no CLI/API for mod packages). Everything
that *can* be declarative lives in this repo.

## Before uploading (all in-repo, PR-reviewed)

1. `RichMerchants/GothicMod.json` is the metadata source the upload UI reads:
   `name`, `title`, `author` (carries the original-author attribution),
   `description`, `projectWebsiteURL` (→ Nexus Mods #161), `modVersion`.
2. Copy the Workshop item description verbatim from
  [`docs/workshop-description.md`](workshop-description.md) - it carries the
   attribution banner; do not publish without it.
3. For UPDATES: bump `modVersion` in `GothicMod.json` first (merge to
   master), then upload - the Workshop shows the version.

## Upload (interactive, ~5 minutes)

```bash
cd "…/Gothic 1 Remake/G1R/Binaries/Win64" && \
STEAM_COMPAT_DATA_PATH=…/compatdata/1297900 \
STEAM_COMPAT_CLIENT_INSTALL_PATH=…/Steam \
"…/Proton - Experimental/proton" run ./G1R-Win64-Shipping.exe \
  -ModManagementUI -no-intro-cinematic
```

Steam must be logged in (the game publishes under the logged-in account -
L-Sypniewski). In the game's Mod Manager:

1. Select **RichMerchants** → **Prepare Steam Workshop Item** → note the
   **Item ID** it returns.
2. Paste the description from `docs/workshop-description.md`; set visibility
   (public), tags ( gameplay / economy - whatever the UI offers).
3. **Upload to SteamWorkshop**.
4. Record the Item ID below and in `README.md` (PR).

## Updating an existing item (the binding is `metadata.SteamWorkshopID`)

The game stores the local-mod → Workshop-item binding INSIDE the package,
in `GothicMod.json`:

```json
"metadata": { "SteamWorkshopID": "3844276160" }
```

The repo carries this block (committed), so the pre-upload re-copy of the
package preserves the binding. **Never hit "Prepare Steam Workshop Item"
on a mod that already has one** - Prepare CREATES A NEW Steam item and
REBINDS the package to it (proven 2026-11-22: a session with a
binding-less package prepared item 3844463013 by accident; the orphan was
deleted and the binding restored by editing the ID back). Update path:

1. `modVersion` bumped on master, package re-copied over
   `G1R/Mods/RichMerchants` (real directory, not a symlink).
2. Steam client launch with `-ModManagementUI`.
3. Select RichMerchants (the local entry) - it points at item
   **3844276160** via `SteamWorkshopID` - and **Upload to SteamWorkshop**:
   this UPDATES the existing item (subscribers get it as an update).
4. Verify the item page shows the new version; delete any accidental
   duplicate items from steamcommunity.com/my/myworkshopfiles/.

## Item record

| | |
|---|---|
| Workshop Item ID | **3844276160** |
| URL | <https://steamcommunity.com/sharedfiles/filedetails/?id=3844276160> |
| First published | 2026-11-22 |
| Last version uploaded | 1.2.0 |

## Hard-won upload facts (2026-11-22 first upload)

- The **Upload to Steam Workshop** button only appears with a properly
  authenticated Steamworks session - launch through the Steam client with
  `-ModManagementUI` as a Steam launch option (a command-line Proton launch
  showed no upload affordance at all).
- The uploader **hangs on symlinked mod directories** - `G1R/Mods/<Mod>`
  must be a REAL directory for the upload (the dev symlink workflow is fine
  for playing/testing; re-copy the package over the directory before each
  upload: `cp -a <repo>/<Mod>/* G1R/Mods/<Mod>/`).
- The preview-image picker is a Wine dialog: Linux files are under the
  **Z:** drive (`Z:\home\<user>\...`); stage screenshots somewhere short.


## Notes

- Local `G1R/Mods/` symlinks are NOT uploaded content - the upload packages
  the `RichMerchants/` directory from the mods directory it is installed in;
  keep the symlink pointing at the repo master checkout so the uploaded
  content is exactly what's on master.
- The dev-only `RichMerchantsTestTool` is a separate package - never upload
  it (its GothicMod.json says so, and it isn't part of the RichMerchants
  package directory).
- If the game ever writes Workshop metadata back into the package (e.g. an
  ID file), commit it via PR so the repo stays the source of truth.
  (2026-11-22: it does - `metadata.SteamWorkshopID` in GothicMod.json; the
  game also normalizes the JSON on write: `loadOrder` "normal"→"Normal",
  empty `scriptPreprocessorDefines`/`tags`/`dependencies` arrays appear.)
- **A binding-less package that gets "Prepare"d = a NEW Steam item.** This
  is how the 3844463013 orphan was created: the game-dir package had been
  replaced by a repo copy that lacked the metadata block, so the mod looked
  unprepared. Always carry the binding in the repo (done) and never
  overwrite a bound package with an unbound copy.
- **Dangling mod symlinks crash the session**: `G1R/Mods/BalancedTraders`
  and `G1R/Mods/EconomyProbe` pointed into a deleted repo while still
  enabled in `Mods.ini` - the resulting Steam-client session wrote ~10 UE
  crash reports before being killed. Remove mod symlinks when their target
  repos are deleted, and scrub `Mods.ini` of their entries.
- While subscribed to the mod's own Workshop item, the Mod Management UI
  may show the subscribed entry instead of the local package (dedup not
  fully confirmed - the broken session above confounds it). If the local
  entry is missing, clean the Mods dir/Mods.ini first before concluding
  subscription hides it.
