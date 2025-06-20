local terrainAtlas = {
   air = vec(184, 214),
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
   spruce_log_side = vec(64, 112),
   birch_log_side = vec(80, 112),
   log_top = vec(80, 16),
   iron_block = vec(96, 16),
   gold_block = vec(112, 16),
   diamond_block = vec(128, 16),
   lapis_block = vec(0, 144),
   stone_slab = vec(80, 0),
   stone_slab_top = vec(96, 0),
   oak_leaves = vec(64, 48),
   spruce_leaves = vec(96, 192),
   birch_leaves = vec(64, 128),
   bricks = vec(112, 0),
   tnt_side = vec(128, 0),
   tnt_top = vec(144, 0),
   tnt_down = vec(160, 0),
   glass = vec(16, 48),
   glass_pane_top = vec(64, 144),
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
   mycelium_top = vec(224, 64),
   mycelium_side = vec(208, 64),
   cake_top = vec(144, 112),
   cake_side = vec(160, 112),
   cake_side_inside = vec(176, 112),
   cake_bottom = vec(192, 112),
   lily_pad = vec(192, 64),
   white_wool = vec(0, 64),
   black_wool = vec(16, 112),
   red_wool = vec(16, 128),
   green_wool = vec(16, 144),
   brown_wool = vec(16, 160),
   blue_wool = vec(16, 176),
   purple_wool = vec(16, 192),
   cyan_wool = vec(16, 208),
   light_gray_wool = vec(16, 224),
   gray_wool = vec(32, 112),
   pink_wool = vec(32, 128),
   lime_wool = vec(32, 144),
   yellow_wool = vec(32, 160),
   light_blue_wool = vec(32, 176),
   magenta_wool = vec(32, 192),
   orange_wool = vec(32, 208),
   cactus_top = vec(80, 64),
   cactus_side = vec(96, 64),
   cactus_down = vec(112, 64),
   farmland = vec(112, 80),
   farmland_wet = vec(96, 80),
   netherrack = vec(112, 96),
   soul_sand = vec(128, 96),
   glowstone = vec(144, 96),
   iron_bars_side = vec(80, 80),
   iron_bars_top = vec(48, 208),
   oak_trapdoor = vec(64, 80),
   stone_bricks = vec(96, 48),
   mossy_stone_bricks = vec(64, 96),
   cracked_stone_bricks = vec(80, 96),
   clay = vec(128, 64),
   enchanting_table_top = vec(96, 160),
   enchanting_table_side = vec(96, 176),
   enchanting_table_down = vec(112, 176),
   note_block = vec(160, 64),
   jukebox = vec(176, 64),
   furnace_front = vec(192, 32),
   furnace_front_lit = vec(208, 48),
   furnace_side = vec(208, 32),
   furnace_top = vec(224, 48),
   dispenser_front = vec(224, 32),
}

local uvRotMats = {
   [0] = matrices.mat3(),
   matrices.translate3(-0.5, -0.5):rotate(0, 0, 90):translate(0.5, 0.5),
   matrices.translate3(-0.5, -0.5):rotate(0, 0, 180):translate(0.5, 0.5),
   matrices.translate3(-0.5, -0.5):rotate(0, 0, -90):translate(0.5, 0.5),
}

local mathFloor = math.floor
---@param block BlockState
local function randomRotation(block)
   local p = block:getPos()
   return uvRotMats[mathFloor(p.x * 9613.51367 + p.y * 6871.16432 + p.z * 9907.6413) % 4]
end

