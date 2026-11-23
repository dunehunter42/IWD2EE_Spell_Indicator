-- Geometry helpers are read-only. Never instantiate projectiles or consume a
-- metamagic charge while previewing. Work is limited to the selected caster.
I2SI_Geometry={}
local G=I2SI_Geometry
local function round(v)return math.floor(v+0.5)end

function G.actor(game,id)
    local objects=IEex_ReadDword(game+0x374C)
    if objects==0 then return nil end
    local entry=objects+bit.band(bit.rshift(id,16),0x7FFF)*12
    if IEex_ReadWord(entry+6,0)~=bit.band(id,0xFFFF) then return nil end
    local actor=IEex_ReadDword(entry+8)
    if actor~=0 and IEex_ReadByte(actor+4,0)==0x31 then return actor end
end

function G.resolve(res,header,actor)
    local original=I2SI_Spells[res]
    if not original then return nil end
    if original.headers then original=original.headers[header] or original.headers[0] end
    if not original then return nil end
    local c={};for k,v in pairs(original) do c[k]=v end
    local canonical=(ex_true_spell and ex_true_spell[res]) or res
    if canonical=="SPWI706" and c.kind=="cone" then c.width=c.width*2 end
    local areaSet,areaMult,rangeMult,widen=nil,100,100,false
    local source=c.target==4 and 1 or 0
    for _,offset in ipairs({0x5526,0x54FA}) do
        local node=IEex_ReadDword(actor+offset+4)
        local seen={};local count=0
        while node~=0 and not seen[node] and count<1024 do
            seen[node]=true;count=count+1
            local effect=IEex_ReadDword(node+8)-4
            if effect>0 and IEex_ReadDword(effect+0x10)==288 then
                local p2=IEex_ReadDword(effect+0x20)
                -- Native EXMETAMA ignores exhausted/disabled modifiers. Cancel
                -- Metamagic clears special immediately, before removing effects.
                -- Read it every frame; never use ex_metamagic_in_use (last cast).
                if p2==251 and IEex_ReadLString(effect+0x30,8)=="EXWIDSPL"
                    and IEex_ReadDword(effect+0x48)~=0 then widen=true end
                if p2==246 then
                    local flags=IEex_ReadDword(effect+0x40)
                    local condition=IEex_ReadWord(effect+0x48,0)
                    local limit=IEex_ReadWord(effect+0x4A,0)
                    if (bit.band(flags,0x10000)==0 or condition+1==c.p)
                        and (bit.band(flags,0x20000)==0 or condition==c.t)
                        and (bit.band(flags,0x40000)==0 or condition==source)
                        and (bit.band(flags,0x80000)==0 or limit>0) then
                        local value=IEex_ReadDword(effect+0x1C)
                        if c.t>=6 and c.t<=8 then
                            if bit.band(flags,0x1000000)~=0 then
                                if bit.band(flags,0x100)~=0 then areaSet=value
                                else areaMult=math.floor(areaMult*value/100) end
                            elseif bit.band(flags,0x8000000)~=0 then rangeMult=math.floor(rangeMult*value/100) end
                        end
                    end
                end
            end
            node=IEex_ReadDword(node)
        end
    end
    local function area(value)
        value=math.floor((areaSet or value)*areaMult/100)
        if widen and c.wide then value=math.floor(value*1.5) end
        return value
    end
    if c.radius then c.radius=area(c.radius) end
    if c.width then c.width=area(c.width) end
    if c.trigger then c.trigger=math.floor(c.trigger*rangeMult/100) end
    if c.kind=="cone" then c.length=math.floor(c.length*rangeMult/100) end
    if (c.radius and (c.radius<1 or c.radius>2000)) or (c.width and (c.width<1 or c.width>2000)) then return nil end
    return c
end

