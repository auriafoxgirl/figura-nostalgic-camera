if not host:isHost() then return end

local imageFilePath = 'photos/photo_%s.png'

file:mkdirs(imageFilePath:gsub('/[^/]*$', ''))
local filePhotoI = 0

local camera=require('camera')
local whitePixel = textures.whitePixel or textures:newTexture('whitePixel', 1, 1):setPixel(0, 0, 1, 1, 1)

-- action wheel
---@param page Page
---@param title string
---@param options string[]
---@param setFunc fun(i: number, v: string)
---@param configName string?
---@return Action
local function actionWheelSlider(page, title, options, setFunc, configName)
   local action = page:newAction()
   local option = 1
   local optionOffset = 0
   if configName then
      local value = config:load(configName)
      if type(value) == 'number' then
         option = math.clamp(value, 1, #options)
      end
   end
   local function updateTitle()
      local text = {
         { text = title }, '\n'
      }
      for i, v in ipairs(options) do
         table.insert(text, '\n')
         if i == option then
            table.insert(text, {text = v, color = 'white'})
         else
            table.insert(text, {text = v, color = 'gray'})
         end
      end
      action:setTitle(toJson(text))
   end
   ---@param dir number
   local function scroll(dir)
      local oldOption = option

      option = option + optionOffset - dir

      optionOffset = option % 1
      option = math.floor(option)
      option = (option - 1) % #options + 1

      if oldOption == option then
         return
      end
      if configName then
         config:save(configName, option)
      end
      setFunc(option, options[option])
      updateTitle()
   end

   action:onScroll(scroll)
   action:onLeftClick(function()
      scroll(-1)
   end)

   updateTitle()
   setFunc(option, options[option])

   return action
end

---@param emoji string
---@return string
local function makeItemEmoji(emoji)
   return 'player_head{SkullOwner:'..avatar:getEntityName()..',display:{Name:\'"icon;'..emoji..'"\'}}'
end

local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

local takePhotoAction = mainPage:newAction()

local resolutionsList = {
   '240x180     4:3',
   '480x360     4:3',
   '80x45        16:9',
   '160x90    §l  §r16:9',
   '640x360     16:9',
   '1920x1080  16:9',
   '3840x2160  16:9',
}
local maxTextureSize = avatar:getMaxTextureSize()
for i = #resolutionsList, 1, -1 do
   local x, y = resolutionsList[i]:match('^(%d+)x(%d+)')
   x, y = tonumber(x), tonumber(y)
   if x > maxTextureSize or y > maxTextureSize then
      table.remove(resolutionsList, i)
   end
end

actionWheelSlider(mainPage, 'Resolution', resolutionsList, function(_, v)
   local x, y = v:match('^(%d+)x(%d+)')
   x, y = tonumber(x), tonumber(y)
   camera.setResolution(vec(x, y))
end, 'resolution')
   :setItem(makeItemEmoji('mcb_end_crystal'))

-- take photo
local previewHud = models:newPart('preview', 'Hud')
previewHud:setVisible(false)
local previewSprite = previewHud:newSprite('preview')
   :setLight(15, 15)
   :setPos(-5, -5, 0)
local bgSprite = previewHud:newSprite('bg')
   :setLight(15, 15)
   :setTexture(whitePixel, 1, 1)
   :setPos(-4, -4, 1)
local previewText = previewHud:newText('text')

local previewTexture

local previewAnim = 0
local oldPreviewAnim = 0
local previewVisible = 0
local previewForceVisible = false

function events.tick()
   oldPreviewAnim = previewAnim
   previewVisible = math.max(previewVisible - 1, 0)
   if previewForceVisible then
      previewVisible = math.max(previewVisible, 1)
   end
   if previewVisible >= 1 then
      previewAnim = math.lerp(previewAnim, 1, 0.3)
   else
      previewAnim = previewAnim * 0.7
   end
   previewHud:setVisible(previewTexture and previewAnim + oldPreviewAnim > 0.01)
end

previewHud.preRender = function(delta)
   if not previewTexture then
      previewHud:setVisible(false)
      return
   end
   previewSprite:setTexture(previewTexture, 1, 1)

   local anim = math.lerp(oldPreviewAnim, previewAnim, delta)
   local res = previewTexture:getDimensions()

   local size = vec(res.x / res.y, 1, 0)
   size = size * client.getScaledWindowSize().y * 0.4

   previewSprite:setScale(size):setColor(1, 1, 1, anim)
   bgSprite:setScale(size + vec(2, 13, 0)):setColor(1, 1, 1, anim)
   previewText:setOpacity(anim)

   previewHud:setPos((1 - anim) * (size.x + 16), 0, 0)
   previewText:setPos(-5, -size.y - 7, -1)
end

local function takePhoto()
   filePhotoI = filePhotoI + 1
   if file:exists(imageFilePath:format(filePhotoI)) then
      -- binary search index for file name
      local min, max = filePhotoI, filePhotoI + 2147483648
      for _ = 1, 32 do
         local middle = math.floor((min + max) * 0.5)
         if file:exists(imageFilePath:format(middle)) then
            min = middle + 1
         else
            max = middle
         end
      end
      filePhotoI = max
   end
   local myFilePath = imageFilePath:format(filePhotoI)
   camera.takePhoto(function(texture)
      previewTexture = texture
      previewForceVisible = true

      previewText:setText(toJson{
         text = 'figura/data/'..myFilePath,
         color = '#000000'
      })
   end, function(texture)
      previewForceVisible = false
      previewVisible = 100

      takePhotoAction:setHoverColor(1, 1, 1)

      local saved = texture:save()
      local buffer = data:createBuffer(#saved)
      local stream = file:openWriteStream(myFilePath)
      buffer:writeBase64(saved)
      buffer:setPosition(0)
      buffer:writeToStream(stream)
      stream:close()
      buffer:close()
   end)
end

-- icons
local iconModel = models:newPart('', 'Skull')
iconModel:setRot(30, -45, 0)
local iconText = iconModel:newText('')
iconText:setPos(7, 9.2, 0):setScale(1.8)

events.SKULL_RENDER:register(function(_, _, item)
   iconModel:visible(false)
   if not item then return end
   local name = item:getName()
   if not name then return end
   local iconName = name:match('^icon;(.*)$')
   if not iconName then return end
   iconModel:visible(true)
   iconText:setText(':'..iconName..':')
end)

-- action wheel
takePhotoAction:title('Take photo')
   :item(makeItemEmoji('camera'))
   :onLeftClick(function()
      if camera.getQueueSize() == 0 then
         takePhotoAction:setHoverColor(0.5, 0.5, 0.5)
         takePhoto()
      end
   end)