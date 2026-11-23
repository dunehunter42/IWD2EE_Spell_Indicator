-- Spell Indicators: verified circular, trap, native cone and straight-path previews.
dofile("override/I2SI_Data.lua")
dofile("override/I2SI_Geometry.lua")
I2SI = I2SI or {enabled=true, draws=0}

local function render(area)
    if not I2SI.enabled or IEex_GetActiveEngine() ~= IEex_GetEngineWorld() then return end
    local game=IEex_GetGameData()
    local state=IEex_ReadWord(game+0x1B96,0)
    if (state~=1 and state~=2) or IEex_ReadByte(game+0x1B98,0)~=0x14 then return end
    if IEex_ReadDword(game+0x3896)~=1 then return end
    local head=IEex_ReadDword(game+0x388E)
    if head==0 then return end
    local actorID=IEex_ReadDword(head+8)
    -- Same generational handle lookup as CGameObjectArray, without taking a
    -- second actor share inside the area render critical section.
    local objects=IEex_ReadDword(game+0x374C)
    if objects==0 then return end
    local entry=objects+bit.band(bit.rshift(actorID,16),0x7FFF)*12
    if IEex_ReadWord(entry+6,0)~=bit.band(actorID,0xFFFF) then return end
    local actor=IEex_ReadDword(entry+8)
    if actor==0 or IEex_ReadByte(actor+4,0)~=0x31 or IEex_ReadDword(actor+0x12)~=area then return end
    -- 71A0E0 copies the chosen CButtonData to sprite+56A0 before targeting.
    local res=IEex_ReadLString(actor+0x56C0,8):upper()
    local cfg=I2SI_Geometry.resolve(res,IEex_ReadWord(actor+0x56BE,0),actor)
    if not cfg then return end

    local infinity=area+0x4CC
    local x,y=IEex_GetCursorXY()
    if not IEex_MouseInViewport(infinity,x,y) then return end
    local left=IEex_ReadDword(infinity+0x48)
    local top=IEex_ReadDword(infinity+0x4C)
    local right=IEex_ReadDword(infinity+0x50)-1
    local bottom=IEex_ReadDword(infinity+0x54)-1
    local mode=IEex_ReadDword(infinity+0x1C)
    if mode==0 then return end
    local ellipse=IEex_ReadDword(IEex_ReadDword(mode)+0x88)
    local line=IEex_ReadDword(IEex_ReadDword(mode)+0x98)
    if ellipse==0 then return end
    if line~=0x797A30 then error("unsupported native line renderer") end
    if not I2SI.buffer then I2SI.buffer=IEex_Malloc(32) end
    local p=I2SI.buffer

    local chitin=IEex_ReadDword(0x8CF6D8)
    local engine=IEex_ReadDword(chitin+0x3C4)
    if engine==0 then return end
    local video=IEex_ReadDword(engine+4)
    local cameraX=IEex_ReadDword(infinity+0x90)
    local cameraY=IEex_ReadDword(infinity+0x94)
    local sx=IEex_ReadDword(actor+6)-cameraX+left
    local sy=IEex_ReadDword(actor+10)-cameraY+top
    if cfg.selfcenter then
        x,y=sx,sy
    elseif cfg.target==2 then
        local picked=I2SI_Geometry.actor(game,IEex_ReadDword(area+0x246))
        if picked and IEex_ReadDword(picked+0x12)==area then
            x=IEex_ReadDword(picked+6)-cameraX+left
            y=IEex_ReadDword(picked+10)-cameraY+top
        end
    end
    local milliseconds=IEex_Call(IEex_ReadDword(0x847300),{},nil,0)
    local pulse=3*math.sin(milliseconds/180)-1
    pulse=pulse<0 and math.ceil(pulse) or math.floor(pulse)
    I2SI_Geometry.draw(cfg,{p=p,x=x,y=y,sx=sx,sy=sy,mode=mode,
        ellipse=ellipse,line=line,video=video,left=left,top=top,right=right,bottom=bottom,pulse=pulse,
        worldSX=IEex_ReadDword(actor+6),worldSY=IEex_ReadDword(actor+10),
        worldX=x+cameraX-left,worldY=y+cameraY-top})
    I2SI.draws=I2SI.draws+1
    if I2SI.draws==1 then print("IWD2EE Spell Indicators 1.0.0: range preview active; no spells or projectiles modified.") end

end

function I2SI_Render(area)
    local ok,err=pcall(render,area)
    if not ok and not I2SI.failed then
        I2SI.failed=true;I2SI.enabled=false
        print("IWD2EE Spell Indicators disabled after render error: "..tostring(err))
    end
end
