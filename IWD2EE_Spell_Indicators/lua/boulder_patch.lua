IEex_AbsoluteOnce('I2SI_BoulderRay',function()
    if IEex_Vanilla then return end
    local address=0x56F9ED
    local expected={0x8B,0x4E,0x0A,0xC1,0xE1,0x02}
    for i,b in ipairs(expected) do
        if IEex_ReadByte(address+i-1,0)~=b then
            error('Spell Indicators: Boulder Roll initialization signature mismatch')
        end
    end
    IEex_DisableCodeProtection()
    local ok,err=pcall(function()
        IEex_HookRestore(address,0,6,IEex_FlattenTable({
            {'9C !push_all_registers_iwd2 81 3E D4 0A 85 00 !jne_dword >done'},
            IEex_GenLuaCall('I2SI_BoulderEndpoint',{args={{'!push(esi)'}}}),
            {'@call_error @done !pop_all_registers_iwd2 9D'},
        }))
    end)
    IEex_EnableCodeProtection()
    if not ok then error('Spell Indicators Boulder Roll assembly: '..tostring(err)) end
end)
