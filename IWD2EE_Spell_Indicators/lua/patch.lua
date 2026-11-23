IEex_AbsoluteOnce("I2SI_RenderHook",function()
    if IEex_Vanilla then return end
    -- CGameArea::Render, immediately after the engine's own selection outline.
    local address=0x477D3F
    local expected={0x8A,0x86,0xED,0x01,0x00,0x00}
    for i,b in ipairs(expected) do
        if IEex_ReadByte(address+i-1,0)~=b then
            print("IWD2EE Spell Indicators: render signature mismatch; no hook installed.")
            return
        end
    end
    IEex_DisableCodeProtection()
    local ok,err=pcall(function()
        IEex_HookRestore(address,0,6,IEex_FlattenTable({
            {"9C !push_all_registers_iwd2"},
            IEex_GenLuaCall("I2SI_Render",{args={{"!push(esi)"}}}),
            {"@call_error !pop_all_registers_iwd2 9D"},
        }))
    end)
    IEex_EnableCodeProtection()
    if not ok then error("IWD2EE Spell Indicators assembly failed: "..tostring(err)) end
    print("IWD2EE Spell Indicators: render hook installed (1.0.0).")
end)
