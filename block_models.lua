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

local faceToN = {
   north = 0,
   west = 1,
   south = 2,
   east = 3,
}

---@param aabbs {[1]: Vector3, [2]: Vector3}[]
---@param rot Vector3
---@return {[1]: Vector3, [2]: Vector3}[]
local function rotateAabbs(aabbs, rot)
   local newAabbs = {}
   local rotMat = matrices.translate4(-0.5, -0.5, -0.5):rotate(rot):translate(0.5, 0.5, 0.5)
   for i, v in pairs(aabbs) do
      newAabbs[i] = {rotMat:apply(v[1]), rotMat:apply(v[2])}
   end
   return newAabbs
end

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

do
local aabbsSmall = {
   {vec(1 / 16, 0, 1 / 16), vec(15 / 16, 14 / 16, 15 / 16)},
   {vec(7 / 16, 7 / 16, 0), vec(9 / 16, 11 / 16, 1 / 16)},
}
local aabbsSmallRots = {
   [0] = aabbsSmall,
   rotateAabbs(aabbsSmall, vec(0, 90, 0)),
   rotateAabbs(aabbsSmall, vec(0, 180, 0)),
   rotateAabbs(aabbsSmall, vec(0, 270, 0)),
}
local aabbsBig = {
   {vec(-7 / 16, 0, 1 / 16), vec(23 / 16, 14 / 16, 15 / 16)},
   {vec(7 / 16, 7 / 16, 0), vec(9 / 16, 11 / 16, 1 / 16)},
}
local aabbsBigRots = {
   [0] = aabbsBig,
   rotateAabbs(aabbsBig, vec(0, 90, 0)),
   rotateAabbs(aabbsBig, vec(0, 180, 0)),
   rotateAabbs(aabbsBig, vec(0, 270, 0)),
}
local bigChestOffsets = {
   [0] = vec(0.5, 0, 0),
   vec(0, 0, -0.5),
   vec(-0.5, 0, 0),
   vec(0, 0, 0.5),
}

blockModels['minecraft:chest'] = function(pos, endPos, block)
   local faceN = faceToN[block.properties.facing]
   if block.properties.type == 'single' then
      local _, hitpos, face = raycast:aabb(pos, endPos, aabbsSmallRots[ faceN ])
      if face then
         local uv = facePosToUv[face]:apply(hitpos)
         if face == 'up' or face == 'down' then
            return terrainPng:getPixel(144 + uv.x * 16, 16 + uv.y * 16), face
         end
         faceN = (faceN - faceToN[ face ]) % 4
         if faceN == 0 then
            return terrainPng:getPixel(176 + uv.x * 16, 16 + uv.y * 16), face
         else
            return terrainPng:getPixel(160 + uv.x * 16, 16 + uv.y * 16), face
         end
      end
      return vec(0, 0, 0, 0)
   end
   local posOffset = bigChestOffsets[faceN]
   if block.properties.type == "left" then
      posOffset = -posOffset
   end
   pos = pos + posOffset
   endPos = endPos + posOffset
   local _, hitpos, face = raycast:aabb(pos, endPos, aabbsBigRots[ faceN ])
   if face then
      local uv = facePosToUv[face]:apply(hitpos)
      if face == 'up' or face == 'down' then
         if faceN == 1 or faceN == 3 then
            uv.x, uv.y = 1 - uv.y, uv.x
         end
         return terrainPng:getPixel(184 + uv.x * 16, 160 + uv.y * 16), face
      end
      faceN = (faceN - faceToN[ face ]) % 4
      if faceN == 0 then
         return terrainPng:getPixel(152 + uv.x * 16, 32 + uv.y * 16), face
      elseif faceN == 2 then
         return terrainPng:getPixel(152 + uv.x * 16, 48 + uv.y * 16), face
      end
      return terrainPng:getPixel(160 + uv.x * 16, 16 + uv.y * 16), face
   end
   return vec(0, 0, 0, 0)
end

end

do
local aabbs = {
   {vec(0, 0, 15 / 16), vec(1, 1, 15 / 16)},
}
local aabbsRots = {
   [0] = aabbs,
   rotateAabbs(aabbs, vec(0, 90, 0)),
   rotateAabbs(aabbs, vec(0, 180, 0)),
   rotateAabbs(aabbs, vec(0, 270, 0)),
}
blockModels['minecraft:ladder'] = function(pos, endPos, block)
   local _, hitpos, face = raycast:aabb(pos, endPos, aabbsRots[ faceToN[block.properties.facing] ])
   if face then
      local uv = facePosToUv[face]:apply(hitpos)
      return terrainPng:getPixel(48 + uv.x * 16, 80 + uv.y * 16), face
   end
   return vec(0, 0, 0, 0)
