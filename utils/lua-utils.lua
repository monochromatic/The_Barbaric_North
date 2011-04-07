--	#textdomain wesnoth-The_Barbaric_North
--	
--	Lua snippets for The Barbaric North

local _ = wesnoth.textdomain "wesnoth-The_Barbaric_North"

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
	if fire_event then
		local current_side = wesnoth.get_variable("side_number")
		local frostbite_units = wesnoth.get_units { side = current_side , { "not" , { id = "Buggles" }} , { "filter_location" , { terrain = "A*,*^F*a,Ms,Ha" , { "not" , { terrain = "*^V*" }}}}}
		for index, unit in ipairs(frostbite_units) do
			frostbite_units.status.frostbite = "true"
			frostbite_units.moves = math.floor(frostbite_units.max_moves / 2)
			wesnoth.float_label(unit.x, unit.y, "<span color='grey'>" .. "frostbite" .. "</span>")
			units_with_frostbite = yes
		end
		if units_with_frostbite then wesnoth.play_sound "entangle.wav" ; units_with_frostbite = nil end
		local unfrostbite_units = wesnoth.get_units { side = current_side , { "filter_location" , { "not" , { terrain = "A*,*^F*a,Ms,Ha" }}}}
		for index, unit in ipair(unfrostbite_units) do
			if unfrostbite_units.status.frostbite then
				unfrostbite_units.status.frostbite = nil
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
