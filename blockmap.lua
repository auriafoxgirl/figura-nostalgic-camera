local blockModels=require('block_models')

local terrainAtlas={
   air=vec(184, 214),
   grass_top=vec(0, 0),
   grass_side=vec(48, 0),
   grass_snow_side=vec(64, 64),
   dirt=vec(32, 0),
   oak_planks=vec(64, 0),
   stone=vec(16, 0),
   snow=vec(32, 64),
   ice=vec(48, 64),
   cobblestone=vec(0, 16),
   bedrock=vec(16, 16),
   sand=vec(32, 16),
   gravel=vec(48, 16),
   oak_log_side=vec(64, 16),
   spruce_log_side=vec(64, 112),
   birch_log_side=vec(80, 112),
   log_top=vec(80, 16),
   iron_block=vec(96, 16),
   gold_block=vec(112, 16),
   diamond_block=vec(128, 16),
   lapis_block=vec(0, 144),
   stone_slab=vec(80, 0),
   stone_slab_top=vec(96, 0),
   oak_leaves=vec(64, 48),
   spruce_leaves=vec(96, 192),
   birch_leaves=vec(64, 128),
   bricks=vec(112, 0),
   tnt_side=vec(128, 0),
   tnt_top=vec(144, 0),
   tnt_down=vec(160, 0),
   glass=vec(16, 48),
   glass_pane_top=vec(64, 144),
   water=vec(208, 192),
   lava=vec(208, 224),
   obsidian=vec(80, 32),
   gold_ore=vec(0, 32),
   iron_ore=vec(16, 32),
   coal_ore=vec(32, 32),
   diamond_ore=vec(32, 48),
   redstone_ore=vec(48, 48),
   lapis_ore=vec(0, 160),
   mossy_cobblestone=vec(64, 32),
   bookshelf=vec(48, 32),
   sponge=vec(0, 48),
   sandstone_top=vec(0, 176),
   sandstone_side=vec(0, 192),
   sandstone_down=vec(0, 208),
   crafting_table_top=vec(176, 32),
   crafting_table_side1=vec(176, 48),
   crafting_table_side2=vec(192, 48),
   nether_portal=vec(64, 192),
   mycelium_top=vec(224, 64),
   mycelium_side=vec(208, 64),
   cake_top=vec(144, 112),
   cake_side=vec(160, 112),
   cake_side_inside=vec(176, 112),
   cake_bottom=vec(192, 112),
   lily_pad=vec(192, 64),
   white_wool=vec(0, 64),
   black_wool=vec(16, 112),
   red_wool=vec(16, 128),
   green_wool=vec(16, 144),
   brown_wool=vec(16, 160),
   blue_wool=vec(16, 176),
   purple_wool=vec(16, 192),
   cyan_wool=vec(16, 208),
   light_gray_wool=vec(16, 224),
   gray_wool=vec(32, 112),
   pink_wool=vec(32, 128),
   lime_wool=vec(32, 144),
   yellow_wool=vec(32, 160),
   light_blue_wool=vec(32, 176),
   magenta_wool=vec(32, 192),
   orange_wool=vec(32, 208),
   cactus_top=vec(80, 64),
   cactus_side=vec(96, 64),
   cactus_down=vec(112, 64),
   farmland=vec(112, 80),
   farmland_wet=vec(96, 80),
   netherrack=vec(112, 96),
   soul_sand=vec(128, 96),
   glowstone=vec(144, 96),
   iron_bars_side=vec(80, 80),
   iron_bars_top=vec(48, 208),
   oak_trapdoor=vec(64, 80),
   stone_bricks=vec(96, 48),
   mossy_stone_bricks=vec(64, 96),
   cracked_stone_bricks=vec(80, 96),
   clay=vec(128, 64),
   enchanting_table_top=vec(96, 160),
   enchanting_table_side=vec(96, 176),
   enchanting_table_down=vec(112, 176),
   note_block=vec(160, 64),
   jukebox=vec(176, 64),
   furnace_front=vec(192, 32),
   furnace_front_lit=vec(208, 48),
   furnace_side=vec(208, 32),
   furnace_top=vec(224, 48),
   dispenser_front=vec(224, 32),
   pumpkin_front=vec(112, 112),
   pumpkin_side=vec(96, 112),
   pumpkin_top=vec(96, 96),
   melon_side=vec(128, 128),
   melon_top=vec(144, 128),
   vine=vec(240, 128),
   end_portal_frame_side=vec(240, 144),
   end_portal_frame_top=vec(224, 144),
   end_portal_frame_top_eye=vec(224, 160),
   end_portal_frame_side_eye=vec(240, 176),
   end_stone=vec(240, 160),
   end_portal=vec(64, 208),
   red_mushroom_block=vec(208, 112),
   brown_mushroom_block=vec(224, 112),
   mushroom_inside=vec(224, 128),
   mushroom_stem=vec(208, 128),
   bed_top1=vec(96, 128),
   bed_top2=vec(112, 128),
   bed_side1=vec(96, 144),
   bed_side2=vec(112, 144),
   bed_front1=vec(80, 144),
   bed_front2=vec(128, 144),
   spawner=vec(16, 64),
   nether_bricks=vec(0, 224),
   wooden_door_top=vec(16, 80),
   wooden_door_bottom=vec(16, 96),
   iron_door_top=vec(32, 80),
   iron_door_bottom=vec(32, 96),
   piston_front=vec(176, 96),
   piston_front_sticky=vec(160, 96),
   piston_front_extended=vec(224, 96),
   piston_back=vec(208, 96),
   piston_side=vec(192, 96),
   piston_head=vec(144, 160),
   repeater=vec(48, 128),
   repeater_lit=vec(48, 144),
   redstone_dot=vec(64, 176),
   redstone_4=vec(64, 160),
   redstone_line=vec(80, 160),
   redstone_curve=vec(80, 176),
   redstone_3=vec(80, 208),
   rail=vec(0, 128),
   rail_curved=vec(0, 112),
   powered_rail=vec(48, 160),
   powered_rail_powered=vec(48, 176),
   detector_rail=vec(48, 192),
}