local blocks = {
   ['minecraft:air'] = {all = 'air'},
   ['minecraft:grass_block'] = {
      up = 'grass_top',
      side = function(block)
         return block.properties.snowy == 'true' and terrainAtlas.grass_snow_side or terrainAtlas.grass_side
      end,
      down = 'dirt'
   },
   ['minecraft:mycelium'] = {up = 'mycelium_top', side = 'mycelium_side', down = 'dirt'},
   ['minecraft:stone'] = {all = 'stone'},
   ['minecraft:dirt'] = {all = 'dirt'},
   ['minecraft:snow_block'] = {all = 'snow'},
   ['minecraft:oak_planks'] = {all = 'oak_planks'},
   ['minecraft:cobblestone'] = {all = 'cobblestone'},
   ['minecraft:bedrock'] = {all = 'bedrock'},
   ['minecraft:sand'] = {all = 'sand'},
   ['minecraft:gravel'] = {all = 'gravel'},
   ['minecraft:oak_log'] = {up = 'log_top', side = 'oak_log_side', down = 'log_top'},
   ['minecraft:spruce_log'] = {up = 'log_top', side = 'spruce_log_side', down = 'log_top'},
   ['minecraft:birch_log'] = {up = 'log_top', side = 'birch_log_side', down = 'log_top'},
   ['minecraft:iron_block'] = {all = 'iron_block'},
   ['minecraft:gold_block'] = {all = 'gold_block'},
   ['minecraft:diamond_block'] = {all = 'diamond_block'},
   ['minecraft:lapis_block'] = {all = 'lapis_block'},
   ['minecraft:smooth_stone_slab'] = {up = 'stone_slab_top', down = 'stone_slab_top', side = 'stone_slab'},
   ['minecraft:oak_leaves'] = {all = 'oak_leaves'},
   ['minecraft:spruce_leaves'] = {all = 'birch_leaves'},
   ['minecraft:birch_leaves'] = {all = 'spruce_leaves'},
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
   ['minecraft:cake'] = {
      up = 'cake_top',
      down = 'cake_bottom',
      side = 'cake_side',
      west = function(block)
         return block.properties.bites == '0' and terrainAtlas.cake_side or terrainAtlas.cake_side_inside
      end
   },
   ['minecraft:lily_pad'] = {all = 'air', up = function(block)
      return terrainAtlas.lily_pad, randomRotation(block)
   end},
   ['minecraft:white_wool'] = {all = 'white_wool'},
   ['minecraft:black_wool'] = {all = 'black_wool'},
   ['minecraft:red_wool'] = {all = 'red_wool'},
   ['minecraft:green_wool'] = {all = 'green_wool'},
   ['minecraft:brown_wool'] = {all = 'brown_wool'},
   ['minecraft:blue_wool'] = {all = 'blue_wool'},
   ['minecraft:purple_wool'] = {all = 'purple_wool'},
   ['minecraft:cyan_wool'] = {all = 'cyan_wool'},
   ['minecraft:light_gray_wool'] = {all = 'light_gray_wool'},
   ['minecraft:gray_wool'] = {all = 'gray_wool'},
   ['minecraft:pink_wool'] = {all = 'pink_wool'},
   ['minecraft:lime_wool'] = {all = 'lime_wool'},
   ['minecraft:yellow_wool'] = {all = 'yellow_wool'},
   ['minecraft:light_blue_wool'] = {all = 'light_blue_wool'},
   ['minecraft:magenta_wool'] = {all = 'magenta_wool'},
   ['minecraft:orange_wool'] = {all = 'orange_wool'},
   ['minecraft:cactus'] = {up = 'cactus_top', side = 'cactus_side', down = 'cactus_down'},
   ['minecraft:farmland'] = {
      all = 'dirt',
      up = function(block)
         return block.properties.moisture == '7' and terrainAtlas.farmland_wet or terrainAtlas.farmland
      end
   },
   ['minecraft:netherrack'] = {all = 'netherrack'},
   ['minecraft:soul_sand'] = {all = 'soul_sand'},
   ['minecraft:glowstone'] = {all = 'glowstone'},
   ['minecraft:iron_bars'] = {side = 'iron_bars_side', up = 'iron_bars_top', down = 'iron_bars_top'},
   ['minecraft:glass_pane'] = {side = 'glass', up = 'glass_pane_top', down = 'glass_pane_top'},
   ['minecraft:oak_trapdoor'] = {all = 'oak_trapdoor'},
   ['minecraft:stone_bricks'] = {all = 'stone_bricks'},
   ['minecraft:clay'] = {all = 'clay'},
   ['minecraft:mossy_stone_bricks'] = {all = 'mossy_stone_bricks'},
   ['minecraft:cracked_stone_bricks'] = {all = 'cracked_stone_bricks'},
   ['minecraft:enchanting_table'] = {side = 'enchanting_table_side', up = 'enchanting_table_top', down = 'enchanting_table_down'},
   ['minecraft:note_block'] = {all = 'note_block'},
   ['minecraft:jukebox'] = {all = 'note_block', up = 'jukebox'},
   ['minecraft:smooth_stone'] = {all = 'stone_slab_top'}, -- block transmutation bug?
   ['minecraft:furnace'] = {
      up = 'furnace_top',
      down = 'furnace_top',
      side = function(block, face)
         if block.properties.facing == face then
            return block.properties.lit == 'true' and terrainAtlas.furnace_front_lit or terrainAtlas.furnace_front
         end
         return terrainAtlas.furnace_side
      end
   },
   ['minecraft:dispenser'] = {
      up = 'furnace_top',
      down = 'furnace_top',
      side = function(block, face)
         if block.properties.facing == face then
            return terrainAtlas.dispenser_front
         end
         return terrainAtlas.furnace_side
      end
   }
}

local blockAliasMap = {
   ['minecraft:grass'] = 'minecraft:short_grass', -- for 1.20.2 and below
   ['minecraft:snow'] = 'minecraft:snow_block',
   ['minecraft:moss_block'] = 'minecraft:lime_wool',
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
   if faces then
      setBlock(faces, id, newId)
   end
end

-- generate aliases for block models
local blockModels = require('block_models')
for newId, id in pairs(blockAliasMap) do
   blockModels[newId] = blockModels[id]
end

return finalList, blockFuncs, blockPropertiesFinal