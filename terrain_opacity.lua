local terrainPng=textures['terrain'] or textures['textures.terrain']

local opacityRegions={
   {vec(48, 64, 16, 16), 0.624},
   {vec(64, 192, 16, 16), 0.75}, -- not accurate but only way to save space
   {vec(208, 192, 48, 32), 0.561},
}

local x=0
local i=0

local emptyColor=vec(0, 0, 0, 0)

local function removeRed(col)
   if col.r > 0.99 and col.g < 0.01 and col.b > 0.99 then
      return emptyColor
   end
end

local function update()
   if i <= #opacityRegions then
      for _ = 1, 4 do
         i = i + 1
         if i > #opacityRegions then
            break
         end
         local v=opacityRegions[i]
         local r=v[1]
         local alpha=v[2]
         terrainPng:applyFunc(r.x,r.y,r.z,r.w,function(col)
            col.a=alpha
	         return col
         end)
      end
      return
   end
   terrainPng:applyFunc(x, 0, 16, 256, removeRed)
   x = x + 16
   if x >= 256 then
      terrainPng:update()
      return true
   end
end

return update