local uvRotMats={
   [0]=matrices.mat3(),
   matrices.translate3(-0.5, -0.5):rotate(0, 0, 90):translate(0.5, 0.5),
   matrices.translate3(-0.5, -0.5):rotate(0, 0, 180):translate(0.5, 0.5),
   matrices.translate3(-0.5, -0.5):rotate(0, 0, -90):translate(0.5, 0.5),
}

local flipXMat=matrices.translate3(-0.5, -0.5):scale(-1, 1, 1):translate(0.5, 0.5)

local faceToN={
   north=0,
   west=1,
   south=2,
   east=3,
}

local mathFloor=math.floor
---@param block BlockState
local function randomRotation(block)
   local p=block:getPos()
   return uvRotMats[mathFloor(p.x * 9613.51367 + p.y * 6871.16432 + p.z * 9907.6413) % 4]
end

---@param block BlockState
---@param face Entity.blockSide
---@return number, number
local function pistonLogic(block, face)
   local faceN=faceToN[block.properties.facing]
   if faceN then
      if not faceToN[face] then
         if face == 'down' then
            faceN=2 - faceN
         end
         return 3, (faceN + 3) % 4
      end
      faceN=faceN - faceToN[face]
      faceN=faceN % 4
      if faceN == 0 then
         return block.properties.type == 'sticky' and 1 or 2, 0
      elseif faceN == 2 then
         return 4, 0
      end
      return 3, faceN == 1 and 2 or 0
   end
   if block.properties.facing == 'up' then
      if face == 'up' then
         return block.properties.type == 'sticky' and 1 or 2, 0
      elseif face == 'down' then
         return 4, 0
      end
      return 3, 3
   end
   if face == 'down' then
      return block.properties.type == 'sticky' and 1 or 2, 0
   elseif face == 'up' then
      return 4, 0
   end
   return 3, 1
end

local redstoneMap={
   ['0000']={terrainAtlas.redstone_dot, 0}, -- dot
   ['0001']={terrainAtlas.redstone_dot, 0}, -- impossible state
   ['0010']={terrainAtlas.redstone_dot, 0}, -- impossible state
   ['0011']={terrainAtlas.redstone_curve, 3}, -- curve
   ['0100']={terrainAtlas.redstone_dot, 0}, -- impossible state
   ['0101']={terrainAtlas.redstone_line, 0}, -- line
   ['0110']={terrainAtlas.redstone_curve, 0}, -- curve
   ['0111']={terrainAtlas.redstone_3, 0}, -- 3
   ['1000']={terrainAtlas.redstone_dot, 0}, -- impossible state
   ['1001']={terrainAtlas.redstone_curve, 2}, -- curve
   ['1010']={terrainAtlas.redstone_line, 1}, -- line
   ['1011']={terrainAtlas.redstone_3, 3}, -- 3
   ['1100']={terrainAtlas.redstone_curve, 1}, -- curve
   ['1101']={terrainAtlas.redstone_3, 2}, -- 3
   ['1110']={terrainAtlas.redstone_3, 1}, -- 3
   ['1111']={terrainAtlas.redstone_4, 0}, -- 4
}

local redstoneColor={
   [0]=vectors.hexToRGB('4c0000'),
   vectors.hexToRGB('6f000b'),
   vectors.hexToRGB('78000c'),
   vectors.hexToRGB('82000d'),
   vectors.hexToRGB('8c000e'),
   vectors.hexToRGB('97000f'),
   vectors.hexToRGB('a00010'),
   vectors.hexToRGB('aa0011'),
   vectors.hexToRGB('b40012'),
   vectors.hexToRGB('be0013'),
   vectors.hexToRGB('c90014'),
   vectors.hexToRGB('d30015'),
   vectors.hexToRGB('de0016'),
   vectors.hexToRGB('e80017'),
   vectors.hexToRGB('f21d19'),
   vectors.hexToRGB('fd331c'),
}

