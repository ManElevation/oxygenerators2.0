-- oxygenerator: block that gives breath at times while in radius, mod for minetest
-- minetest 0.4.17.1
-- (c) 2018 ManElevation

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

dofile(minetest.get_modpath("oxygenerator").."/particles.lua") --makes small particles emanate from the beginning of a beam
minetest.register_privilege("oxygenerator", {description = "Allows you to allways breath in space", give_to_singleplayer = false})
oxygenerator = {}
oxygenerator.radius = tonumber(minetest.settings:get("oxygenerator_radius")) or 5  

    minetest.register_node("oxygenerator:oxygenerator_small", {
    description = "Oxygenerator: gives breath at all times while in radius",
    drawtype = "nodebox",
	tiles = {
		"oxygenerator_top.png", "oxygenerator_side.png", -- TOP, BOTTOM
		"oxygenerator_side.png", "oxygenerator_side.png", -- SIDE, SIDE
		"oxygenerator_side.png", -- SIDE
		{
			image = "oxygenerator_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 3.5
			},
		}
	},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = true,
    groups = {snappy=2,cracky=3},
    legacy_wallmounted = true,
    is_watercraft = true,
on_punch = function(pos, node, puncher)
minetest.add_entity(pos, "oxygenerator:display") end,
    on_construct=function(pos)
        minetest.get_node_timer(pos):start(1)
    end,
    on_timer = function (pos, elapsed)
        for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
           if ob:get_breath() ~= 11 then
   		 ob:set_breath(10)
	    end
        end
    minetest.get_node_timer(pos):set(0.1, 0)
    end
})


minetest.register_entity("oxygenerator:display", {
	physical = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "wielditem",
	-- wielditem seems to be scaled to 1.5 times original node size
	visual_size = {x = 1.0 / 1.5, y = 1.0 / 1.5},
	textures = {"oxygenerator:display_node"},
	timer = 0,

	on_step = function(self, dtime)

		self.timer = self.timer + dtime

		-- remove after 5 seconds
		if self.timer > 5 then
			self.object:remove()
		end
	end,
})

local x = oxygenerator.radius
minetest.register_node("oxygenerator:display_node", {
	tiles = {"oxygenerator_display.png"},
	use_texture_alpha = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- sides
			{-(x+.55), -(x+.55), -(x+.55), -(x+.45), (x+.55), (x+.55)},
			{-(x+.55), -(x+.55), (x+.45), (x+.55), (x+.55), (x+.55)},
			{(x+.45), -(x+.55), -(x+.55), (x+.55), (x+.55), (x+.55)},
			{-(x+.55), -(x+.55), -(x+.55), (x+.55), (x+.55), -(x+.45)},
			-- top
			{-(x+.55), (x+.45), -(x+.55), (x+.55), (x+.55), (x+.55)},
			-- bottom
			{-(x+.55), -(x+.55), -(x+.55), (x+.55), -(x+.45), (x+.55)},
			-- middle (surround oxygenerator)
			{-.55,-.55,-.55, .55,.55,.55},
		},
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
})

minetest.register_craft({
	output = "oxygenerator:oxygenerator_small",
	recipe = {
                {"default:steel_ingot", "default:copper_ingot", "default:steel_ingot", },
                {"default:steel_ingot", "default:coalblock",        "default:steel_ingot", },
                {"default:steel_ingot", "default:copper_ingot", "default:steel_ingot", }
	}
})
-- Space! 
local function is_populated(pos)
    if minetest.find_node_near(pos, 5, {"oxygenerator:oxygenerator_small"}) ~= nil or
        minetest.find_node_near(pos, 26, {"oxygeneratorbig:oxygenerator_big"}) ~=nil then
        return true
    else
        return false
    end
end

space_timer=0

minetest.register_globalstep(function(dtime)
    space_timer=space_timer + dtime;
    if space_timer>1 then
        space_timer=0
        for _,player in ipairs(minetest.get_connected_players()) do
            local pos=player:get_pos()
            if pos.y>=1100 then
                if player then
                    player:set_physics_override({gravity=0.1})
                    player:set_sky({r=0, g=0, b=0},"skybox",{"sky_pos_y.png","sky_neg_y.png","sky_pos_z.png","sky_neg_z.png","sky_neg_x.png","sky_pos_x.png"})
                    if not is_populated(pos) then
                        local hp = player:get_hp()
                    --    local privs = minetest.get_player_privs(name);
                      --  if hp>0 and not privs.oxygenerator then
						if hp>0 then
                            player:set_hp(hp-1)
                        end
                    end
                end
            end
        end
    end
end)