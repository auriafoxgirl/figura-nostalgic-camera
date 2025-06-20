local res = vec(480, 360) * 0.5
local cameraSpeed = 5
local raycastBlocksDist = 100
local maxRaysPerPixel = 12

local mod = {}
local cameraQueue = {}
local textureId = 0

local faceBlockToTerrainUvMap, faceBlockToUvFuncs, blockPropertiesList = require('blockmap')
local blockModels = require('block_models')
local terrainPng = textures['terrain'] or textures['model.terrain']

local faceToNormal = {
   up = vec(0, 1, 0),
   down = vec(0, -1, 0),
   north = vec(0, 0, -1),
   south = vec(0, 0, 1),
   east = vec(1, 0, 0),
   west = vec(-1, 0, 0),
}

local faceShading = {
   up = 1,
   down = 0.47,
   north = 0.79,
   south = 0.79,
   east = 0.59,
   west = 0.59,
}

local facePosToUv = {
   up = matrices.mat4(vec(1, 0, 0, 0), vec(0, 0, 0, 0), vec(0, 1, 0, 0), vec(0, 0, 0, 0)),
   down = matrices.mat4(vec(1, 0, 0, 0), vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 1, 0, 0)),
   north = matrices.mat4(vec(-1, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 0, 0, 0), vec(1, 1, 0, 0)),
   south = matrices.mat4(vec(1, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 0, 0, 0), vec(0, 1, 0, 0)),
   east = matrices.mat4(vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(-1, 0, 0, 0), vec(1, 1, 0, 0)),
   west = matrices.mat4(vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(1, 0, 0, 0), vec(0, 1, 0, 0)),
}

local skipBlockAabbs = {
   {vec(1, -1, -1), vec(2, 2, 2)},
   {vec(-1, 1, -1), vec(2, 2, 2)},
   {vec(-1, -1, 1), vec(2, 2, 2)},
   {vec(-1, -1, -1), vec(0, 2, 2)},
   {vec(-1, -1, -1), vec(2, 0, 2)},
   {vec(-1, -1, -1), vec(2, 2, 0)},
}

---@param pos Vector3
---@param dir Vector3
---@return Vector3
local function skipBlock(pos, dir)
   local _, hitpos = raycast:aabb(pos, pos + dir * 4, skipBlockAabbs)
   return hitpos or pos
end

local texture = textures:newTexture('temp', 1, 1)
local defaultFluidMode = 'ANY'

local previewSprite = models:newPart('', 'HUD'):newSprite('')
function events.tick()
   local size = vec(res.x / res.y, 1, 0)
   size = size * client.getScaledWindowSize().y * 0.4
   previewSprite:setTexture(texture, 1, 1)
   previewSprite:setScale(size)
end

local function raycastPixel(camPos, dir, x, y)
   local pos = camPos
   local color = vec(0, 0, 0, 0)
   local blocksDist = raycastBlocksDist
   local cullId = pos
   local fluidMode = defaultFluidMode
   local oldLight = 1
   for _ = 1, maxRaysPerPixel do
      local block, hitpos, face = raycast:block(pos, pos + dir * blocksDist, "OUTLINE", fluidMode)
      local blockProperties = blockPropertiesList[block.id]
      local newCullId = blockProperties.cull or hitpos

      local distTraveled = (hitpos - pos):length()

      blocksDist = blocksDist - distTraveled

      local newColor
      if blockModels[block.id] then
         local newFace
         local p = hitpos - block:getPos()
         newColor, newFace = blockModels[block.id](p - dir * 4, p + dir * 64, block)
         if newFace then
            face = newFace
         end
      else
         local uv = facePosToUv[face]:apply(hitpos % 1).xy
         local uvOffset = faceBlockToTerrainUvMap[face][block.id]
         local uvFunc = faceBlockToUvFuncs[face][block.id]
         if uvFunc then
            local uvMat
            uvOffset, uvMat = uvFunc(block, face)
            if uvMat then
               uv = uvMat:apply(uv)
            end
         end
         newColor = terrainPng:getPixel(uvOffset.x + uv.x * 16, uvOffset.y + uv.y * 16)
      end

      local newLight = (world.getLightLevel(hitpos + faceToNormal[face] * 0.4) / 15)
      if newLight > 0 or distTraveled > 0.1 then -- bad fix because raycast stupid
         oldLight = newLight
      end
      newColor.rgb = newColor.rgb * oldLight * faceShading[face]

      local colorApplied = false
      if cullId ~= newCullId and newColor.a ~= 0 then
         colorApplied = true
         local alpha = color.a + newColor.a * (1 - color.a)
         color = (
            (color.rgb * color.a + newColor.rgb * newColor.a * (1 - color.a)) / alpha
         ):augmented(alpha)
      end
      cullId = newCullId

      if (colorApplied and newColor.a > 0.95) or blocksDist < 0.01 then
         break
      end

      local newFluidMode = #block:getFluidTags() >= 1 and 'NONE' or 'ANY'

      pos = hitpos
      if fluidMode == newFluidMode then
         local blockPos = block:getPos()
         pos = skipBlock(pos - blockPos, dir) + blockPos + dir * 0.05
         blocksDist = blocksDist - (pos - hitpos):length()
      else
         fluidMode = newFluidMode
      end
   end
   texture:setPixel(x, y, color)
end

function events.tick()
   local pos = player:getPos():add(0, player:getEyeHeight())
   local dir = player:getLookDir()
   raycastPixel(pos, dir, 0, 0)
end

local function cameraUpdate()
   if #cameraQueue == 0 then
      events.WORLD_RENDER:remove(cameraUpdate)
      return
   end
   local camera = cameraQueue[1]
   local pos = camera.pos
   local dirMat = camera.dirMat
   texture = camera.texture

   local maxHeight = res.y - 1
   local yScale = 2 / -maxHeight
   defaultFluidMode = #world.getBlockState(pos):getFluidTags() >= 1 and 'NONE' or 'ANY'

   for i = 0, math.min(cameraSpeed, res.x - camera.x) - 1 do
      local x = camera.x + i
      local xScaled = (1 - x / (res.x - 1) * 2) * res.x / res.y
      for y = 0, maxHeight do
         local dir = (vec(xScaled, y * yScale + 1, 1) * dirMat):normalize()
         raycastPixel(pos, dir, x, y)
      end
   end
   camera.x = camera.x + cameraSpeed

   texture:update()
   if camera.x >= res.x then
      table.remove(cameraQueue, 1)
      -- print('size', #texture:save() / 1000, 'bytes')
   end
end

function mod.takePhoto()
   local camRot = client.getCameraRot()
   local texture = textures:newTexture('preview'..textureId, res.x, res.y)
   textureId = (textureId + 1) % 100
   local dirMat = matrices.mat3()
   local fov = math.tan(math.rad(client.getFOV() / 2))
   dirMat:scale(fov, fov, 1)
   dirMat:rotate(camRot.x, -camRot.y, 0)
   if #cameraQueue == 0 then
      events.WORLD_RENDER:register(cameraUpdate)
   end
   table.insert(cameraQueue, {
      pos = client.getCameraPos(),
      dirMat = dirMat,
      x = 0,
      fov = fov,
      texture = texture
   })
end

return mod