local blocks={
   ['minecraft:air']={all='air'},
   ['minecraft:grass_block']={
      up='grass_top',
      side=function(block)
         return block.properties.snowy == 'true' and terrainAtlas.grass_snow_side or terrainAtlas.grass_side
      end,
      down='dirt'
   },
   ['minecraft:mycelium']={up='mycelium_top', side='mycelium_side', down='dirt'},
   ['minecraft:stone']={all='stone'},
   ['minecraft:dirt']={all='dirt'},
   ['minecraft:snow_block']={all='snow'},
   ['minecraft:oak_planks']={all='oak_planks'},
   ['minecraft:cobblestone']={all='cobblestone'},
   ['minecraft:bedrock']={all='bedrock'},
   ['minecraft:sand']={all='sand'},
   ['minecraft:gravel']={all='gravel'},
   ['minecraft:oak_log']={up='log_top', side='oak_log_side', down='log_top'},
   ['minecraft:spruce_log']={up='log_top', side='spruce_log_side', down='log_top'},
   ['minecraft:birch_log']={up='log_top', side='birch_log_side', down='log_top'},
   ['minecraft:iron_block']={all='iron_block'},
   ['minecraft:gold_block']={all='gold_block'},
   ['minecraft:diamond_block']={all='diamond_block'},
   ['minecraft:lapis_block']={all='lapis_block'},
   ['minecraft:smooth_stone_slab']={up='stone_slab_top', down='stone_slab_top', side='stone_slab'},
   ['minecraft:oak_leaves']={all='oak_leaves'},
   ['minecraft:spruce_leaves']={all='birch_leaves'},
   ['minecraft:birch_leaves']={all='spruce_leaves'},
   ['minecraft:bricks']={all='bricks'},
   ['minecraft:tnt']={up='tnt_top', side='tnt_side', down='tnt_down'},
   ['minecraft:glass']={all='glass'},
   ['minecraft:ice']={all='ice'},
   ['minecraft:water']={all='water'},
   ['minecraft:lava']={all='lava'},
   ['minecraft:obsidian']={all='obsidian'},
   ['minecraft:gold_ore']={all='gold_ore'},
   ['minecraft:iron_ore']={all='iron_ore'},
   ['minecraft:coal_ore']={all='coal_ore'},
   ['minecraft:diamond_ore']={all='diamond_ore'},
   ['minecraft:redstone_ore']={all='redstone_ore'},
   ['minecraft:lapis_ore']={all='lapis_ore'},
   ['minecraft:mossy_cobblestone']={all='mossy_cobblestone'},
   ['minecraft:bookshelf']={side='bookshelf', up='oak_planks', down='oak_planks'},
   ['minecraft:sponge']={all='sponge'},
   ['minecraft:sandstone']={side='sandstone_side', up='sandstone_top', down='sandstone_down'},
   ['minecraft:crafting_table']={up='crafting_table_top', down='oak_planks', east='crafting_table_side1', south='crafting_table_side1', west='crafting_table_side2', north='crafting_table_side2'},
   ['minecraft:nether_portal']={all='nether_portal'},
   ['minecraft:cake']={
      up='cake_top',
      down='cake_bottom',
      side='cake_side',
      west=function(block)
         return block.properties.bites == '0' and terrainAtlas.cake_side or terrainAtlas.cake_side_inside
      end
   },
   ['minecraft:lily_pad']={all='air', up=function(block)
      return terrainAtlas.lily_pad, randomRotation(block)
   end},
   ['minecraft:white_wool']={all='white_wool'},
   ['minecraft:black_wool']={all='black_wool'},
   ['minecraft:red_wool']={all='red_wool'},
   ['minecraft:green_wool']={all='green_wool'},
   ['minecraft:brown_wool']={all='brown_wool'},
   ['minecraft:blue_wool']={all='blue_wool'},
   ['minecraft:purple_wool']={all='purple_wool'},
   ['minecraft:cyan_wool']={all='cyan_wool'},
   ['minecraft:light_gray_wool']={all='light_gray_wool'},
   ['minecraft:gray_wool']={all='gray_wool'},
   ['minecraft:pink_wool']={all='pink_wool'},
   ['minecraft:lime_wool']={all='lime_wool'},
   ['minecraft:yellow_wool']={all='yellow_wool'},
   ['minecraft:light_blue_wool']={all='light_blue_wool'},
   ['minecraft:magenta_wool']={all='magenta_wool'},
   ['minecraft:orange_wool']={all='orange_wool'},
   ['minecraft:cactus']={up='cactus_top', side='cactus_side', down='cactus_down'},
   ['minecraft:farmland']={
      all='dirt',
      up=function(block)
         return block.properties.moisture == '7' and terrainAtlas.farmland_wet or terrainAtlas.farmland
      end
   },
   ['minecraft:netherrack']={all='netherrack'},
   ['minecraft:soul_sand']={all='soul_sand'},
   ['minecraft:glowstone']={all='glowstone'},
   ['minecraft:iron_bars']={side='iron_bars_side', up='iron_bars_top', down='iron_bars_top'},
   ['minecraft:glass_pane']={side='glass', up='glass_pane_top', down='glass_pane_top'},
   ['minecraft:oak_trapdoor']={all='oak_trapdoor'},
   ['minecraft:stone_bricks']={all='stone_bricks'},
   ['minecraft:clay']={all='clay'},
   ['minecraft:mossy_stone_bricks']={all='mossy_stone_bricks'},
   ['minecraft:cracked_stone_bricks']={all='cracked_stone_bricks'},
   ['minecraft:enchanting_table']={side='enchanting_table_side', up='enchanting_table_top', down='enchanting_table_down'},
   ['minecraft:note_block']={all='note_block'},
   ['minecraft:jukebox']={all='note_block', up='jukebox'},
   ['minecraft:smooth_stone']={all='stone_slab_top'}, -- block transmutation bug?
   ['minecraft:furnace']={
      up='furnace_top',
      down='furnace_top',
      side=function(block, face)
         if block.properties.facing == face then
            return block.properties.lit == 'true' and terrainAtlas.furnace_front_lit or terrainAtlas.furnace_front
         end
         return terrainAtlas.furnace_side
      end
   },
   ['minecraft:dispenser']={
      up='furnace_top',
      down='furnace_top',
      side=function(block, face)
         local blockFace=block.properties.facing
         if (faceToN[blockFace] and blockFace or 'north') == face then
            return terrainAtlas.dispenser_front
         end
         return terrainAtlas.furnace_side
      end
   },
   ['minecraft:carved_pumpkin']={
      up='pumpkin_top',
      down=function()
         return terrainAtlas.pumpkin_top, uvRotMats[1]
      end,
      side=function(block, face)
         if block.properties.facing == face then
            return terrainAtlas.pumpkin_front
         end
         return terrainAtlas.pumpkin_side
      end
   },
   ['minecraft:jack_o_lantern']={
      up='pumpkin_top',
      down=function()
         return terrainAtlas.pumpkin_top, uvRotMats[1]
      end,
      side=function(block, face)
         if block.properties.facing == face then
            return terrainAtlas.jack_o_lantern
         end
         return terrainAtlas.pumpkin_side
      end
   },
   ['minecraft:pumpkin']={
      north='pumpkin_front',
      side='pumpkin_side',
      up='pumpkin_top',
      down=function()
         return terrainAtlas.pumpkin_top, uvRotMats[1]
      end,
   },
   ['minecraft:melon']={side='melon_side', all='melon_top'},
   ['minecraft:vine']={
      all='air',
      side=function()
         return terrainAtlas.vine, nil, 'up'
      end
   },
   ['minecraft:end_portal_frame']={
      down='end_stone',
      side=function(block)
         return block.properties.eye == 'true' and terrainAtlas.end_portal_frame_side_eye or terrainAtlas.end_portal_frame_side
      end,
      up=function(block)
         return block.properties.eye == 'true' and terrainAtlas.end_portal_frame_top_eye or terrainAtlas.end_portal_frame_top,
            uvRotMats[ faceToN[block.properties.facing] ]
      end
   },
   ['minecraft:end_stone']={all='end_stone'},
   ['minecraft:end_portal']={all='air', up='end_portal'},
   ['minecraft:red_mushroom_block']={all=function(block, face)
      return block.properties[face] == 'true' and terrainAtlas.red_mushroom_block or terrainAtlas.mushroom_inside
   end},
   ['minecraft:brown_mushroom_block']={all=function(block, face)
      return block.properties[face] == 'true' and terrainAtlas.brown_mushroom_block or terrainAtlas.mushroom_inside
   end},
   ['minecraft:mushroom_stem']={all='mushroom_inside', side='mushroom_stem'},
   ['minecraft:red_bed']={
      up=function(block)
         return block.properties.part == 'head' and terrainAtlas.bed_top2 or terrainAtlas.bed_top1,
            uvRotMats[ (faceToN[block.properties.facing] + 1) % 4 ]
      end,
      side=function(block, face)
         face=(faceToN[face] - faceToN[block.properties.facing]) % 4
         if block.properties.part == 'head' then
            return face == 0 and terrainAtlas.bed_front2 or terrainAtlas.bed_side2,
               face == 1 and flipXMat or nil
         end
         return face == 2 and terrainAtlas.bed_front1 or terrainAtlas.bed_side1,
            face == 1 and flipXMat or nil
      end,
      down='oak_planks'
   },
   ['minecraft:spawner']={all='spawner'},
   ['minecraft:nether_bricks']={all='nether_bricks'},
   ['minecraft:oak_door']={all=function(block)
      local faceN=faceToN[block.properties.facing] + 2
      if block.properties.open == 'true' then
         faceN=faceN + (block.properties.hinge == 'right' and 1 or -1)
      end
      return block.properties.half == 'upper' and terrainAtlas.wooden_door_top or terrainAtlas.wooden_door_bottom,
         uvRotMats[ faceN % 4 ]
   end,
   side=function(block, face)
      local side=block.properties.hinge == 'left'
      local faceN=faceToN[block.properties.facing] - faceToN[face]
      if block.properties.open == 'true' then
         faceN=faceN + (side and 1 or -1)
      end
      faceN=faceN % 4
      if faceN == 2 then
         side=not side
      end
      return block.properties.half == 'upper' and terrainAtlas.wooden_door_top or terrainAtlas.wooden_door_bottom,
         side and flipXMat or nil
   end},
   ['minecraft:iron_door']={all=function(block)
      local faceN=faceToN[block.properties.facing] + 2
      if block.properties.open == 'true' then
         faceN=faceN + (block.properties.hinge == 'right' and 1 or -1)
      end
      return block.properties.half == 'upper' and terrainAtlas.iron_door_top or terrainAtlas.iron_door_bottom,
         uvRotMats[ faceN % 4 ]
   end,
   side=function(block, face)
      local side=block.properties.hinge == 'left'
      local faceN=faceToN[block.properties.facing] - faceToN[face]
      if block.properties.open == 'true' then
         faceN=faceN + (side and 1 or -1)
      end
      faceN=faceN % 4
      if faceN == 2 then
         side=not side
      end
      return block.properties.half == 'upper' and terrainAtlas.iron_door_top or terrainAtlas.iron_door_bottom,
         side and flipXMat or nil
   end},
   ['minecraft:piston_head']={
      all=function(block, face)
         local tex, rot=pistonLogic(block, face)
         local mat=uvRotMats[rot]
         if tex == 1 then
            return terrainAtlas.piston_front_sticky, mat
         elseif tex == 2 then
            return terrainAtlas.piston_front, mat
         elseif tex == 3 then
            return terrainAtlas.piston_head, mat
         end
         return terrainAtlas.piston_front, mat
      end
   },
   ['minecraft:piston']={
      all=function(block, face)
         local tex, rot=pistonLogic(block, face)
         if tex == 3 then
            rot=(rot + 1) % 4
         end
         local mat=uvRotMats[rot]
         if tex <= 2 then
            return block.properties.extended and terrainAtlas.piston_front_extended or terrainAtlas.piston_front, mat
         elseif tex == 3 then
            return terrainAtlas.piston_side, mat
         end
         return terrainAtlas.piston_back, mat
      end
   },
   ['minecraft:sticky_piston']={
      all=function(block, face)
         local tex, rot=pistonLogic(block, face)
         if tex == 3 then
            rot=(rot + 1) % 4
         end
         local mat=uvRotMats[rot]
         if tex <= 2 then
            return block.properties.extended and terrainAtlas.piston_front_extended or terrainAtlas.piston_front_sticky, mat
         elseif tex == 3 then
            return terrainAtlas.piston_side, mat
         end
         return terrainAtlas.piston_back, mat
      end
   },
   ['minecraft:repeater']={ -- i cant do block models sadly
      all='stone_slab_top',
      up=function(block)
         return block.properties.powered == 'true' and terrainAtlas.repeater_lit or terrainAtlas.repeater,
            uvRotMats[ (faceToN[block.properties.facing] + 2) % 4 ]
      end
   },
   ['minecraft:redstone_wire']={
      side=function(block)
         return terrainAtlas.redstone_line, uvRotMats[1], nil, redstoneColor[tonumber(block.properties.power)]
      end,
      up=function(block)
         local shape=redstoneMap[
            (block.properties.north ~= 'none' and '1' or '0')..
            (block.properties.east ~= 'none' and '1' or '0')..
            (block.properties.south ~= 'none' and '1' or '0')..
            (block.properties.west ~= 'none' and '1' or '0')
         ]
         return shape[1], uvRotMats[ shape[2] ], nil, redstoneColor[tonumber(block.properties.power)]
      end,
      down='air'
   },
   ['minecraft:rail']={
      all='air',
      up=function(block)
         local shape=block.properties.shape
         if shape == 'south_east' then
            return terrainAtlas.rail_curved
         elseif shape == 'south_west' then
            return terrainAtlas.rail_curved, uvRotMats[3]
         elseif shape == 'north_west' then
            return terrainAtlas.rail_curved, uvRotMats[2]
         elseif shape == 'north_east' then
            return terrainAtlas.rail_curved, uvRotMats[1]
         elseif shape == 'east_west' then
            return terrainAtlas.rail, uvRotMats[1]
         end
         return terrainAtlas.rail
      end
   },
   ['minecraft:powered_rail']={
      all='air',
      up=function(block)
         return block.properties.powered == 'true' and terrainAtlas.powered_rail or terrainAtlas.powered_rail,
            block.properties.shape == 'east_west' and uvRotMats[1] or nil
      end
   },
   ['minecraft:detector_rail']={
      all='air',
      up=function(block)
         return terrainAtlas.detector_rail,
            block.properties.shape == 'east_west' and uvRotMats[1] or nil
      end
   },
   ['minecraft:stone_button']={ -- buttons were only placable on walls in old versions
      all=function(block)
         return block.properties.face == 'wall' and terrainAtlas.stone or terrainAtlas.air
      end
   }
}