end
end

local farmPlantModel
do
local aabbs = {
   { { vec(0.25, 0, 0), vec(0.25, 1, 1) } },
   { { vec(0.75, 0, 0), vec(0.75, 1, 1) } },
   { { vec(0, 0, 0.25), vec(1, 1, 0.25) } },
   { { vec(0, 0, 0.75), vec(1, 1, 0.75) } },
}
local emptyVec4 = vec(0, 0, 0, 0)
---@param pos Vector3
---@param endPos Vector3
---@param uvX number
---@param uvY number
---@return Vector4
function farmPlantModel(pos, endPos, uvX, uvY)
   local colors = {}
   local depths = {}
   for i, v in pairs(aabbs) do
      local _, hitpos, face = raycast:aabb(pos, endPos, v)
      depths[i] = 99
      colors[i] = emptyVec4
      if face then
         local uv = facePosToUv[face]:apply(hitpos)
         local color = terrainPng:getPixel(uvX + uv.x * 16, uvY + uv.y * 16)
         if color.a > 0.5 then
            colors[i] = color
            depths[i] = (hitpos - pos):lengthSquared()
         end
      end
   end
   local smallestDepth = 99
   local smallestI = 1
   for i, v in pairs(depths) do
      if v < smallestDepth then
         smallestDepth = v
         smallestI = i
      end
   end
   return colors[smallestI]
end

end

blockModels['minecraft:wheat'] = function(pos, endPos, block)
   return farmPlantModel(
      pos,
      endPos,
      128 + tonumber(block.properties.age) * 16,
      80
   ), 'up'
end

blockModels['minecraft:nether_wart'] = function(pos, endPos, block)
   local age = tonumber(block.properties.age)
   local offset = age == 0 and 0 or age == 3 and 32 or 16
   return farmPlantModel(
      pos,
      endPos,
      32 + offset,
      224
   ), 'up'
end

local torchModel
do

local wallTorchMat = matrices.mat4()
wallTorchMat:translate(0, -3 / 16, -8 / 16)
local skewMat = matrices.mat4()
skewMat.v32 = 0.25
wallTorchMat:multiply(skewMat)
local posMats = {
   [0] = wallTorchMat,
   matrices.mat4():translate(-0.5, 0, -0.5):rotate(0, -90, 0):translate(0.5, 0, 0.5):multiply(wallTorchMat),
   matrices.mat4():translate(-0.5, 0, -0.5):rotate(0, 180, 0):translate(0.5, 0, 0.5):multiply(wallTorchMat),
   matrices.mat4():translate(-0.5, 0, -0.5):rotate(0, 90, 0):translate(0.5, 0, 0.5):multiply(wallTorchMat),
   matrices.mat4()
}

local posMatsInverse = {}
for i, v in pairs(posMats) do
   posMatsInverse[i] = v:inverted()
end

local emptyVec4 = vec(0, 0, 0, 0)

-- local
---@param aabbs {[1]: Vector3, [2]: Vector3}[]
---@param pos Vector3
---@param endPos Vector3
---@param block BlockState
---@param uvX number
---@param uvY number
---@return Vector4
function torchModel(aabbs, pos, endPos, block, uvX, uvY)
   local faceN = faceToN[block.properties.facing] or 4
   local posMat = posMats[faceN]
   local posMatInverse = posMatsInverse[faceN]
   pos = posMat:apply(pos)
   endPos = posMat:apply(endPos)
   local colors = {}
   local depths = {}
   for i, v in pairs(aabbs) do
      local aabb, hitpos, face = raycast:aabb(pos, endPos, v)
      depths[i] = 99
      colors[i] = emptyVec4
      local realHitPos = posMatInverse:apply(hitpos)
      if face and realHitPos.xz > vec(0, 0) and realHitPos.xz < vec(1, 1) and not aabb[face] then
         local uv = facePosToUv[face]:apply(hitpos)
         local offset = 0
         if face == 'up' then
            offset = offset - 1
         elseif face == 'down' then
            offset = offset + 7
         end
         local color = terrainPng:getPixel(uvX + uv.x * 16, uvY + uv.y * 16 + offset)
         if color.a > 0.5 then
            colors[i] = color
            depths[i] = (hitpos - pos):lengthSquared()
         end
      end
   end
   local smallestDepth = 99
   local smallestI = 1
   for i, v in pairs(depths) do
      if v < smallestDepth then
         smallestDepth = v
         smallestI = i
      end
   end
   return colors[smallestI]
