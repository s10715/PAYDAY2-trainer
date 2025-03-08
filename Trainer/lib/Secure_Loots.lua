-- if the map have secure area but none of them activated, then drop the bag at the last secure area

local get_all_secure_area = function()
	local invalid = { -- bag despawn areas
		['rat'] = { [102299] = true },
		['crojob2'] = { [105173] = true },
		['framing_frame_1'] = { [104285] = true, [104286] = true, [101046] = true, [101052] = true, [101820] = true, [101920] = true, [101931] = true } -- prevent bag touch laser
	}
	local custom_position = {
		['trai'] = { Vector3(-3432, 6910, 446.987) },
		['framing_frame_1'] = { Vector3(1154, -4298, 222) }, -- 100667, set higher priority
		['cane'] = { Vector3(-3293, -736, -18), Vector3(7830, -980, -19.28) }
	}

	local level = managers.job:current_level_id()
	local positions = {}
	-- add custom secure area
	for _,position in pairs(custom_position[level] or {}) do
		table.insert(positions, position)
	end
	-- find secure area
	for _, script in pairs(managers.mission._scripts) do
		for _, element in pairs(script._elements) do
			local values = element._values
			if ((values.instigator == "loot") or (values.instigator == "unique_loot")) and values.position and (not (invalid[level] and invalid[level][element:id()])) then
				if element._values.enabled then
					table.insert(positions, element._values.position)
					-- managers.chat:_receive_message(1, "debug", "job_id=" .. tostring(level) .. " ,element_id=" .. tostring(element:id()) .. " ,position=" .. tostring(element._values.position), Color.green)
				end
			end
		end
	end
	return positions
end

local drop_bag_at_position = function(position)
	if not managers or not managers.player or not managers.player:player_unit() then return end

	local carry_data = managers.player:get_my_carry_data()
	local player_cam = managers.player:player_unit():camera()
	local rotation = player_cam:rotation()
	local forward = Vector3(0,0,0)
	if carry_data then
		if Network:is_server() then
			managers.player:server_drop_carry(carry_data.carry_id,carry_data.multiplier, carry_data.dye_initiated,carry_data.has_dye_pack, carry_data.dye_value_multiplier,position, rotation, forward, 1, nil,managers.network:session():local_peer())
		else
			managers.network:session():send_to_host("server_drop_carry",carry_data.carry_id, carry_data.multiplier,carry_data.dye_initiated, carry_data.has_dye_pack,carry_data.dye_value_multiplier,position, rotation, forward, 1, nil)
		end

		managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
		managers.hud:temp_hide_carry_bag()
		managers.player:update_removed_synced_carry_to_peers()
		managers.player:set_player_state("standard")

		-- if the map have despawn areas, then the last appear position is despawn areas
		-- managers.chat:_receive_message(1, "debug", "position=" .. tostring(position) .. " ,rotation=" .. tostring(rotation) .. " ,forward=" .. tostring(forward), Color.green)
	end
end

function secure_loots(is_show_hint)
	if not BaseNetworkHandler or not managers or not managers.player then return end

	local player_unit = managers.player:player_unit()
	local state = managers.player._current_state
	if not player_unit or not alive(player_unit) or state == "bleed_out" or state == "incapacitated" or state == "fatal" or state == "arrested" then
		return
	end

	if managers.player:is_carrying() then
		managers.player:drop_carry()
	end

	local positions = get_all_secure_area()
	local delay = 0.1
	for _,position in pairs(positions) do
		-- drop bag have delay, need to wait for the animation
		DelayedCalls:Add( "drop_bag" .. tostring(delay), delay, function()
			for _,unit in pairs(managers.interaction._interactive_units) do
				local interaction = unit and unit.interaction
				interaction = interaction and interaction(unit)
				if interaction and (interaction.tweak_data == "carry_drop" or interaction.tweak_data == "painting_carry_drop") then
					interaction:interact(managers.player:player_unit())
					drop_bag_at_position(position)
				end
			end
		end)
		delay = delay + 0.25
	end

	if is_show_hint then
		if #positions == 0 then
			managers.mission._fading_debug_output:script().log('Secure Loots: no secure area',  Color.yellow)
		else
			managers.mission._fading_debug_output:script().log('Secure Loots: success',  Color.yellow)
		end
	end
end


-- in case delay is too high, try few times
local delay = 0.1
for i=1,5 do
	DelayedCalls:Add( "try_drop_bag" .. tostring(delay), delay, function()
		if i == 1 then
			secure_loots(true)
		else
			secure_loots(false)
		end
	end)
	delay = delay + 2
end
