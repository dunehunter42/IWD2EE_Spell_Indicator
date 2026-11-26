# Changes

## 1.3.2 — Mass Spell (2026-11-26)

- Preview the native Mass replacement area for eligible creature- and ground-targeted spells, including spells with no ordinary area preview.
- Read pending Mass state each frame; cancel immediately without consuming charges or invoking native metamagic mutators.
- Combine Mass with Widen and applicable equipment modifiers in native order.
- Follow the hovered creature for Mass actor targets; preserve self-centred anchoring where applicable.
- Fall back to header zero for missing/sentinel ability indices. Mass + Luck passed in-game testing; modifier combinations also passed offline native-function and regression checks.
- Retain the actual native radius256 (Fireball200), despite the IWD2EE description saying20 feet. No actual range change is included.
- Remove temporary Luck diagnostic logging from the published source.


## 2026-11-22 — Widen and Cancel Metamagic correction

- Read pending Widen state on every frame and require a nonzero modifier special value, matching native EXMETAMA.
- Restore the normal preview immediately when Cancel Metamagic clears the marker, without waiting for effect removal.
- Retain supported equipment area modifiers, including Staff of Widening; combine them with pending Widen using native rules.
- Preserve independent trap trigger radii, native widen eligibility and the existing geometry/rendering.
- Self-centred previews use the same modifier handling.

## 1.3.1 — Spiritual Wrath

- Preview the four initial paths: toward the cursor, opposite, and perpendicular in both directions.
- Preserve native raw-coordinate rotation. Each initial preview ray is limited to 300 pixels; later bounces are not simulated.

## 1.3.0 — Wall previews

- Add Wall of Moonlight, Wall of Fire, Trial by Fire, Wall of Force and Prismatic Wall.
- Use native wall geometry where available; show seven parallel layers for Prismatic Wall.
- Keep solid three-pixel green lines and cache unchanged geometry.

## 1.2.1 — Boulder Roll endpoint correction

- A ground click selects a direction rather than the projectile's stopping point.
- Use native terrain queries and the boulder's terrain table to choose the endpoint before an obstruction or at the map edge.
- Preserve existing projectile movement, damage, knockdown and arrival processing. The preview shows only the initial direction.

## Self-centred area selection — component #1

- Offer 28 self-centred area spells as preview-then-click-self casts; leave personal buffs unchanged.
- Keep the casting cursor and use its native disabled colour for other targets.
- Preserve spell effects and expansion animations; normalize the audited ordinary BCS casts to `Myself` without changing their conditions or order.
- Keep event/forced casts and Tactics opcode-based buff paths unchanged.
- Include Gedlee's Electric Loop; exclude sight-wide/map-wide spells and unsupported special geometry.

## 1.0.0 — Independent mod

- Promote the tested independent sample v0.11 to IWD2EE Spell Indicators #0.
- Preserve circular/cone breathing, trap dual-colour outlines, 75% ground projection and three-pixel solid straight paths with flat ends.
- Generate spell/header bindings at installation from the current SPL resources.
- Use independent I2SI names and prevent simultaneous installation of the old sample.
- Verify uninstall restoration, deterministic reinstall and geometry matching for the 246 spell resources / 649 headers in the development snapshot. Counts vary with the installation.

## 2026-11-23 — Repository documentation

- Consolidate current features, installation, optional components, modifier support and known limitations into the README.
- Add an English repository landing page and preserve the Chinese package documentation.
- Package only mod sources, documentation and the attributed WeiDU installer; exclude game assets, saves and development files.


