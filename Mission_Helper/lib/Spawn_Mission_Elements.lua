-- Activates Overdrill even if you are not the host. It can spawn other mission elements too, like chopper with guards in shadow raid
-- @unkounusername7
-- https://www.unknowncheats.me/forum/payday-2-a/679479-overdrill-activator-host.html


local function trigger_mission_elements(elem_ids)
	if not managers and managers.mission then return end
	for _, data in pairs(managers.mission._scripts) do
		for id, element in pairs(data:elements()) do
			for _, elem_id in pairs(elem_ids) do
				if id == elem_id then
					if Network:is_server() then
						element:on_executed()
					else
						managers.network:session():send_to_host("to_server_mission_element_trigger", element:id(), managers.player:player_unit())
					end
					return true
				end
			end
		end
	end
end

-- only activate overvault
local function overdrill_activator_non_host()
	if Global.level_data and Global.level_data.level_id == "red2" then
		local overdrill = {103974}
		if trigger_mission_elements(overdrill) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Overdrill", Color.green)
		end
	end
end

-- open overvault
local function overdrill_open_vault_non_host()
	if Global.level_data and Global.level_data.level_id == "red2" then
		local overdrill = {
			103974,
			104136,		-- show the overvault gate and drill intercation.
			104194,
			104181,		-- 'func_sequence_trigger_088' loads the overvault itself and open the drilled gate.
			104193,
			104303,
			104189,		-- 'dasistcorrectsir' disables the floor button interactions and open the overvault door
			104326		-- 'trigger_area_110' enables the interaction for the 70 gold bars and gives the overdrill achievement to all players that have been there from start of the heist.
			}
		if trigger_mission_elements(overdrill) and managers.chat then
			managers.chat:_receive_message(1, "Opened", "Overvault", Color.green)
		end
	end
end

local function chopper_with_guards_shadow_raid()
	if Global.level_data and Global.level_data.level_id == "kosugi" then
		local chopper = {100303}
		if trigger_mission_elements(chopper) and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Shadow Raid Chopper", Color.green)
		end
	end
end

overdrill_activator_non_host()
overdrill_open_vault_non_host()
chopper_with_guards_shadow_raid()
