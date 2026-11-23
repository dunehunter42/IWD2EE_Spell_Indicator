-- Optional component1; original effects and forced/area casts are unchanged.
if I2SI_SelfTargetLoaded then return end
I2SI_SelfTargetLoaded=true
dofile("override/I2SI_SelfData.lua")
for res,spec in pairs(I2SI_SelfSpecs)do I2SI_Spells[res]=spec end
function I2SI_SelfTargetAction(actionData,actor)
 local action=IEex_GetActionID(actionData)
 -- ForceSpell/ReallyForceSpell/ApplySpell and point-cast trap/cutscene actions
 -- deliberately retain their original explicit target semantics.
 if action~=31 and action~=191 then return end
 local res=IEex_GetActionString1(actionData):upper()
 if res=="" then
  local id=IEex_GetActionInt1(actionData)
  local prefix=IEex_SpellIDSPrefix[math.floor(id/1000)]
  if prefix then res=prefix..string.format("%03d",id%1000)end
 end
 if not I2SI_SelfTargets[res] then return end
 if IEex_GetActionObjectID(actionData)~=IEex_GetActorIDShare(actor) then
  IEex_SetActionID(actionData,0)
 end
end
IEex_AddActionHookGlobal("I2SI_SelfTargetAction")