local blockAliasMap={
   ['minecraft:grass']='minecraft:short_grass', -- for 1.20.2 and below
   ['minecraft:lever']='minecraft:air', -- too big
   ['minecraft:fire']='minecraft:air', -- too big
   ['minecraft:brewing_stand']='minecraft:air', -- too big
   ['minecraft:snow']='minecraft:snow_block',
   ['minecraft:moss_block']='minecraft:lime_wool',
   ['minecraft:andesite']='minecraft:stone',

   ['minecraft:wet_sponge']='minecraft:sponge',

   ['minecraft:barrier']='minecraft:air',

   ['minecraft:petrified_oak_slab']='minecraft:oak_planks',
   ['minecraft:sandstone_slab']='minecraft:sandstone',
   ['minecraft:cobblestone_slab']='minecraft:cobblestone',
   ['minecraft:cobblestone_stairs']='minecraft:cobblestone',
   ['minecraft:brick_slab']='minecraft:bricks',
   ['minecraft:brick_stairs']='minecraft:bricks',
   ['minecraft:stone_brick_slab']='minecraft:stone_bricks',
   ['minecraft:stone_brick_stairs']='minecraft:stone_bricks',
   ['minecraft:nether_brick_stairs']='minecraft:nether_bricks',

   ['minecraft:polished_blackstone_button']='minecraft:stone_button',
   ['minecraft:stone_pressure_plate']='minecraft:stone',
   ['minecraft:polished_blackstone_pressure_plate']='minecraft:stone',
   ['minecraft:light_weighted_pressure_plate']='minecraft:stone',
   ['minecraft:heavy_weighted_pressure_plate']='minecraft:stone',

   ['minecraft:stripped_spruce_log']='minecraft:oak_log',
   ['minecraft:shulker_box']='minecraft:purple_wool',
   ['minecraft:tinted_glass']='minecraft:glass',
   ['minecraft:dirt_path']='minecraft:farmland',
   ['minecraft:packed_ice']='minecraft:light_blue_wool',
   ['minecraft:blue_ice']='minecraft:cyan_wool',
   ['minecraft:water_cauldron']='minecraft:cauldron',
   ['minecraft:lava_cauldron']='minecraft:cauldron',
   ['minecraft:powder_snow_cauldron']='minecraft:cauldron',

   ['minecraft:cherry_leaves']='minecraft:pink_wool',
   ['minecraft:azalea_leaves']='minecraft:oak_leaves',
   ['minecraft:flowering_azalea_leaves']='minecraft:oak_leaves',
   ['minecraft:manrove_propagule']='minecraft:air',
   ['minecraft:azalea']='minecraft:air',
   ['minecraft:flowering_azalea']='minecraft:air',
   ['minecraft:blue_orchid']='minecraft:poppy',
   ['minecraft:allium']='minecraft:dandelion',
   ['minecraft:azure_bluet']='minecraft:dandelion',
   ['minecraft:red_tulip']='minecraft:poppy',
   ['minecraft:orange_tulip']='minecraft:dandelion',
   ['minecraft:white_tulip']='minecraft:dandelion',
   ['minecraft:pink_tulip']='minecraft:poppy',
   ['minecraft:oxeye_daisy']='minecraft:dandelion',
   ['minecraft:cornflower']='minecraft:poppy',
   ['minecraft:lily_of_the_valley']='minecraft:dandelion',
   ['minecraft:torchflower']='minecraft:dandelion',
   ['minecraft:wither_rose']='minecraft:poppy',
   ['minecraft:pink_petals']='minecraft:air',
   ['minecraft:sunflower']='minecraft:air',
   ['minecraft:lilac']='minecraft:air',
   ['minecraft:rose_bush']='minecraft:air',
   ['minecraft:peony']='minecraft:air',
   ['minecraft:pitcher_plant']='minecraft:air',

   ['minecraft:dark_oak_log']='minecraft:spruce_log',
   ['minecraft:stripped_dark_oak_log']='minecraft:spruce_log',
   ['minecraft:dark_oak_wood']='minecraft:spruce_log',
   ['minecraft:stripped_dark_oak_wood']='minecraft:spruce_log',
   ['minecraft:quartz_block']='minecraft:iron_block',
   ['minecraft:smooth_quartz']='minecraft:snow_block',
   ['minecraft:sea_lantern']='minecraft:diamond_block',

   ['minecraft:tall_grass']='minecraft:air',

   ['minecraft:copper_ore']='minecraft:gold_ore',
   ['minecraft:emerald_ore']='minecraft:redstone_ore',
   ['minecraft:deepslate_coal_ore']='minecraft:coal_ore',
   ['minecraft:deepslate_iron_ore']='minecraft:iron_ore',
   ['minecraft:deepslate_copper_ore']='minecraft:gold_ore',
   ['minecraft:deepslate_gold_ore']='minecraft:gold_ore',
   ['minecraft:deepslate_redstone_ore']='minecraft:redstone_ore',
   ['minecraft:deepslate_emerald_ore']='minecraft:redstone_ore',
   ['minecraft:deepslate_lapis_ore']='minecraft:lapis_ore',
   ['minecraft:deepslate_diamond_ore']='minecraft:diamond_ore',
   ['minecraft:nether_gold_ore']='minecraft:netherrack',
   ['minecraft:nether_quartz_ore']='minecraft:netherrack',

   ['minecraft:dark_oak_fence']='minecraft:nether_brick_fence',
   ['minecraft:nether_brick_wall']='minecraft:nether_brick_fence',

   ['minecraft:red_nether_bricks']='minecraft:nether_bricks',
   ['minecraft:red_nether_brick_stairs']='minecraft:nether_bricks',
   ['minecraft:red_nether_brick_slab']='minecraft:nether_bricks',
   ['minecraft:red_nether_brick_wall']='minecraft:nether_brick_fence',

   ['minecraft:ender_chest']='minecraft:chest',
   ['minecraft:iron_trapdoor']='minecraft:oak_trapdoor',
   ['minecraft:beacon']='minecraft:diamond_block',
   ['minecraft:candle']='minecraft:air',
   ['minecraft:candle_cake']='minecraft:cake',

   ['minecraft:crimson_nylium']='minecraft:netherrack',
   ['minecraft:warped_nylium']='minecraft:netherrack',

   ['minecraft:infested_stone_bricks']='minecraft:stone_bricks',
   ['minecraft:infested_stone']='minecraft:stone',
   ['minecraft:infested_mossy_stone_bricks']='minecraft:mossy_stone_bricks',
   ['minecraft:infested_cracked_stone_bricks']='minecraft:cracked_stone_bricks',
   ['minecraft:infested_cobblestone']='minecraft:cobblestone',

   ['minecraft:composter']='minecraft:cauldron',
   ['minecraft:chiseled_bookshelf']='minecraft:bookshelf',

   ['minecraft:crafter']='minecraft:crafting_table',

   ['minecraft:tuff']='minecraft:stone',

   ['minecraft:smooth_sandstone']='minecraft:sandstone',
   ['minecraft:smooth_sandstone_slab']='minecraft:sandstone',
   ['minecraft:coarse_dirt']='minecraft:dirt',
}

