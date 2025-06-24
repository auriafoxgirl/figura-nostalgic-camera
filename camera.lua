local res=vec(480, 360) * 0.5
local cameraSpeed=5
local raycastBlocksDist=128
local maxRaysPerPixel=12
local starCount = 500

local mod={}
local terrainOpacityUpdate=require('terrain_opacity')
local cameraQueue={}
local textureId=0
local starGridSize = 256

local faceBlockToTerrainUvMap, faceBlockToUvFuncs, blockPropertiesList=require('blockmap')
local blockModels=require('block_models')
local terrainPng=textures['terrain'] or textures['textures.terrain']
local cloudsPng=textures['clouds'] or textures['textures.clouds']
local sunPng=textures['sun'] or textures['textures.sun']
local moonPng=textures['moon_phases'] or textures['textures.moon_phases']

local mathMin = math.min

local faceToNormal={
   up=vec(0, 1, 0),
   down=vec(0, -1, 0),
   north=vec(0, 0, -1),
   south=vec(0, 0, 1),
   east=vec(1, 0, 0),
   west=vec(-1, 0, 0),
}

local faceShading={
   up=1,
   down=0.47,
   north=0.79,
   south=0.79,
   east=0.59,
   west=0.59,
}

local facePosToUv={
   up=matrices.mat4(vec(1, 0, 0, 0), vec(0, 0, 0, 0), vec(0, 1, 0, 0), vec(0, 0, 0, 0)),
   down=matrices.mat4(vec(1, 0, 0, 0), vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 1, 0, 0)),
   north=matrices.mat4(vec(-1, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 0, 0, 0), vec(1, 1, 0, 0)),
   south=matrices.mat4(vec(1, 0, 0, 0), vec(0, -1, 0, 0), vec(0, 0, 0, 0), vec(0, 1, 0, 0)),
   east=matrices.mat4(vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(-1, 0, 0, 0), vec(1, 1, 0, 0)),
   west=matrices.mat4(vec(0, 0, 0, 0), vec(0, -1, 0, 0), vec(1, 0, 0, 0), vec(0, 1, 0, 0)),
}

local stars = {}
math.randomseed(0)
for _ = 1, starCount do
   local dir = vectors.angleToDir(math.random() * 180 - 90, math.random() * 380)
   local id = tostring((dir * starGridSize):floor())
   stars[id] = true
end

