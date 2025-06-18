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
   lapis_block = vec(0, 144),
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
   gold_ore = vec(0, 32),
   iron_ore = vec(16, 32),
   coal_ore = vec(32, 32),
   diamond_ore = vec(32, 48),
   redstone_ore = vec(48, 48),
   lapis_ore = vec(0, 160),
   mossy_cobblestone = vec(64, 32),
   bookshelf = vec(48, 32),
   sponge = vec(0, 48),
   sandstone_top = vec(0, 176),
   sandstone_side = vec(0, 192),
   sandstone_down = vec(0, 208),
   crafting_table_top = vec(176, 32),
   crafting_table_side1 = vec(176, 48),
   crafting_table_side2 = vec(192, 48),
   nether_portal = vec(64, 192),
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
   ['minecraft:lapis_block'] = {all = 'lapis_block'},
   ['minecraft:smooth_stone_slab'] = {up = 'stone_slab_top', down = 'stone_slab_top', side = 'stone_slab'},
   ['minecraft:oak_leaves'] = {all = 'oak_leaves'},
   ['minecraft:bricks'] = {all = 'bricks'},
   ['minecraft:tnt'] = {up = 'tnt_top', side = 'tnt_side', down = 'tnt_down'},
   ['minecraft:glass'] = {all = 'glass'},
   ['minecraft:ice'] = {all = 'ice'},
   ['minecraft:water'] = {all = 'water'},
   ['minecraft:lava'] = {all = 'lava'},
   ['minecraft:obsidian'] = {all = 'obsidian'},
   ['minecraft:gold_ore'] = {all = 'gold_ore'},
   ['minecraft:iron_ore'] = {all = 'iron_ore'},
   ['minecraft:coal_ore'] = {all = 'coal_ore'},
   ['minecraft:diamond_ore'] = {all = 'diamond_ore'},
   ['minecraft:redstone_ore'] = {all = 'redstone_ore'},
   ['minecraft:lapis_ore'] = {all = 'lapis_ore'},
   ['minecraft:mossy_cobblestone'] = {all = 'mossy_cobblestone'},
   ['minecraft:bookshelf'] = {side = 'bookshelf', up = 'oak_planks', down = 'oak_planks'},
   ['minecraft:sponge'] = {all = 'sponge'},
   ['minecraft:sandstone'] = {side = 'sandstone_side', up = 'sandstone_top', down = 'sandstone_down'},
   ['minecraft:crafting_table'] = {up = 'crafting_table_top', down = 'oak_planks', east = 'crafting_table_side1', south = 'crafting_table_side1', west = 'crafting_table_side2', north = 'crafting_table_side2'},
   ['minecraft:nether_portal'] = {all = 'nether_portal'},
}

local blockAliasMap = {
   ['minecraft:snow'] = 'minecraft:snow_block',

   ['minecraft:andesite'] = 'minecraft:stone',

   ['minecraft:wet_sponge'] = 'minecraft:sponge',
}

local blockProperties = {
   ['minecraft:glass'] = {cull = 1},
   ['minecraft:ice'] = {cull = 2},
   ['minecraft:water'] = {cull = 3},
   ['minecraft:nether_portal'] = {cull = 4},
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