local blockAliasMap2={}

for _, wood in pairs({
   'oak', 'spruce', 'birch',
   'jungle', 'acacia', 'dark_oak',
   'mangrove', 'cherry', 'bamboo',
   'crimson', 'warped', 'pale'
}) do
   blockAliasMap2['minecraft:'..wood..'_planks']='minecraft:oak_planks'
   blockAliasMap2['minecraft:'..wood..'_slab']='minecraft:oak_planks'
   blockAliasMap2['minecraft:'..wood..'_stairs']='minecraft:oak_planks'
   blockAliasMap2['minecraft:'..wood..'_button']='minecraft:stone_button'
   blockAliasMap2['minecraft:'..wood..'_pressure_plate']='minecraft:oak_planks'
   blockAliasMap2['minecraft:'..wood..'_fence']='minecraft:oak_fence'
   blockAliasMap2['minecraft:'..wood..'_fence_gate']='minecraft:oak_fence_gate'
   blockAliasMap2['minecraft:'..wood..'_log']='minecraft:oak_log'
   blockAliasMap2['minecraft:stripped_'..wood..'_log']='minecraft:oak_planks'
   blockAliasMap2['minecraft:stripped_'..wood..'_wood']='minecraft:oak_planks'
   blockAliasMap2['minecraft:'..wood..'_wood']='minecraft:oak_log'
   blockAliasMap2['minecraft:'..wood..'_trapdoor']='minecraft:oak_trapdoor'
   blockAliasMap2['minecraft:'..wood..'_leaves']='minecraft:oak_leaves'
   blockAliasMap2['minecraft:'..wood..'_sapling']='minecraft:oak_sapling'
   blockAliasMap2['minecraft:'..wood..'_sign']='minecraft:air' -- cant do block model
   blockAliasMap2['minecraft:'..wood..'_wall_sign']='minecraft:air'
   blockAliasMap2['minecraft:'..wood..'_hanging_sign']='minecraft:air'
   blockAliasMap2['minecraft:'..wood..'_wall_hanging_sign']='minecraft:air'
   blockAliasMap2['minecraft:'..wood..'_door']='minecraft:oak_door'