local skipBlockAabbs={
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
   local _, hitpos=raycast:aabb(pos, pos + dir * 4, skipBlockAabbs)
   return hitpos or pos
end

local texture=textures:newTexture('temp', 1, 1)
local defaultFluidMode='ANY'
local sunMat = matrices.mat3()
local moonUv = vec(0, 0)
local fogColor = vec(0, 0, 0)
local skyColor = vec(0, 0, 0)
local skyColorTop = vec(0, 0, 0)
local cloudColor = vec(0, 0, 0)
local skySideMat = matrices.mat3()
local starStrength = 1

local previewSprite=models:newPart('', 'HUD'):newSprite('')
previewSprite:setLight(15, 15)
function events.tick()
   local size=vec(res.x / res.y, 1, 0)
   size=size * client.getScaledWindowSize().y * 0.4
   -- previewSprite:setTexture(textures['terrain'], 1, 1)
   previewSprite:setTexture(texture, 1, 1)
   previewSprite:setScale(size)
end

local function raycastPixel(camPos, dir, x, y)
   local pos=camPos
   local color=vec(0, 0, 0, 0)
   local blocksDist=raycastBlocksDist
   local cullId=pos
   local fluidMode=defaultFluidMode
   local oldLight=1
   local depth = -99999
   for _=1, maxRaysPerPixel do
      local block, hitpos, face=raycast:block(pos, pos + dir * blocksDist, "OUTLINE", fluidMode)
      local blockProperties=blockPropertiesList[block.id]
      local newCullId=blockProperties.cull or hitpos

      local distTraveled=(hitpos - pos):length()

      blocksDist=blocksDist - distTraveled

      local newColor
      if blockModels[block.id] then
         local newFace
         local p=hitpos - block:getPos()
         newColor, newFace=blockModels[block.id](p - dir * 4, p + dir * 64, block)
         if newFace then
            face=newFace
         end
      else
         local uv=facePosToUv[face]:apply(hitpos % 1).xy
         local uvOffset=faceBlockToTerrainUvMap[face][block.id]
         local uvFunc=faceBlockToUvFuncs[face][block.id]
         local colorMul
         if uvFunc then
            local uvMat, newFace
            uvOffset, uvMat, newFace, colorMul=uvFunc(block, face)
            if uvMat then
               uv=uvMat:apply(uv)
            end
            face=newFace or face
         end
         newColor=terrainPng:getPixel(uvOffset.x + uv.x * 16, uvOffset.y + uv.y * 16)
         if colorMul then
            newColor.rgb=newColor.rgb * colorMul
         end
      end

      local newLight=(world.getLightLevel(hitpos + faceToNormal[face] * 0.4) / 15)
      if newLight > 0 or distTraveled > 0.1 then -- bad fix because raycast stupid
         oldLight=newLight
      end
      newColor.rgb=newColor.rgb * oldLight * faceShading[face]

      local colorApplied=false
      if cullId ~= newCullId and newColor.a ~= 0 then
         colorApplied=true
         if color.a == 0 then
            depth = blocksDist
         end
         local alpha=color.a + newColor.a * (1 - color.a)
         color=(
            (color.rgb * color.a + newColor.rgb * newColor.a * (1 - color.a)) / alpha
         ):augmented(alpha)
      end
      cullId=newCullId

      if (colorApplied and newColor.a > 0.95) or blocksDist < 0.01 then
         break
      end

      local newFluidMode=#block:getFluidTags() >= 1 and 'NONE' or 'ANY'

      pos=hitpos
      if fluidMode == newFluidMode then
         local blockPos=block:getPos()
         pos=skipBlock(pos - blockPos, dir) + blockPos + dir * 0.05
         blocksDist=blocksDist - (pos - hitpos):length()
      else
         fluidMode=newFluidMode
      end
   end
   depth = raycastBlocksDist - depth
   -- sky color
   local sky = math.lerp(
      skyColor,
      fogColor,
      math.clamp((dir * skySideMat).x * 2 + 0.5, 0, 1)
   )
   -- fog
   color.rgb = math.lerp(
      color.rgb,
      sky * 0.7 + fogColor * 0.3,
      math.clamp((depth - raycastBlocksDist + 32) / 32, 0, 1)
   )
   -- clouds
   if dir.y ~= 0 then
      local dirScale = ((121 - camPos.y) / dir.y)
      if dirScale > 0 and dirScale < depth then
         local cloudHitPos = camPos + dir * dirScale
         local uv = (cloudHitPos.xz / 8):floor() % 256
         -- local uv = (cloudHitPos.xz):floor() % 256
         local newColor = cloudsPng:getPixel(uv.x, uv.y)
         if newColor.a > 0.5 then
            depth = dirScale
            -- fog
            local fog = math.clamp((depth - raycastBlocksDist - 128) / 64, 0, 1)
            newColor.rgb = math.lerp(
               newColor.rgb,
               fogColor,
               fog
            )
            newColor.rgb = newColor.rgb * cloudColor
            color = math.lerp(color, newColor, 0.9 * (1 - fog))
         end
      end
   end
   -- sky
   if color.a ~= 1 then
      sky = math.lerp(
         sky,
         skyColorTop,
         math.clamp((dir.y - 0.12) * 5, 0, 1)
      )
      -- stars
      if starStrength ~= 0 then
         local id = tostring(((dir * sunMat):normalize() * starGridSize):floor())
         if stars[id] then
            sky = sky + starStrength
         end
      end
      -- sun and moon
      local sunDir = dir * sunMat
      local dirScale = 3 / sunDir.x
      local uv = (sunDir * dirScale).zy
      if uv.x > -1 and uv.x < 1 and uv.y > -1 and uv.y < 1 then
         uv.y = -uv.y
         uv = (uv * 0.5 + 0.5) * 31.999
         if dirScale > 0 then
            sky = sky + sunPng:getPixel(uv.x, uv.y).rgb
         else
            sky = sky + moonPng:getPixel(uv.x + moonUv.x, uv.y + moonUv.y).rgb
         end
      end
      -- apply sky
      sky.r = mathMin(sky.r, 1)
      sky.g = mathMin(sky.g, 1)
      sky.b = mathMin(sky.b, 1)
      color.rgb = math.lerp(sky, color.rgb, color.a)
      color.a = 1
   end
   texture:setPixel(x, y, color)
end

local function cameraUpdate()
   if #cameraQueue == 0 then
      events.WORLD_RENDER:remove(cameraUpdate)
      return
   end
   local camera=cameraQueue[1]
   if camera.terrainPng then
      if terrainOpacityUpdate() then
         table.remove(cameraQueue, 1)
      end
      return
   end
   local pos=camera.pos
   local dirMat=camera.dirMat
   texture=camera.texture
   sunMat=camera.sunMat
   moonUv=camera.moonUv
   fogColor=camera.fogColor
   skyColor=camera.skyColor
   skyColorTop=camera.skyColorTop
   cloudColor=camera.cloudColor
   skySideMat=camera.skySideMat
   starStrength=camera.starStrength

   local maxHeight=res.y - 1
   local yScale=2 / -maxHeight
   defaultFluidMode=#world.getBlockState(pos):getFluidTags() >= 1 and 'NONE' or 'ANY'

   for i=0, mathMin(cameraSpeed, res.x - camera.x) - 1 do
      local x=camera.x + i
      local xScaled=(1 - x / (res.x - 1) * 2) * res.x / res.y
      for y=0, maxHeight do
         local dir=(vec(xScaled, y * yScale + 1, 1) * dirMat):normalize()
         raycastPixel(pos, dir, x, y)
      end
   end
   camera.x=camera.x + cameraSpeed

   texture:update()
   if camera.x >= res.x then
      table.remove(cameraQueue, 1)
      -- print('size', #texture:save() / 1000, 'bytes')
   end
end

events.WORLD_RENDER:register(cameraUpdate)

---@param tbl table
local function addToQueue(tbl)
   if #cameraQueue == 0 then
      events.WORLD_RENDER:register(cameraUpdate)
   end
   table.insert(cameraQueue, tbl)
end

addToQueue({terrainPng=true})

function mod.takePhoto()
   local camPos=client.getCameraPos()
   local camRot=client.getCameraRot()
   if math.abs(math.abs(camRot.x) - 90) < 0.1 then -- stupid fix for figura bug
      local p=vectors.worldToScreenSpace(camPos + vec(1, 0, 0) + client.getCameraDir())
      local rot=math.deg(math.atan2(p.x, p.y))
      rot=rot + 90
      if camRot.x < 0 then
         rot=-rot
      end
      camRot.y=rot
   end
   local texture=textures:newTexture('preview'..textureId, res.x, res.y)
   textureId=(textureId + 1) % 100
   local dirMat=matrices.mat3()
   local fov=math.tan(math.rad(client.getFOV() / 2))
   dirMat:scale(fov, fov, 1)
   dirMat:rotate(camRot.x, -camRot.y, 0)
   if #cameraQueue == 0 then
      events.WORLD_RENDER:register(cameraUpdate)
   end
   local dayTime = world.getTimeOfDay()
   local dayTime2 = ((dayTime % 24000) / 24000 - 0.25) % 1
   local sunAngle = (dayTime2 * 2 + (0.5 - math.cos(dayTime2 * math.pi) / 2)) / 3 * 360
   local sunMat = matrices.rotation3(0, 0, -90 - sunAngle)
   local sunDir = sunMat * vec(1, 0, 0)
   sunDir.y = -sunDir.y
   local moonPhase = math.floor(dayTime / 24000) % 8
   local moonUv = vec(
      (moonPhase % 4) * 32,
      moonPhase >= 4 and 32 or 0
   )
   local fogColor = math.lerp(
      vec(0.04, 0.04, 0.07),
      vec(0.69, 0.78, 0.99),
      math.clamp(sunDir.y * 2 + 0.5, 0, 1)
   )
   local skyColorTop = math.lerp(
      vec(0, 0, 0),
      vec(0.45, 0.74, 0.99),
      math.clamp(sunDir.y * 2 + 0.5, 0, 1)
   )
   local orangeStrength = math.clamp(sunDir.y * 5 + 0.5, 0.5, 1)
   local skyColor = math.lerp(
      vec(1, 0.7 * orangeStrength, 0.5 * orangeStrength),
      fogColor,
      math.clamp(math.abs(sunDir.y * 4 - 0.1), 0, 1)
   )
   local cloudColor = math.lerp(
      vec(0.05, 0.05, 0.1),
      vec(1, 1, 1),
      math.clamp((sunDir.y + 0.1) * 5, 0, 1)
   )
   local starStrength = math.clamp(sunDir.y * -3 + 0.1, 0, 0.4)
   local skySideMat = matrices.mat3()
   if sunDir.x > 0 then
      skySideMat:rotateZ(67.5)
      skySideMat:scale(-1, 1, 1)
   else
      skySideMat:rotateZ(-67.5)
   end

   addToQueue({
      pos=camPos,
      dirMat=dirMat,
      x=0,
      fov=fov,
      texture=texture,
      sunMat = sunMat,
      moonUv = moonUv,
      fogColor = fogColor,
      skyColor = skyColor,
      skyColorTop = skyColorTop,
      cloudColor = cloudColor,
      skySideMat = skySideMat,
      starStrength = starStrength
   })
end

return mod