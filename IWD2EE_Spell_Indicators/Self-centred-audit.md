# Component1 compatibility audit

710 native script actions in 137 scripts inspected. 13 normal spell targets in five BCS normalized to Myself.

| Script | Before | After |
|---|---|---|
| `00SSCHRM` | `Spell(LastSeenBy(Myself),CLERIC_HEALING_CIRCLE)` | `Spell(Myself,CLERIC_HEALING_CIRCLE)` |
| `00SSMDOM` | `Spell(LastSeenBy(Myself),CLERIC_HEALING_CIRCLE)` | `Spell(Myself,CLERIC_HEALING_CIRCLE)` |
| `63MOUR1C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_MALAVONS_RAGE)` | `Spell(Myself,WIZARD_MALAVONS_RAGE)` |
| `63MOUR2C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_MALAVONS_RAGE)` | `Spell(Myself,WIZARD_MALAVONS_RAGE)` |
| `63MOUR2C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_WAIL_OF_THE_BANSHEE)` | `Spell(Myself,WIZARD_WAIL_OF_THE_BANSHEE)` |
| `63MOUR2C` | `Spell(NearestEnemyOf(Myself),WIZARD_SUNFIRE)` | `Spell(Myself,WIZARD_SUNFIRE)` |
| `63MOUR2C` | `Spell(SecondNearestEnemyOf(Myself),WIZARD_SUNFIRE)` | `Spell(Myself,WIZARD_SUNFIRE)` |
| `63MOUR2C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_SUNFIRE)` | `Spell(Myself,WIZARD_SUNFIRE)` |
| `63MOUR3C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_MALAVONS_RAGE)` | `Spell(Myself,WIZARD_MALAVONS_RAGE)` |
| `63MOUR3C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_WAIL_OF_THE_BANSHEE)` | `Spell(Myself,WIZARD_WAIL_OF_THE_BANSHEE)` |
| `63MOUR3C` | `Spell(NearestEnemyOf(Myself),WIZARD_SUNFIRE)` | `Spell(Myself,WIZARD_SUNFIRE)` |
| `63MOUR3C` | `Spell(SecondNearestEnemyOf(Myself),WIZARD_SUNFIRE)` | `Spell(Myself,WIZARD_SUNFIRE)` |
| `63MOUR3C` | `Spell(ThirdNearestEnemyOf(Myself),WIZARD_SUNFIRE)` | `Spell(Myself,WIZARD_SUNFIRE)` |

Forced and event calls deliberately preserved:

- `60OJAIHC`: `ForceSpell(LastHeardBy(Myself),CLERIC_INVISIBILITY_PURGE)`
- `60OJAIHC`: `ForceSpell(LastAttackerOf(Myself),CLERIC_INVISIBILITY_PURGE)`
- `60RECIT0`: `ForceSpellPoint([420.490],CLERIC_RECITATION)`
- `61PJAWD2`: `ForceSpell(LastTrigger,CLERIC_CIRCLE_OF_BLADES)`
- `61PJAWD3`: `ForceSpell(LastTrigger,CLERIC_CIRCLE_OF_BLADES)`
- `61PJAWDR`: `ForceSpell(LastTrigger,CLERIC_CIRCLE_OF_BLADES)`
- `61PPENDU`: `ApplySpell(LastTrigger,CLERIC_CIRCLE_OF_BLADES)`
- `61PPENDU`: `ApplySpell(LastTrigger,CLERIC_CIRCLE_OF_BLADES)`
- `63PPORFB`: `ReallyForceSpell("Isair2",WIZARD_EXECUTIONERS_EYES)`
- `63PPORFB`: `ReallyForceSpell("Madae2",CLERIC_HOLY_AURA)`
- `65YQUOGC`: `SpellWait(CLERIC_INVISIBILITY_PURGE)`

Native ForceSpell/ReallyForceSpell/ApplySpell, point actions and SpellWait do not enter the new ordinary-spell cancellation guard. No coordinator, CRE, ARE, save file or spell effect payload is changed.

Circle radii are based on native projectile constructors. The five fixed auras use their current native417 / MEAOESP2 parameters: True Seeing512, Executioner Eyes175, Repulsion200, Living Lightning200, Cloak of Fear50. Circle of Bones / Blades use native subclass radius70; Healing Circle uses native0x2A0 radius256. Widen is enabled only for the projectile types the installed IEex mutators can widen.