-- Use the same 3/4 vertical projection as circular previews. Undo projection
-- on the cursor direction first; build a symmetric ground-space trapezoid,
-- then project all its vertices. The displayed axis still points at the mouse.
-- This is a preview adjustment only; native hit geometry is unchanged.
function G.coneVertices(c,sx,sy,ux,uy,pulse)
    local vertical=0.75
    uy=uy/vertical
    local norm=math.sqrt(ux*ux+uy*uy)
    ux,uy=ux/norm,uy/norm
    -- Same real-time pixel pulse as the circular wedges. Add a small outline
    -- displacement rather than scaling the whole cone; the caster stays fixed.
    pulse=pulse or 0
    local near=c.padding+pulse
    local far=math.floor(c.width/2)+c.padding+pulse
    local depth=c.length+c.padding+pulse
    local px,py=-uy,ux
    return {sx+px*near,sy+py*near*vertical},
        {sx-px*near,sy-py*near*vertical},
        {sx+ux*depth+px*far,sy+(uy*depth+py*far)*vertical},
        {sx+ux*depth-px*far,sy+(uy*depth-py*far)*vertical}
end

-- Rasterize a filled three-pixel rectangle, using its shorter screen dimension
-- for the scan axis. Every span is solid; independent oblique strokes cannot
-- leave cracks. Clip before drawing and never visit offscreen scan rows.
function G.lineSpans(sx,sy,tx,ty,left,top,right,bottom)
    local cache=G.lineSpanCache
    if cache and cache.sx==sx and cache.sy==sy and cache.tx==tx and cache.ty==ty
        and cache.left==left and cache.top==top and cache.right==right and cache.bottom==bottom then
        return cache.spans
    end
    local dx,dy=tx-sx,ty-sy
    local length=math.sqrt(dx*dx+dy*dy)
    if length<0.001 then return {} end
    local nx,ny=-dy/length*1.5,dx/length*1.5
    local vertices={{sx+nx,sy+ny},{tx+nx,ty+ny},
        {tx-nx,ty-ny},{sx-nx,sy-ny}}
    local swap=math.abs(dy)>math.abs(dx)
    local lo,hi=math.huge,-math.huge
    for _,v in ipairs(vertices) do
        if swap then v[1],v[2]=v[2],v[1] end
        lo=math.min(lo,v[2]);hi=math.max(hi,v[2])
    end
    local crossLo,crossHi=left,right
    local scanLo,scanHi=top,bottom
    if swap then crossLo,crossHi=top,bottom;scanLo,scanHi=left,right end
    local spans={}
    for row=math.max(scanLo,math.ceil(lo-0.5)),math.min(scanHi,math.ceil(hi-0.5)-1) do
        local y=row+0.5
        local a,b=math.huge,-math.huge
        for i=1,4 do
            local p,q=vertices[i],vertices[i%4+1]
            if (p[2]<=y and y<q[2]) or (q[2]<=y and y<p[2]) then
                local x=p[1]+(y-p[2])*(q[1]-p[1])/(q[2]-p[2])
                a=math.min(a,x);b=math.max(b,x)
            end
        end
        local first=math.max(crossLo,math.ceil(a-0.5-1e-9))
        local last=math.min(crossHi,math.ceil(b-0.5-1e-9)-1)
        if first<=last then
            if swap then spans[#spans+1]={row,first,row,last}
            else spans[#spans+1]={first,row,last,row} end
        end
    end
    G.lineSpanCache={sx=sx,sy=sy,tx=tx,ty=ty,left=left,top=top,right=right,bottom=bottom,spans=spans}
    return spans
end

-- Same read-only rectangle helper used by native Moonlight/Fire walls.
-- Output is written into our own buffer, without creating a projectile.
function G.wallSegments(c,sx,sy,tx,ty)
    local cached=G.wallCache
    if cached and cached.mode==c.wallMode and cached.sx==sx and cached.sy==sy
        and cached.tx==tx and cached.ty==ty then return cached.segments end
    local result={}
    if c.wallMode=="native" then
        if not G.wallBuffer then G.wallBuffer=IEex_Malloc(128) end
        local p=G.wallBuffer
        IEex_WriteDword(p+0x32,70);IEex_WriteDword(p+0x36,20)
        IEex_WriteDword(p+96,sx);IEex_WriteDword(p+100,sy)
        IEex_WriteDword(p+104,tx);IEex_WriteDword(p+108,ty)
        IEex_Call(0x55B010,{p+104,p+96},p,0)
        local function signed(a)
            local v=IEex_ReadDword(a);if v>=2147483648 then return v-4294967296 end;return v
        end
        result[1]={tx+(signed(p+0x3C)+signed(p+0x44))/2,
            ty+(signed(p+0x40)+signed(p+0x48))/2,
            tx+(signed(p+0x4C)+signed(p+0x54))/2,
            ty+(signed(p+0x50)+signed(p+0x58))/2}
    elseif c.wallMode=="force" then
        if not G.wallBuffer then G.wallBuffer=IEex_Malloc(128) end
        local p=G.wallBuffer
        IEex_WriteDword(p+96,sx);IEex_WriteDword(p+100,math.floor(sy*4/3))
        IEex_WriteDword(p+104,tx);IEex_WriteDword(p+108,math.floor(ty*4/3))
        local direction=IEex_Call(0x706DD0,{p+104,p+96},nil,8)%16
        -- MEWOFORC: five blockers spaced 30 pixels, centre shifted down 7.
        local angle=math.rad(-90+(direction%8)*22.5)
        if direction==8 then angle=math.pi/2 end
        local dx=math.floor(-math.sin(angle)*30)
        local dy=math.floor(math.cos(angle)*30)
        result[1]={tx-dx*2,ty+7-dy*2,tx+dx*2,ty+7+dy*2}
    elseif c.wallMode=="prismatic" then
        -- MEPRISWL: seven layers, 20 pixels apart. MERECTSP: half-width
        -- 130, depth 30. Each line lies inside its corresponding layer.
        local dx,dy=tx-sx,ty-sy
        local angle=dx==0 and (dy>=0 and 90 or -90) or math.deg(math.atan(dy/dx))
        for i=0,8 do
            local a=-90+i*22.5
            if math.abs(angle-a)<=11.25 then angle=a;break end
        end
        angle=math.rad(angle)
        local stepX,stepY=math.floor(math.cos(angle)*20),math.floor(math.sin(angle)*20)
        local ax,ay=math.floor(130*math.sin(angle)),-math.floor(130*math.cos(angle))
        local depthX,depthY=math.floor(30*math.cos(angle))/2,math.floor(30*math.sin(angle))/2
        local sign=dx>=0 and 1 or -1
        for i=0,6 do
            local x,y=tx+sign*stepX*i+depthX,ty+sign*stepY*i+depthY
            result[#result+1]={x-ax,y-ay,x+ax,y+ay}
        end
    end
    G.wallCache={mode=c.wallMode,sx=sx,sy=sy,tx=tx,ty=ty,segments=result}
    return result
end

function G.crossSegments(sx,sy,tx,ty,maximum)
    local dx,dy=tx-sx,ty-sy
    local length=math.sqrt(dx*dx+dy*dy)
    if length<0.001 then return {} end
    local scale=math.min(length,maximum)/length
    dx,dy=dx*scale,dy*scale
    -- Spiritual Wrath's initializer rotates the raw coordinate delta by
    -- 90 degrees. Do not apply the cone/circle projection a second time.
    return {{sx-dx,sy-dy,sx+dx,sy+dy},
        {sx-dy,sy+dx,sx+dy,sy-dx}}
end

function G.draw(c,ctx)
    local p=ctx.p
    local function clip(l,t,r,b)
        IEex_WriteDword(p+16,l);IEex_WriteDword(p+20,t)
        IEex_WriteDword(p+24,r);IEex_WriteDword(p+28,b)
    end
    local function colour(rgb)
        local value=IEex_Call(0x795FB0,{rgb},ctx.video,0)
        return IEex_Call(0x795E00,{value},ctx.video,0)
    end
    local green=colour(0x00FF00)
    local function line(ax,ay,bx,by,color)
        clip(ctx.left,ctx.top,ctx.right,ctx.bottom)
        IEex_Call(ctx.line,{color,p+16,0,round(by),round(bx),round(ay),round(ax)},ctx.mode,0)
    end
    local function circle(x,y,radius,color,breathing)
        local rx,ry=radius,math.floor(radius*3/4)
        IEex_WriteDword(p+8,rx);IEex_WriteDword(p+12,ry)
        for quadrant=0,3 do
            local angle=quadrant*math.pi/2-math.pi/2
            local pulse=breathing and ctx.pulse or 0
            local cx,cy=round(x+math.cos(angle)*pulse),round(y+math.sin(angle)*pulse)
            local a,b=angle-math.pi/6,angle+math.pi/6
            local ax,ay=round(cx+rx*math.cos(a)),round(cy+ry*math.sin(a))
            local bx,by=round(cx+rx*math.cos(b)),round(cy+ry*math.sin(b))
            local tipx=round(cx+((ax+bx)/2-cx)*0.25)
            local tipy=round(cy+((ay+by)/2-cy)*0.25)
            local l,t,r,bottom
            if quadrant==0 then l,t,r,bottom=cx-rx/2,cy-ry-1,cx+rx/2,cy
            elseif quadrant==1 then l,t,r,bottom=cx,cy-ry/2,cx+rx+1,cy+ry/2
            elseif quadrant==2 then l,t,r,bottom=cx-rx/2,cy,cx+rx/2,cy+ry+1
            else l,t,r,bottom=cx-rx-1,cy-ry/2,cx,cy+ry/2 end
            l=math.max(round(l),ctx.left);r=math.min(round(r),ctx.right)
            t=math.max(round(t),ctx.top);bottom=math.min(round(bottom),ctx.bottom)
            if l<r and t<bottom then
                IEex_WriteDword(p,cx);IEex_WriteDword(p+4,cy);clip(l,t,r,bottom)
                IEex_Call(ctx.ellipse,{color,p+16,p+8,p},ctx.mode,0)
            end
            line(ax,ay,tipx,tipy,color);line(tipx,tipy,bx,by,color)
        end
    end
    if c.kind=="circle" or c.kind=="trap" then
        circle(ctx.x,ctx.y,c.radius,green,true)
        if c.kind=="trap" then
            -- Same four wedges and phase as the damage boundary, but yellow.
            -- The independent trigger radius never inherits Widen's area bonus.
            local yellow=colour(0x00FFFF)
            circle(ctx.x,ctx.y,c.trigger,yellow,true)
        end
        return
    end
    if c.kind=="wall" then
        local sx,sy=ctx.worldSX,ctx.worldSY
        local ox,oy=ctx.sx-sx,ctx.sy-sy
        clip(ctx.left,ctx.top,ctx.right,ctx.bottom)
        for _,segment in ipairs(G.wallSegments(c,sx,sy,ctx.worldX,ctx.worldY)) do
            for _,span in ipairs(G.lineSpans(segment[1]+ox,segment[2]+oy,
                segment[3]+ox,segment[4]+oy,ctx.left,ctx.top,ctx.right,ctx.bottom)) do
                IEex_Call(ctx.line,{green,p+16,0,span[4],span[3],span[2],span[1]},ctx.mode,0)
            end
        end
        return
    end
    local sx,sy=ctx.sx,ctx.sy
    local dx,dy=ctx.x-sx,ctx.y-sy
    local length=math.sqrt(dx*dx+dy*dy)
    if length<0.001 then return end
    local ux,uy=dx/length,dy/length
    if c.kind=="cross" then
        clip(ctx.left,ctx.top,ctx.right,ctx.bottom)
        for _,segment in ipairs(G.crossSegments(sx,sy,ctx.x,ctx.y,c.length)) do
            for _,span in ipairs(G.lineSpans(segment[1],segment[2],segment[3],segment[4],
                ctx.left,ctx.top,ctx.right,ctx.bottom)) do
                IEex_Call(ctx.line,{green,p+16,0,span[4],span[3],span[2],span[1]},ctx.mode,0)
            end
        end
    elseif c.kind=="line" then
        -- Initial straight trajectory only. Wall bounces and victim collision
        -- widths are deliberately not represented as a fabricated corridor.
        local previewLength=math.min(length,c.length)
        local tx,ty=sx+ux*previewLength,sy+uy*previewLength
        clip(ctx.left,ctx.top,ctx.right,ctx.bottom)
        for _,span in ipairs(G.lineSpans(sx,sy,tx,ty,
            ctx.left,ctx.top,ctx.right,ctx.bottom)) do
            IEex_Call(ctx.line,{green,p+16,0,span[4],span[3],span[2],span[1]},ctx.mode,0)
        end
    elseif c.kind=="cone" then
        local a,b,d,e=G.coneVertices(c,sx,sy,ux,uy,ctx.pulse)
        line(a[1],a[2],d[1],d[2],green);line(d[1],d[2],e[1],e[2],green)
        line(e[1],e[2],b[1],b[2],green);line(b[1],b[2],a[1],a[2],green)
    end
end
