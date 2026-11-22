# Steam Workshop item description - VERBATIM copy of the live item

> This file mirrors, byte for byte, the description published on the
> Workshop item (ID 3844276160). Edit here first, then paste into the item
> via its web Edit - the two must never drift. The attribution banner is
> mandatory; never publish without it. Steam renders BBCode.

[h1]Rich Merchants - native port[/h1]

Make every trader as rich as you want: multiply their [b]ore[/b], [b]arrows[/b] and [b]bolts[/b] by [b]anything from 1× to 100×[/b], configured on [b]in-game sliders[/b] (default 3×). Merchants stay useful as buyers and sellers all game long.

[b]Why[/b]
A trader's ore pile is his buying money - and vanilla amounts run dry fast. By mid-game you're hauling loot nobody can pay for, and archers burn through the odd dozen arrows merchants stock. This mod multiplies exactly those three stock types and leaves the rest of the economy untouched.

[b]Features[/b]
[list]
[*]More [b]ore[/b] (a trader's buying money), [b]arrows[/b] and [b]bolts[/b] at every trader in the game - per-item multipliers, default 3×
[*]Covers all traders, all chapter restocks and all difficulty presets (Easy/Hard scaling still applies, like vanilla)
[*][b]Configurable in-game:[/b] Settings → Game → Rich Merchants - three labeled sliders (English & Polish; other languages fall back to English), 1×–100×, default 3×
[*]Exact math: every stock entry is multiplied against the game's own vanilla baseline - never stacks, never compounds across chapters, reloads or updates
[*]Pure official-ModKit AngelScript: no UE4SS, no .pak, no game files modified
[/list]

[b]How it works - and what it does NOT change[/b]
[list]
[*]The mod scales the game's per-chapter trader stock tables while scripts load. chapter 4 under this mod = exactly your-multiplier × vanilla chapter 4 (3× by default) - linearly, at any chapter, forever, no compounding.
[*]Prices, trader inventories (weapons, potions, …) and the whole dynamic economy are untouched - pair it freely with price/economy mods.
[*]The mod never touches your saves - safe to add, update or remove at any time. (Saves made with it keep the stock they captured; after removal, future chapter restocks return to vanilla scale.)
[/list]

[b]Settings apply from the next game launch[/b] (stock tables are built during script load). New games get the boost immediately; an existing save receives its next chapter restock at your multiplier.

[b]Compatibility[/b]
[list]
[*]Works with existing saves - safe to add or remove mid-playthrough.
[*]The game may note "save was made with a different modlist" after adding/removing - Continue anyway is safe.
[*]Don't stack with another mod that multiplies the same trader stock.
[/list]

[b]Installation[/b]
Subscribe - the game installs and updates it for you. Enable it in the mod manager (launch the game with [i]-ModManagementUI[/i], or via Steam launch options) if it isn't already.

[h1]Credits[/h1]
This is a native AngelScript (official ModKit) port of [b]Rich Merchants[/b] by [b]tailwindtom[/b] - [url=https://www.nexusmods.com/gothic1remake/mods/161]Nexus Mods #161[/url] (v1.0.2). The mod concept, defaults and gameplay design are tailwindtom's work. This port contains none of the original code - it is a clean-room reimplementation published with attribution. Thanks for the original mod!

[b]Source, issues & full validation evidence:[/b] [url=https://github.com/L-Sypniewski/RichMerchants-G1R]github.com/L-Sypniewski/RichMerchants-G1R[/url]