end

local woolColors={}

for _, color in pairs({
   "white", "black", "red", "green",
   "brown", "blue", "purple", "cyan",
   "light_gray", "gray", "pink", "lime",
   "yellow", "light_blue", "magenta", "orange",
}) do
   woolColors['minecraft:'..color..'_wool']=world.newBlock('minecraft:'..color..'_wool'):getMapColor()
   blockAliasMap2['minecraft:'..color..'_concrete']='minecraft:'..color..'_wool'
   blockAliasMap2['minecraft:'..color..'_concrete_powder']='minecraft:'..color..'_wool'
   blockAliasMap2['minecraft:'..color..'_shulker_box']='minecraft:'..color..'_wool'
   blockAliasMap2['minecraft:'..color..'_terracotta']='minecraft:'..color..'_wool'
   blockAliasMap2['minecraft:'..color..'_glazed_terracotta']='minecraft:'..color..'_wool'
   blockAliasMap2['minecraft:'..color..'_candle']='minecraft:air'
   blockAliasMap2['minecraft:'..color..'_candle_cake']='minecraft:cake'
   blockAliasMap2['minecraft:'..color..'_stained_glass']='minecraft:glass'
   blockAliasMap2['minecraft:'..color..'_stained_glass_pane']='minecraft:glass_pane'
   blockAliasMap2['minecraft:'..color..'_carpet']='minecraft:air'
   blockAliasMap2['minecraft:'..color..'_banner']='minecraft:air'
   blockAliasMap2['minecraft:'..color..'_wall_banner']='minecraft:air'
   blockAliasMap2['minecraft:'..color..'_bed']='minecraft:red_bed'