Checks: actual IEex assembler; execution of generated native lookup code for every supported resource and excluded target modes; self/forced/point action checks; isolated install/uninstall/reinstall; exact SPL byte whitelist; BCS preservation and round-trip checks.


## Gedlee’s Electric Loop, component1 version1.1.1

- Added SPWI227, all10 level-dependent headers. Native projectile369 constructs the same area subclass as Sunfire, radius70 (factory0x5285EB / ctor0x575B00); it is circular, not a special cone or chain.
- Spell(Myself,...) in51HARMG0 and SpellNoDec(Myself,...) inUSWITCHL are already explicit self targets. The construct-command ReallyForceSpell(MyTarget,...) in53PCGLMC deliberately retains its forced-target semantics and is not intercepted. No BCS changes are needed for this addition.
- Total28 public resources. Effect payloads, projectile IDs, level thresholds and cast times are unchanged.


## Component0 Boulder Roll, version1.2.0

USWI653 keeps projectile383 and its original range1000, cast time, damage and knockdown effects. Only its UI header target is changed from self5 to ground4, and the obsolete due-south sentence is updated. Native CProjectileArea initialization0x56F9CB/0x56F9E4 takes destination coordinates; movement0x5777D7 follows that destination. Directional behaviour still needs in-game verification. The preview uses the existing solid3px mouse-ended line, not a fabricated collision corridor.

## Component 0 Boulder Roll endpoint correction, 1.2.1
Native initializer 0x56F9ED is hooked after source/destination assignment, before velocity calculation. Only vtable 0x850AD4 / index382 is handled. Original update 0x5776E0 destroys the projectile when it arrives at C8/CC; a ground-target change alone therefore stopped at the clicked point. One-shot grid ray traversal now uses CSearchBitmap::GetCost (0x547A00), area+0x76C, the projectile terrain table+0xD0, and native 16x12 cells; first blocking cell/map edge supplies the endpoint. No sight-distance cap, no actor walking table, no per-tick scan. Original self-targeted script calls use the south fallback when source equals target. Real IEex assembly and mocked direction/wall/boundary checks passed; in-game test pending.

## Component 0 wall previews, 1.3.0
Projectile304: SPPR423, SPIN216; projectile370: SPPR427, USPR658. Native constructors0x5802B0/0x581CA0 set rectangle half-length70/half-width20 at2E6/2EA. Initialization0x580600 invokes0x55B010 with caster and target points. Preview invokes only that pure geometry helper on a private128-byte buffer and averages opposite short-edge corners; it does not construct a projectile or native collection. Native rectangle uses16-direction quantization and its own coordinate projection; no extra visual compression is applied. World coordinates are supplied so camera scrolling cannot change quantization.
USWI554 projectile304 uses MEWOFORC instead: USWI554D special5 makes5 blockers at targetY+7,30-pixel spacing. Preview line joins the outer blocker centres. Direction uses native0x706DD0 with Y*4/3, as in0x52A480, then the original folded animation angle; cdecl stack cleanup is8. It does not claim blocker collision thickness.
USWI867 projectile1 uses MEPRISWL and MERECTSP: seven layers offset20px along quantized22.5-degree ray; each affected rectangle has depth30 and half-width130 (special0x82001E). Each preview line lies halfway into that layer, spanning its actual width. No generic projectile1 spell is included.
Native helper has no world mutation/allocation, only local arithmetic and writes to private output. Regression checks cover call argument order/ABI, signed coordinates, native-output mapping, cache,16 force directions,7 prism layers in8 directions and clipped3px rasterization. Real game visual test remains pending.

## Component0 Spiritual Wrath,1.3.1
SPPR612 uses ground target4/projectile312. Factory0x527258 calls constructor0x57F210, vtable0x85133C, initializer0x57F390. At0x57F3F8 the native code takes raw target-minus-caster X/Y;0x57F43B onwards generates perpendicular/opposite endpoints via0x5847B0. Four child line projectiles use field2AE=300 at0x57F546. Preview follows the existing cursor-ended line convention with300 cap, constructs two centred axes equivalent to four rays, and uses the existing solid3px rasterizer. It previews initial aiming geometry, not downstream bounces. USES021D/USES022D/USWI956D also use312 but are self-target5 internal child spells and remain excluded. No SPL/BCS/action hook changes. Geometry invariants, near/far/zero mouse positions,8 directions and clipping passed; actual game test pending.
