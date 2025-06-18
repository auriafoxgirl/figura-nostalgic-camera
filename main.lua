local camera = require('camera')

camera.takePhoto()

-- for i = 0, 100, 10 do
--    local func = i == 0 and function()
--    end or raycast.block
--    local p1 = client.getCameraPos()
--    local p2 = client.getCameraPos() + vec(0, i == 0 and 100 or i, 0)
--    local t = client.getSystemTime()
--    for _ = 1, 10000 do
--       func(raycast, p1, p2)
--    end
--    local time = client.getSystemTime() - t
--    print(i == 0 and 'empty func' or 'raycast '..i..' blocks', time, 'ms')
-- end