end

for _, waxed in pairs({'', 'waxed_'}) do
   for oxidized, color in pairs({
      ['']='orange',
      exposed_='orange',
      weathered_='cyan',
      oxidized_='cyan'
   }) do
      local suffix=oxidized == '' and '_block' or ''
      blockAliasMap2['minecraft:'..waxed..oxidized..'copper'..suffix]='minecraft:'..color..'_wool'
      blockAliasMap2['minecraft:'..waxed..oxidized..'cut_copper']='minecraft:'..color..'_wool'
      blockAliasMap2['minecraft:'..waxed..oxidized..'cut_copper_stairs']='minecraft:bricks'
      blockAliasMap2['minecraft:'..waxed..oxidized..'cut_copper_slab']='minecraft:bricks'
      blockAliasMap2['minecraft:'..waxed..oxidized..'chiseled_copper']='minecraft:'..color..'_wool'
      blockAliasMap2['minecraft:'..waxed..oxidized..'copper_grate']='minecraft:glass'
      blockAliasMap2['minecraft:'..waxed..oxidized..'copper_door']='minecraft:oak_door'
      blockAliasMap2['minecraft:'..waxed..oxidized..'copper_trapdoor']='minecraft:oak_trapdoor'
      blockAliasMap2['minecraft:'..waxed..oxidized..'copper_bulb']='minecraft:'..color..'_wool'
   end
