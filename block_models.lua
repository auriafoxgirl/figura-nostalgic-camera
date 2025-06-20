local terrainPng = textures['terrain'] or textures['model.terrain']
---@type {[string]: fun(pos: Vector3, endpos: Vector3, block: BlockState): Vector4, Entity.blockSide?}
local blockModels = {}

local facePosToUv = {
   up = matrices.mat4(vec(1, 0, 0, 0), vec(0, 0, 0, 0), vec(0, 1, 0, 0), vec(0, 0, 0, 0)),
   down = matrices.mat4(vec(1, 0, 0, 0), vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 1, 0, 0)),
   north = matrices.mat4(vec(-1, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 0, 0, 0), vec(1, 1, 0, 0)),
   south = matrices.mat4(vec(1, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 0, 0, 0), vec(0, 1, 0, 0)),
   east = matrices.mat4(vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(-1, 0, 0, 0), vec(1, 1, 0, 0)),
   west = matrices.mat4(vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(1, 0, 0, 0), vec(0, 1, 0, 0)),
}

do
   local aabbs = {
      {vec(0.1, 0.25, 0.1), vec(0.9, 0.25, 0.9)},
      {vec(0, 0, 0), vec(1, 1, 2 / 16)},
      {vec(0, 0, 0), vec(2 / 16, 1, 1)},
      {vec(14 / 16, 0, 0), vec(1, 1, 1)},
      {vec(0, 0, 14 / 16), vec(1, 1, 1)},
   }
   local minSize = vec(0.05, -1, 0.05)
   local maxSize = vec(0.99, 2, 0.99)
   blockModels["minecraft:cauldron"] = function(pos, endpos)
      local _, hitpos, side = raycast:aabb(pos, endpos, aabbs)
      if hitpos then
         local uv = facePosToUv[side]:apply(hitpos)
         if side == 'up' then
            if hitpos.y > 0.5 then
               return terrainPng:getPixel(160 + uv.x * 16, 128 + uv.y * 16), side
            else
               return terrainPng:getPixel(176 + uv.x * 16, 128 + uv.y * 16), side
            end
         elseif side == 'down' then
            return terrainPng:getPixel(176 + uv.x * 16, 128 + uv.y * 16), side
         else
            if hitpos > minSize and hitpos < maxSize then
               side = 'up'
            end
            return terrainPng:getPixel(160 + uv.x * 16, 144 + uv.y * 16), side
         end
      end
      return vec(0, 0, 0, 0)
   end
end

local makePlantModel
do
local plantModelAabbOffset = (2 ^ 0.5 - 1) * 0.5
local plantModelAabb1 = {
   {vec(plantModelAabbOffset, 0, 0), vec(1 + plantModelAabbOffset, 1, 0)},
}
local plantModelAabb2 = {
   {vec(0.5 + plantModelAabbOffset, 0, -0.5), vec(0.5 + plantModelAabbOffset, 1, 0.5)},
}
local plantModelPosRotMat = matrices.rotation3(0, 45, 0)
local emptyVec4 = vec(0, 0, 0, 0)
---@param uvOffset Vector2
function makePlantModel(uvOffset)
   local uvOffsetX = uvOffset.x
   local uvOffsetY = uvOffset.y + 16
   return function(pos, endpos)
      pos = pos * plantModelPosRotMat
      endpos = endpos * plantModelPosRotMat
      local _, hitpos, side = raycast:aabb(
         pos,
         endpos,
         plantModelAabb1
      )
      local color1 = emptyVec4
      local depth1 = 99
      if side then
         depth1 = (pos - hitpos):lengthSquared()
         local uv = hitpos.xy - vec(plantModelAabbOffset, 0)
         if side == 'north' then
            uv.x = 1 - uv.x
         end
         -- color1 = vec(uv.x, uv.y, 0, 1)
         color1 = terrainPng:getPixel(uv.x * 16 + uvOffsetX, uv.y * -16 + uvOffsetY)
      end
      _, hitpos, side = raycast:aabb(
         pos,
         endpos,
         plantModelAabb2
      )
      local depth2 = 99
      local color2 = emptyVec4
      if side then
         depth2 = (pos - hitpos):lengthSquared()
         local uv = hitpos.zy + vec(0.5, 0)
         if side == 'east' then
            uv.x = 1 - uv.x
         end
         -- color2 = vec(uv.x, uv.y, 0.2, 1)
         color2 = terrainPng:getPixel(uv.x * 16 + uvOffsetX, uv.y * -16 + uvOffsetY)
      end
      return depth2 < depth1 and color2.a == 1 and color2 or color1, 'up'
   end
