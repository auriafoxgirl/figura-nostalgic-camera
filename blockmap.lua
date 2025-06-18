local terrainAtlas = {
   grass_top = vec(0, 0),
   grass_side = vec(48, 0),
   grass_snow_side = vec(64, 64),
   dirt = vec(32, 0),
   oak_planks = vec(64, 0),
   stone = vec(16, 0),
   snow = vec(32, 64),
   ice = vec(48, 64),
   cobblestone = vec(0, 16),
   bedrock = vec(16, 16),
   sand = vec(32, 16),
   gravel = vec(48, 16),
   oak_log_side = vec(64, 16),
   oak_log_top = vec(80, 16),
   iron_block = vec(96, 16),
   gold_block = vec(112, 16),
   diamond_block = vec(128, 16),
   stone_slab = vec(80, 0),
   stone_slab_top = vec(96, 0),
   oak_leaves = vec(64, 48),
   bricks = vec(112, 0),
   tnt_side = vec(128, 0),
   tnt_top = vec(144, 0),
   tnt_down = vec(160, 0),
   glass = vec(16, 48),
   water = vec(208, 192),
   lava = vec(208, 224),
   obsidian = vec(80, 32),
}

local blocks = {
   ['minecraft:grass_block'] = {
      up = 'grass_top',
      side = function(block)
         return block.properties.snowy == 'true' and terrainAtlas.grass_snow_side or terrainAtlas.grass_side
      end,
      down = 'dirt'
   },
   ['minecraft:stone'] = {all = 'stone'},
   ['minecraft:dirt'] = {all = 'dirt'},
   ['minecraft:snow_block'] = {all = 'snow'},
   ['minecraft:oak_planks'] = {all = 'oak_planks'},
   ['minecraft:cobblestone'] = {all = 'cobblestone'},
   ['minecraft:bedrock'] = {all = 'bedrock'},
   ['minecraft:sand'] = {all = 'sand'},
   ['minecraft:gravel'] = {all = 'gravel'},
   ['minecraft:oak_log'] = {up = 'oak_log_top', side = 'oak_log_side', down = 'oak_log_top'},
   ['minecraft:iron_block'] = {all = 'iron_block'},
   ['minecraft:gold_block'] = {all = 'gold_block'},
   ['minecraft:diamond_block'] = {all = 'diamond_block'},
   ['minecraft:smooth_stone_slab'] = {up = 'stone_slab_top', down = 'stone_slab_top', side = 'stone_slab'},
   ['minecraft:oak_leaves'] = {all = 'oak_leaves'},
   ['minecraft:bricks'] = {all = 'bricks'},
   ['minecraft:tnt'] = {up = 'tnt_top', side = 'tnt_side', down = 'tnt_down'},
   ['minecraft:glass'] = {all = 'glass'},
   ['minecraft:ice'] = {all = 'ice'},
   ['minecraft:water'] = {all = 'water'},
   ['minecraft:lava'] = {all = 'lava'},
   ['minecraft:obsidian'] = {all = 'obsidian'},
}

local blockAliasMap = {
   ['minecraft:snow'] = 'minecraft:snow_block',

   ['minecraft:andesite'] = 'minecraft:stone',
}

local blockProperties = {
   ['minecraft:glass'] = {cull = 1},
   ['minecraft:ice'] = {cull = 2},
}

---@type {[string]: {[string]: Vector2}}
local finalList = {
   up = {},
   down = {},
   north = {},
   south = {},
   east = {},
   west = {},
}

---@type {[string]: {[string]: fun(block: BlockState): Vector2}}
local blockFuncs = {
   up = {},
   down = {},
   north = {},
   south = {},
   east = {},
   west = {},
}

local blockPropertiesFinal = {}

-- fallback
for i, v in pairs(finalList) do
   setmetatable(v, {
      __index = function()
         return vec(208, 208)
      end
   })
end

setmetatable(blockPropertiesFinal, {
   __index = function()
      return {}
   end
})

---@param facesData table
---@param blockId string
---@param targetBlockId string
local function setBlock(facesData, blockId, targetBlockId)
   local faces = {
      up = facesData.up or facesData.all,
      down = facesData.down or facesData.all,
      north = facesData.north or facesData.side or facesData.all,
      south = facesData.south or facesData.side or facesData.all,
      east = facesData.east or facesData.side or facesData.all,
      west = facesData.west or facesData.side or facesData.all,
   }
   for face, v in pairs(faces) do
      if type(v) == 'function' then
         blockFuncs[face][targetBlockId] = v
      else
         finalList[face][targetBlockId] = terrainAtlas[v]
      end
   end
   blockPropertiesFinal[blockId] = blockProperties[blockId] or {}
end

for id, faces in pairs(blocks) do
   setBlock(faces, id, id)
end

for newId, id in pairs(blockAliasMap) do
   local faces = blocks[id]
   setBlock(faces, id, newId)
end

return finalList, blockFuncs, blockPropertiesFinal