end

for coral, color in pairs({
   tube='blue',
   brain='pink',
   bubble='purple',
   fire='red',
   horn='yellow'
}) do
   for _, alive in pairs({'', 'dead_'}) do
      if alive ~= '' then
         color='light_gray'
      end
      blockAliasMap['minecraft:'..alive..coral..'_coral_block']='minecraft:'..color..'_wool'
      blockAliasMap['minecraft:'..alive..coral..'_coral']='minecraft:air'
      blockAliasMap['minecraft:'..alive..coral..'_coral_fan']='minecraft:air'
      blockAliasMap['minecraft:'..alive..coral..'_coral_wall_fan']='minecraft:air'
   end
end

for i, v in pairs(blockAliasMap2) do
   if not blockAliasMap[i] then
      blockAliasMap[i]=v
   end
end

-- automatically add block aliases
for _, blockId in pairs(client.getRegistry("minecraft:block")) do
   if not (blockAliasMap[blockId] or blockModels[blockId] or blocks[blockId]) then
      local ok, block=pcall(world.newBlock, blockId) -- world.newBlock errors for experimental blocks
      if ok then
         if blockId:match('^minecraft:potted_') or blockId:match('^minecraft:(.-)_wall$') then
            blockAliasMap[blockId]='minecraft:oak_fence'
         elseif blockId:match('_slab$') or blockId:match('_stairs$') then
            blockAliasMap[blockId]='minecraft:cobblestone'
         elseif blockId:match('deepslate$') then
            blockAliasMap[blockId]='minecraft:stone'
         elseif block:isFullCube() then
            local color=block:getMapColor()
            local dist=1000
            local closestBlock='minecraft:pink_wool'
            for bl, c in pairs(woolColors) do
               local d=(color - c):lengthSquared()
               if d < dist then
                  dist=d
                  closestBlock=bl
               end
            end
            blockAliasMap[blockId]=closestBlock
         else
            blockAliasMap[blockId]='minecraft:air'
         end
      end
   end
end

local blockProperties={
   ['minecraft:glass']={cull=1},
   ['minecraft:ice']={cull=2},
   ['minecraft:water']={cull=3},
   ['minecraft:nether_portal']={cull=4},
}

---@type {[string]: {[string]: Vector2}}
local finalList={
   up={},
   down={},
   north={},
   south={},
   east={},
   west={},
}

---@type {[string]: {[string]: fun(block: BlockState): Vector2}}
local blockFuncs={
   up={},
   down={},
   north={},
   south={},
   east={},
   west={},
}

local blockPropertiesFinal={}

-- fallback
for i, v in pairs(finalList) do
   setmetatable(v, {
      __index=function()
         return vec(208, 208)
      end
   })
end

setmetatable(blockPropertiesFinal, {
   __index=function()
      return {}
   end
})

---@param facesData table
---@param blockId string
---@param targetBlockId string
local function setBlock(facesData, blockId, targetBlockId)
   local faces={
      up=facesData.up or facesData.all,
      down=facesData.down or facesData.all,
      north=facesData.north or facesData.side or facesData.all,
      south=facesData.south or facesData.side or facesData.all,
      east=facesData.east or facesData.side or facesData.all,
      west=facesData.west or facesData.side or facesData.all,
   }
   for face, v in pairs(faces) do
      if type(v) == 'function' then
         blockFuncs[face][targetBlockId]=v
      else
         finalList[face][targetBlockId]=terrainAtlas[v]
      end
   end
   blockPropertiesFinal[blockId]=blockProperties[blockId] or {}
end

for id, faces in pairs(blocks) do
   setBlock(faces, id, id)
end

for newId, id in pairs(blockAliasMap) do
   if not blocks[newId] then
      local faces=blocks[id]
      if faces then
         setBlock(faces, id, newId)
      end
   end
end

-- generate aliases for block models
for newId, id in pairs(blockAliasMap) do
   if not blockModels[newId] then
      blockModels[newId]=blockModels[id]
   end
end

return finalList, blockFuncs, blockPropertiesFinal