end

end

do
   local torchAabbs = {
      { {vec(7 / 16, 0, 7 / 16), vec(9 / 16, 10 / 16, 9 / 16)} }
   }

   local redstoneTorchAabbs = {
      { {vec(7 / 16, 0, 7 / 16), vec(9 / 16, 10 / 16, 9 / 16)} },
      { {vec(6 / 16, 8 / 16, 7 / 16), vec(10 / 16, 11 / 16, 9 / 16), up = true, down = true, west = true, east = true} },
      { {vec(7 / 16, 8 / 16, 6 / 16), vec(9 / 16, 11 / 16, 10 / 16), up = true, down = true, north = true, south = true} },
   }

   blockModels['minecraft:torch'] = function(pos, endPos, block)
      return torchModel(torchAabbs, pos, endPos, block, 0, 80), 'up'
   end
   blockModels['minecraft:wall_torch'] = blockModels['minecraft:torch']

   blockModels['minecraft:redstone_torch'] = function(pos, endPos, block)
      if block.properties.lit then
         return torchModel(redstoneTorchAabbs, pos, endPos, block, 48, 96), 'up'
      end
      return torchModel(torchAabbs, pos, endPos, block, 48, 112), 'up'
   end
   blockModels['minecraft:redstone_wall_torch'] = blockModels['minecraft:redstone_torch']
end

local fenceModel
do
local middleAabb = {vec(6 / 16, 0, 6 / 16), vec(10 / 16, 1, 10 / 16)}
local northAabbs = {
   {vec(7 / 16, 6 / 16, 0 / 16), vec(9 / 16, 9 / 16, 6 / 16)},
   {vec(7 / 16, 12 / 16, 0 / 16), vec(9 / 16, 15 / 16, 6 / 16)}
}
local rotAabbs = {
   north = northAabbs,
   east = rotateAabbs(northAabbs, vec(0, -90, 0)),
   south = rotateAabbs(northAabbs, vec(0, 180, 0)),
   west = rotateAabbs(northAabbs, vec(0, 90, 0)),
}
---@param pos Vector3
---@param endPos Vector3
---@param block BlockState
---@param uvX number
---@param uvY number
---@return Vector4, Entity.blockSide
function fenceModel(pos, endPos, block, uvX, uvY)
   local aabbs = {middleAabb}
   for side, myAabbs in pairs(rotAabbs) do
      if block.properties[side] == 'true' then
         for _, v in pairs(myAabbs) do
            table.insert(aabbs, v)
         end
      end
   end
   local _, hitpos, face = raycast:aabb(pos, endPos, aabbs)
   if face then
      local uv = facePosToUv[face]:apply(hitpos)
      return terrainPng:getPixel(uvX + uv.x * 16, uvY + uv.y * 16), face
   end
   return vec(0, 0, 0, 0), 'up'
end
end

blockModels['minecraft:oak_fence'] = function(pos, endPos, block)
   return fenceModel(pos, endPos, block, 64, 0)
end

blockModels['minecraft:nether_brick_fence'] = function(pos, endPos, block)
   return fenceModel(pos, endPos, block, 0, 224)
end

do
local aabbs = {
   {vec(0, 5 / 16, 7 / 16), vec(2 / 16, 1, 9 / 16)},
   {vec(14 / 16, 5 / 16, 7 / 16), vec(1, 1, 9 / 16)},
   {vec(2 / 16, 6 / 16, 7 / 16), vec(14 / 16, 9 / 16, 9 / 16)},
   {vec(2 / 16, 12 / 16, 7 / 16), vec(14 / 16, 15 / 16, 9 / 16)},
   {vec(6 / 16, 9 / 16, 7 / 16), vec(10 / 16, 12 / 16, 9 / 16)},
}
local aabbs2 = rotateAabbs(aabbs, vec(0, 90, 0))

blockModels['minecraft:oak_fence_gate'] = function(pos, endPos, block)
   local _, hitpos, face = raycast:aabb(
      pos,
      endPos,
      (block.properties.facing == 'east' or block.properties.facing == 'west') and aabbs2 or aabbs
   )
   if face then
      local uv = facePosToUv[face]:apply(hitpos)
      return terrainPng:getPixel(64 + uv.x * 16, uv.y * 16), face
   end
   return vec(0, 0, 0, 0)
end

end

return blockModels