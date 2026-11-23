-- Run once when the native rolling projectile receives its launch coordinates.
-- The mouse selects a ray, not a stopping point. Keep the native projectile,
-- velocity calculation, pulse effects and arrival/destruction processing.
function I2SI_BoulderEndpoint(p)
    if IEex_ReadDword(p) ~= 0x850AD4 or IEex_ReadWord(p+0x6E,0) ~= 382 then return end
    local area=IEex_ReadDword(p+0xEA)
    if area==0 then return end
    local x,y=IEex_ReadDword(p+6),IEex_ReadDword(p+10)
    local dx,dy=IEex_ReadDword(p+0xC8)-x,IEex_ReadDword(p+0xCC)-y
    if dx==0 and dy==0 then dy=1 end -- original self-targeted casts roll south
    local cols,rows=IEex_ReadDword(area+0x852),IEex_ReadDword(area+0x856)
    if cols<=0 or rows<=0 or cols>4096 or rows>4096 then return end
    local cx,cy=math.floor(x/16),math.floor(y/12)
    local sx,sy=dx>=0 and 1 or -1,dy>=0 and 1 or -1
    local tx=dx==0 and math.huge or ((cx+(sx>0 and 1 or 0))*16-x)/dx
    local ty=dy==0 and math.huge or ((cy+(sy>0 and 1 or 0))*12-y)/dy
    local stepx=dx==0 and math.huge or 16/math.abs(dx)
    local stepy=dy==0 and math.huge or 12/math.abs(dy)
    local scratch=IEex_Malloc(12)
    local function blocked(gx,gy)
        if gx<0 or gy<0 or gx>=cols or gy>=rows then return true end
        IEex_WriteDword(scratch,gx);IEex_WriteDword(scratch+4,gy)
        -- Native search-map lookup, including closed doors; use the rolling
        -- projectile's own terrain table, never the caster's walking rules.
        return IEex_Call(0x547A00,{0,scratch+8,p+0xD0,scratch},area+0x76C,0)%256==255
    end
    local ok,err=pcall(function()
        for i=1,cols+rows+2 do
            local t=math.min(tx,ty)
            local bx,by=tx<=ty,ty<=tx
            if (bx and blocked(cx+sx,cy)) or (by and blocked(cx,cy+sy))
                or (bx and by and blocked(cx+sx,cy+sy)) then
                -- Stop just before entering the first blocking cell. Native
                -- arrival processing handles disappearance and final effects.
                local epsilon=0.5/math.max(math.abs(dx),math.abs(dy))
                t=math.max(0,t-epsilon)
                IEex_WriteDword(p+0xC8,math.floor(x+dx*t+0.5))
                IEex_WriteDword(p+0xCC,math.floor(y+dy*t+0.5))
                return
            end
            if bx then cx=cx+sx;tx=tx+stepx end
            if by then cy=cy+sy;ty=ty+stepy end
        end
    end)
    IEex_Free(scratch)
    if not ok then print('Spell Indicators Boulder Roll: '..tostring(err)) end
end
