# IWD2EE Spell Indicators

BG2-style spell area and trajectory previews for **Icewind Dale II with IWD2EE**. An independent WeiDU mod; Tactics is not required.

**Version 1.3.1, including the 2026-11-22 Widen / Cancel Metamagic correction.**

[中文说明 / Chinese documentation](IWD2EE_Spell_Indicators/README.md) · [Changelog](IWD2EE_Spell_Indicators/CHANGELOG.md)

## Components

| Component | Features |
| --- | --- |
| **#0: area and trajectory previews** | Breathing circular and cone outlines, separate trap trigger/damage outlines, solid three-pixel lines, wall previews, and Spiritual Wrath's four-way paths |
| **#1: self-centred selection (optional)** | Preview 28 self-centred area spells, then click the caster to cast; requires #0 |

Circular and cone previews use a 75% vertical ground projection. Skull Trap and Glyph of Warding show green damage and yellow trigger outlines. Straight lines have flat ends and follow the cursor up to their configured maximum length.

Supported walls include Wall of Moonlight, Wall of Fire, Trial by Fire, Wall of Force and Prismatic Wall. Spiritual Wrath previews four directions from the caster.

**Widen Spell and equipment:** previews read active modifiers every frame, including supported native modifiers such as Staff of Widening. Cancel Metamagic immediately removes the pending Widen preview while preserving equipment bonuses. Trap trigger radii remain separate. Previewing never consumes metamagic charges.

**Boulder Roll:** component #0 changes casting to ground-direction selection. The click sets the initial direction; the boulder continues toward the native terrain obstruction rather than stopping at the cursor. Its existing projectile effects are retained.

**Self-centred spells:** optional component #1 adds caster-only selection to area spells such as Prayer, Recitation and Sunfire. Invalid targets retain the casting cursor with the native disabled colour. Personal buffs such as Mirror Image and Stoneskin keep their existing direct-cast behaviour. See the [spell list](IWD2EE_Spell_Indicators/Self-centred-spells.md) and [script compatibility audit](IWD2EE_Spell_Indicators/Self-centred-audit.md).

## Installation

1. Exit the game. Install IWD2EE Core first, followed by any spell-changing mods.
2. Download this repository as a ZIP and extract it. Copy the `IWD2EE_Spell_Indicators` folder and `setup-IWD2EE_Spell_Indicators.exe` into the game directory containing `IWD2.exe`.
3. Uninstall the older `I2T_AOE_Sample #0` if present. Before installing #1, also uninstall the older Prayer trial, `I2SI_SelfAOE_Trial #0`.
4. Run `setup-IWD2EE_Spell_Indicators.exe`. Install #0 and optionally #1.

No Python, BG2 artwork or save editing is required. Bindings are generated from the installed spell headers. Reinstall after another mod changes those headers or projectiles. To uninstall, exit the game and run the same installer again.

## Compatibility and limits

- Intended for the verified Windows IWD2 / IWD2EE engine. Hooks check instruction signatures before installing.
- Outlines represent geometry, not guaranteed hits: walls, line of sight, allegiance and immunities still apply. Bounces and later projectile reflections are not predicted.
- Cone projection is a visual approximation. IWD2EE Patch #25 is recommended for its caster-centred cone-origin correction.
- Unknown projectiles, chain spells and sight-wide/map-wide targeting are not assigned guessed shapes. Wall and four-way previews need further testing across all angles and mod combinations.
- No damage increase or general area increase is applied. The explicit gameplay changes are Boulder Roll direction selection (#0), and self-centred selection plus necessary ordinary BCS call corrections (#1).
- Tactics precombat/combat opcode-based buff casting remains unchanged. This repository contains no game executable, copied game artwork, saves or development backups.

## Installer attribution

The included Windows installer is unmodified **WeiDU 24900**, renamed for the mod. Its license and upstream source links are included in [THIRD_PARTY.md](IWD2EE_Spell_Indicators/THIRD_PARTY.md) and [WeiDU-COPYING.txt](IWD2EE_Spell_Indicators/WeiDU-COPYING.txt).
