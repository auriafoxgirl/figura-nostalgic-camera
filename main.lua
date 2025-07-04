if not host:isHost() then return end

local imageFilePath = 'photos/photo_%s.png'

local imageFolderPath = imageFilePath:gsub('/[^/]*$', '/')
file:mkdirs(imageFolderPath)

-- info text
if #file:list(imageFolderPath) == 0 then
   printJson(toJson{
      'Open ',
      {text = 'action wheel ', color = 'aqua'},
      'to take photos!'
   })
end

local filePhotoI = 0

local camera=require('camera')
local whitePixel = textures.whitePixel or textures:newTexture('whitePixel', 1, 1):setPixel(0, 0, 1, 1, 1)

-- action wheel
---@param page Page
---@param title string
---@param options (string|number)[]
---@param setFunc fun(i: number, v: string, dir: number)
---@param default number?
---@param configName string?
---@param description string?
---@return Action
local function actionWheelSlider(page, title, options, setFunc, default, configName, description)
   default = default or 1
   description = description and description..'\n' or ''
   local action = page:newAction()
   local option = default
   local optionOffset = 0
   if configName then
      local value = config:load(configName)
      if type(value) == 'number' then
         option = math.clamp(value, 1, #options)
      end
   end
   local function updateTitle()
      local text = {
         { text = title }, '\n',
         { text = description, color = 'gray' }
      }
      for i, v in ipairs(options) do
         table.insert(text, '\n')
         v = tostring(v)
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
      setFunc(option, options[option], dir)
      updateTitle()
   end

   action:onScroll(scroll)
   action:onLeftClick(function()
      scroll(-1)
   end)
   action:onRightClick(function()
      scroll(option - default)
   end)

   updateTitle()
   setFunc(option, options[option], 0)

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

local currentResolution = 144
local currentAspectRatio = 16 / 9
local currentRes = vec(144, 144)

local function updateCameraResolution()
   local res = vec(1, 1)
   if currentAspectRatio >= 1 then
      local width = math.ceil(currentResolution * currentAspectRatio)
      res = vec(width, currentResolution)
   else
      local height = math.ceil(currentResolution / currentAspectRatio)
      res = vec(currentResolution, height)
   end
   currentRes = res
   camera.setResolution(res)
end


actionWheelSlider(mainPage, 'Resolution', {
   '144p',
   '360p',
   '480p',
   '720p',
   '900p',
   '1080p',
   '2160p'
}, function(_, v)
   currentResolution = tonumber(v:match('%d+'))
   updateCameraResolution()
end, 2, 'resolution')
   :setItem(makeItemEmoji('mcb_end_crystal'))

actionWheelSlider(mainPage, 'Aspect Ratio', {
   '1:1',
   '4:3',
   '16:9',
   '21:9',
   '3:4',
   '9:16',
   '9:21',
}, function(_, v)
   local x, y = v:match('(%d+):(%d+)')
   x = tonumber(x)
   y = tonumber(y)
   currentAspectRatio = x / y
   updateCameraResolution()
end, 2, 'aspect_ratio')
   :setItem(makeItemEmoji('mcb_glass'))

actionWheelSlider(mainPage, 'Render distance', {
   '32§l  §rblocks',
   '64§l  §rblocks',
   '128 blocks',
   '256 blocks',
   '512 blocks',
}, function(i, v)
   local dist = tonumber(v:match('%d+'))
   if dist < 60 then -- add some extra blocks so its actually visible because fog removes some
      dist = dist + 16
   end
   camera.setRenderDistance(dist)
end, 3, 'render_distance')
   :setItem(makeItemEmoji('mag_right'))

do
   local renderSpeedAction

   local clockRot = -1
   local oldClockRot = -1
   local clockSpeed = 0
   local hovered = false
   local hoverTime = 0
   local actionWheelTime = 0
   function events.tick()
      actionWheelTime = action_wheel:isEnabled() and math.min(actionWheelTime + 1, 10) or 0
      local hovering = actionWheelTime >= 2 and action_wheel:getSelectedAction() == renderSpeedAction
      if hovering and not hovered and hoverTime == 0 then
         clockSpeed = clockSpeed + 1 + math.random() * 4
      end
      if hovering then
         hoverTime = 2
      else
         hoverTime = math.max(hoverTime - 1, 0)
      end
      hovered = hovering
      clockSpeed = clockSpeed * 0.9
      oldClockRot = clockRot
      clockRot = clockRot + clockSpeed
      local offset = math.floor(clockRot / 12) * 12
      clockRot = clockRot - offset
      oldClockRot = oldClockRot - offset
   end

   renderSpeedAction = actionWheelSlider(mainPage, 'Render speed', {
      1,
      2,
      4,
      8,
      16,
      32,
   }, function(i, v, dir)
      camera.setRenderSpeed(v)
      clockSpeed = clockSpeed - dir * 0.5
   end, 3, 'render_speed', 'Vertical lines per frame\nuse slower on higher resolutions\nto avoid lag')
      :setItem(makeItemEmoji('question'))

   function events.world_render(delta)
      if action_wheel:isEnabled() then
         local rot = math.floor(math.lerp(oldClockRot, clockRot, delta)) % 12 + 1
         renderSpeedAction:setItem(makeItemEmoji('clock'..rot))
      end
   end
end

local photoSaved = true
local lastPhotoFilePath = ''
local textureToSave = nil

local savePhotoAction = mainPage:newAction()

---@param autoSave boolean?
local function savePhoto(autoSave)
   if photoSaved then
      return
   end
   if autoSave and currentResolution >= 1500 then
      printJson(toJson{
         '',
         {text = '! ', color = 'red'},
         'Current photo might be too big to save and it might crash your avatar or game. ',
         'Use ',
         {text = '/figura export texture '..textureToSave:getName(), color = 'aqua'},
         ' to save photo to your ',
         {text = 'figura/', color = 'aqua'},
         ' folder.'
      })
      return
   end
   photoSaved = true

   savePhotoAction:hoverColor(0.5, 0.5, 0.5)
   savePhotoAction:hoverItem(makeItemEmoji('checkmark'))
   savePhotoAction:title(toJson{
      'Save photo',
      {color = 'gray', text = '\nPhoto saved to:\n'},
      {color = 'aqua', text = 'figura/data/'..lastPhotoFilePath}
   })

   local saved = textureToSave:save()
   local buffer = data:createBuffer(#saved)
   local stream = file:openWriteStream(lastPhotoFilePath)
   buffer:writeBase64(saved)
   buffer:setPosition(0)
   buffer:writeToStream(stream)
   stream:close()
   buffer:close()
end

local savePhotoActionItem = makeItemEmoji('photo')
savePhotoAction:title('Save photo')
   :item(savePhotoActionItem)
   :hoverColor(0.5, 0.5, 0.5)
   :onLeftClick(function() savePhoto() end)

local autoSavePhotos = config:load('auto_save_photos')
if autoSavePhotos == nil then
   autoSavePhotos = true
end
local autoSavePhotosAction = mainPage:newAction()
autoSavePhotosAction:setToggleColor(0, 0.75, 0)
   :title('Auto save photos')
   :item(makeItemEmoji('paper'))

local function setAutoSave(x)
   if autoSavePhotos ~= x then
      config:save('auto_save_photos', x)
   end
   autoSavePhotos = x
   if x then
      autoSavePhotosAction:hoverColor(0.5, 1, 0.5)
   else
      autoSavePhotosAction:hoverColor(1, 1, 1)
   end
end

setAutoSave(autoSavePhotos)
autoSavePhotosAction:setToggled(autoSavePhotos)
autoSavePhotosAction:onToggle(setAutoSave)
autoSavePhotosAction:onRightClick(function()
   setAutoSave(true)
   autoSavePhotosAction:setToggled(true)
end)

mainPage:newAction()
   :title(toJson{
      'You can find photos in:\n',
      {text = 'figura/data/'..imageFolderPath, color = 'aqua'},
      '\nWhere ',
      {text = 'figura', color = 'aqua'},
      ' is',
      '\nyour figura folder'
   })
   :setItem(makeItemEmoji('folder'))
   :setHoverItem(makeItemEmoji('folder_paper'))
   :setHoverColor(0.5, 0.5, 0.5)

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
local previewTextTask = previewHud:newText('text')
local previewText = ''
previewTextTask:setWrap(true)

local previewTexture

local previewAnim = 0
local oldPreviewAnim = 0
local previewVisible = 0
local previewForceVisible = false

function events.tick()
   oldPreviewAnim = previewAnim
   previewVisible = math.max(previewVisible - 1, 0)
   if previewForceVisible or (previewTexture and action_wheel:isEnabled()) then
      previewVisible = math.max(previewVisible, 1)
   end
   if previewVisible >= 1 then
      previewAnim = math.lerp(previewAnim, 1, 0.35)
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

   local opacity = math.clamp(1 - (1 - anim) * 1.2, 0, 1)
   opacity = 3 * opacity ^ 2 - 2 * opacity ^ 3
   opacity = math.clamp(opacity, 0.01, 1)

   previewTextTask:setWidth(size.x)
   local textHeight = client.getTextDimensions(previewText, size.x, true).y
   previewSprite:setScale(size):setColor(1, 1, 1, opacity)
   bgSprite:setScale(size + vec(2, textHeight + 3, 0)):setColor(1, 1, 1, opacity)
   previewTextTask:setOpacity(opacity)

   previewHud:setPos((1 - anim) * (size.x + 16), 0, 0)
   previewTextTask:setPos(-5, -size.y - 7, -1)
end

local function takePhoto()
   local maxRes = avatar:getMaxTextureSize()
   if currentRes.x > maxRes or currentRes.y > maxRes then
      printJson(toJson{
         {text = '', color = 'white'},
         {text = '! ', color = 'red'},
         'Current resolution ',
         {text = currentRes.x..'x'..currentRes.y, color = 'aqua'},
         ' is bigger than allowed by figura ',
         {text = maxRes..'x'..maxRes, color = 'aqua'},
         '. Pick lower resolution or go to ',
         {text = 'figura permissions tab', color = 'aqua'},
        ' and change ',
        {text = 'Max Texture Size', color = 'aqua'},
        ' with ',
        {text = 'Precise Mode enabled ', color = 'aqua'},
        'to something bigger.'
      })
      return
   end
   takePhotoAction:setHoverColor(0.5, 0.5, 0.5)
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

      previewText = 'figura/data/'..myFilePath
      previewTextTask:setText(toJson{
         text = previewText,
         color = '#000000'
      })
   end, function(texture)
      previewForceVisible = false
      previewVisible = 100

      textureToSave = texture
      lastPhotoFilePath = myFilePath
      photoSaved = false
      savePhotoAction:hoverColor()
      savePhotoAction:setHoverItem(savePhotoActionItem)

      takePhotoAction:setHoverColor()

      savePhotoAction:title('Save photo')

      if autoSavePhotos then
         savePhoto(true)
      end
   end)
end

-- icons
local iconModel = models:newPart('', 'Skull')
iconModel:setRot(30, -45, 0)
local iconText = iconModel:newText('')
iconText:setPos(7, 9.2, 0):setScale(1.8):setLight(15, 15)

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
         takePhoto()
      end
   end)