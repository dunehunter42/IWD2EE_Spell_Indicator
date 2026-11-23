-- At SetCursor normal-return tail, after native colour reset.
-- Keep the spell icon; apply the native disabled/grey treatment to nonself.
-- No runtime Lua callback or recursive SetCursor call.
IEex_AbsoluteOnce("I2SI_SelfTargetCursor",function()
 if IEex_Vanilla then return end
 dofile("override/I2SI_SelfData.lua")
 local resources={};for res in pairs(I2SI_SelfTargets)do resources[#resources+1]=res end
 table.sort(resources)
 if #resources==0 then return end
 local resourceTable=IEex_Malloc(#resources*8)
 for i,res in ipairs(resources)do
  for j=1,8 do IEex_WriteByte(resourceTable+(i-1)*8+j-1,res:byte(j) or 0)end
 end
 local address=0x5975E0
 for i,b in ipairs({0x5E,0x5D,0x5B,0x83,0xC4,0x10}) do
  if IEex_ReadByte(address+i-1,0)~=b then
   error("Self-centred spell cursor: native cursor signature mismatch")
  end
 end
 IEex_DisableCodeProtection()
 local ok,err=pcall(function()
  IEex_HookRestore(address,0,6,{[[
   9C 60                             ; save flags and all eight registers ;
   83 7C 24 44 14                    ; original first arg cursor20 ;
   !jne_dword >done
   A1 DC F6 8C 00                    ; chitin ;
   85 C0
   !je_dword >done
   8B 80 54 1C 00 00                 ; game ;
   85 C0
   !je_dword >done
   80 B8 98 1B 00 00 14              ; spell targeting cursor ;
   !jne_dword >done
   0F B7 88 96 1B 00 00              ; targeting state1 or2 ;
   49
   83 F9 01
   !ja_dword >done
   83 B8 96 38 00 00 01              ; one selected caster ;
   !jne_dword >done
   8B 88 8E 38 00 00                 ; selected list head ;
   85 C9
   !je_dword >done
   8B 51 08                          ; selected actor handle ;
   8B 80 4C 37 00 00                 ; object array ;
   85 C0
   !je_dword >done
   8B CA C1 E9 10 81 E1 FF 7F 00 00 ; handle index ;
   8D 0C 49 C1 E1 02 03 C8           ; entry=array+index*12 ;
   66 39 51 06                       ; handle generation ;
   !jne_dword >done
   8B 49 08
   85 C9
   !je_dword >done
   80 79 04 31                       ; actor sprite ;
   !jne_dword >done
   8B 81 C0 56 00 00                 ; selected resref low dword ;
   8B 99 C4 56 00 00                 ; selected resref high dword ;
   BF ]],{resourceTable,4},[[
   BD ]],{#resources,4},[[
   @resource_loop
   3B 07
   !jne_dword >resource_next
   3B 5F 04
   !je_dword >resource_found
   @resource_next
   83 C7 08 4D
   !jne_dword >resource_loop
   !jmp_dword >done
   @resource_found
   8B 49 12                          ; caster area ;
   85 C9
   !je_dword >done
   39 91 46 02 00 00                 ; hover actor == selected caster ;
   !je_dword >done
   6A 01 8B CE B8 10 76 59 00 FF D0 ; SetCursorGrey(true), this=esi ;
   @done
   61 9D
  ]]})
 end)
 IEex_EnableCodeProtection()
 if not ok then error("Self-centred spell cursor assembly failed: "..tostring(err)) end
 print("Spell Indicators component1: native self-only grey spell cursors installed.")
end)