end
end

blockModels['minecraft:dead_bush'] = makePlantModel(vec(112, 48))
blockModels['minecraft:short_grass'] = makePlantModel(vec(112, 32))
blockModels['minecraft:fern'] = makePlantModel(vec(128, 48))
blockModels['minecraft:sugar_cane'] = makePlantModel(vec(144, 64))
blockModels['minecraft:oak_sapling'] = makePlantModel(vec(240, 0))
blockModels['minecraft:spruce_sapling'] = makePlantModel(vec(240, 48))
blockModels['minecraft:birch_sapling'] = makePlantModel(vec(240, 64))
blockModels['minecraft:poppy'] = makePlantModel(vec(192, 0))
blockModels['minecraft:dandelion'] = makePlantModel(vec(208, 0))
blockModels['minecraft:cobweb'] = makePlantModel(vec(176, 0))
blockModels['minecraft:red_mushroom'] = makePlantModel(vec(192, 16))
blockModels['minecraft:brown_mushroom'] = makePlantModel(vec(208, 16))
blockModels['minecraft:pumpkin_stem'] = makePlantModel(vec(240, 96))
blockModels['minecraft:melon_stem'] = makePlantModel(vec(240, 96))

do
local aabb1 = { {vec(0.5, 0, 0), vec(0.5, 1, 1)} }
local aabb2 = { {vec(0, 0, 0.5), vec(1, 1, 0.5)} }
local plantModel = makePlantModel(vec(208, 160))
blockModels['minecraft:attached_pumpkin_stem'] = function(pos, endPos, block)
   local color = plantModel(pos, endPos)
   if color.a > 0.1 then
      return color, 'up'
   end
   local facing = block.properties.facing
   if facing == 'north' or facing == 'south' then
      local _, hitpos = raycast:aabb(pos, endPos, aabb1)
      if hitpos then
         if facing == 'south' then
            hitpos.z = 1 - hitpos.z
         end
         return terrainPng:getPixel(240 + hitpos.z * 16, 128 - hitpos.y * 16), 'up'
      end
   else
      local _, hitpos = raycast:aabb(pos, endPos, aabb2)
      if hitpos then
         if facing == 'east' then
            hitpos.x = 1 - hitpos.x
         end
         return terrainPng:getPixel(240 + hitpos.x * 16, 128 - hitpos.y * 16), 'up'
      end
   end
   return vec(0, 0, 0, 0)
end
blockModels['minecraft:attached_melon_stem'] = blockModels['minecraft:attached_pumpkin_stem']
end

do
local aabbs = {
   {vec(6, 15, 6) / 16, vec(10, 16, 10) / 16},
   {vec(5, 14, 5) / 16, vec(11, 15, 11) / 16},
   {vec(4, 13, 4) / 16, vec(12, 14, 12) / 16},
   {vec(3, 0, 3) / 16, vec(13, 13, 13) / 16},
   {vec(2, 1, 2) / 16, vec(14, 11, 14) / 16},
   {vec(1, 3, 1) / 16, vec(15, 8, 15) / 16},
}
blockModels['minecraft:dragon_egg'] = function(pos, endPos)
   local _, hitpos, face = raycast:aabb(pos, endPos, aabbs)
   if face then
      local uv = facePosToUv[face]:apply(hitpos)
      return terrainPng:getPixel(112 + uv.x * 16, 160 + uv.y * 16), face
   end
   return vec(0, 0, 0, 0)
end
end

return blockModels