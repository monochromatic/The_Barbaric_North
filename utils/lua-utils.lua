--	#textdomain wesnoth-The_Barbaric_North
--	
--	Lua snippets for The Barbaric North

local _ = wesnoth.textdomain "wesnoth-The_Barbaric_North"
local helper = wesnoth.require "lua/helper.lua"
local wml_actions = wesnoth.wml_actions

helper.set_wml_var_metatable(_G)

function wml_actions.limit_recruits(cfg)
	local value = tonumber(cfg.value) or helper.wml_error("Missing or wrong required 'value' attribute in [limit_recruits]")
	
	local filter = wesnoth.get_units(cfg)
	if #filter >= value then
		for index,unit in ipairs(filter) do
			wml_actions.disallow_recruit { side = unit.side , type = unit.type }
		end
	elseif not cfg.cumulative then
		if #filter < value then
			for index,unit in ipairs(filter) do
				wml_actions.allow_recruit { side = unit.side , type = unit.type }
			end
		end
	end
end

function wml_actions.frostbite_event(cfg)
	if cfg.fire_event then
		local frostbite_units = wesnoth.get_units { side = side_number , { "not" , { id = "Buggles" }} , { "filter_location" , { terrain = "A*,*^F*a,Ms,Ha" , { "not" , { terrain = "*^V*" }}}}}
		for index, unit in ipairs(frostbite_units) do
			local status = helper.get_child (unit.__cfg, "status")
			unit.status.frostbite = "true"
			unit.moves = math.floor(unit.max_moves / 2)
			wesnoth.float_label(unit.x, unit.y, "<span color='grey'>" .. "frostbite" .. "</span>")
		end
		if #frostbite_units > 0 then wesnoth.play_sound "entangle.wav" end
		local unfrostbite_units = wesnoth.get_units { side = side_number , { "filter_location" , { { "not" , { terrain = "A*,*^F*a,Ms,Ha" }}}}}
		for index, unit in ipairs(unfrostbite_units) do
			local status = helper.get_child (unit.__cfg, "status")
			if unit.status.frostbite then
				unit.status.frostbite = nil
				wesnoth.float_label(unit.x, unit.y, "<span color='green'>" .. _"healed" .. "</span>")
			end
		end
	end
end

--	Icon code by silene

local old_unit_status = wesnoth.theme_items.unit_status
function wesnoth.theme_items.unit_status()
	local u = wesnoth.get_displayed_unit()
	if not u then return {} end
	local s = old_unit_status()
	if u.status.frostbite then
		table.insert(s, { "element", {
		image = "statuses/status-frostbite.png",
		tooltip = _ "frostbite: This unit has been frostbitten, thus its movement points are reduced by half."
		} })
	end
	return s
end

function wml_actions.spawn_units(cfg)
	if cfg.fire_event then
		local side_two = wesnoth.get_units { side = 2 }
		if not side_two then side_two = 0 end
		local units_placed = #side_two
		local possible_locs = wesnoth.get_locations { x = 31-38 , y = 1-7 , { "filter" , { }}}
		
		if turn_number < 10 then number_of_units = 15
		elseif turn_number < 20 then number_of_units = 20
		elseif turn_number >= 21 then number_of_units = 30
		end
		
		while units_placed < number_of_units do
			local rand_index = helper.rand('1..' .. #possible_locs)
			wesnoth.put_unit(possible_locs[rand_index][1], possible_locs[rand_index][2], { type = helper.rand("Bowman,Javelineer,Longbowman,Mage,Pikeman,Red Mage,Spearman,Spearman,Swordsman,Swordsman") })
			table.remove(possible_locs, rand_index)
			units_placed = units_placed + 1
		end
		number_of_units = nil
	end
end