global_dropbagonebyone_toggle = not global_dropbagonebyone_toggle

local function drop_bag_one_by_one()
	DelayedCalls:Add("drop_bag_one_by_one", 0.2, function()
		local local_player = managers.player and managers.player:local_player()
		if not global_dropbagonebyone_toggle or not local_player or not alive(local_player) then return end

		for key,unit in pairs(managers.interaction._interactive_units) do
			local interaction = unit and unit.interaction and unit.interaction(unit)
			if interaction and interaction.tweak_data == "carry_drop" or interaction.tweak_data == "painting_carry_drop" then
				managers.player:drop_carry()
				interaction:interact(local_player)
				managers.player:drop_carry()
				break
			end
		end
		drop_bag_one_by_one()
	end)
end
drop_bag_one_by_one()

if global_dropbagonebyone_toggle then
	managers.mission._fading_debug_output:script().log('Drop Bag One By One - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Drop Bag One By One - Deactivated',  Color.red)
end
