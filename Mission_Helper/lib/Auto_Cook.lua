local function toggle_autocook()
	global_autocook_toggle = not global_autocook_toggle

	if global_autocook_toggle then
		if managers and managers.mission then managers.mission._fading_debug_output:script().log('Auto Cook - Activated',  Color.green) end
	else
		if managers and managers.mission then managers.mission._fading_debug_output:script().log('Auto Cook - Deactivated',  Color.red) end
	end
end

local function drop_bag_at_position(position)
	if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
		local forward = Vector3(0, 0, 0) -- managers.player:player_unit():camera():forward()
		local rotation = Rotation(math.random(-180,180), math.random(-180,180), 0)
		local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
		local carry_data = managers.player:get_my_carry_data()
		if Network:is_client() then
			managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil)
		else
			managers.player:server_drop_carry(carry_data.carry_id,carry_data.multiplier, carry_data.dye_initiated,carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil, managers.network:session():local_peer())
		end
		managers.player:clear_carry()
		managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
		managers.hud:temp_hide_carry_bag()
		managers.player:update_removed_synced_carry_to_peers()
	end
end


if Global.game_settings and ( Global.game_settings.level_id == "rat" or Global.game_settings.level_id == "alex_1" ) then
	if RequiredScript == "lib/managers/dialogmanager" then
		local orig_queue_dialog = DialogManager.queue_dialog
		function DialogManager:queue_dialog(id, ...)
			if not global_autocook_toggle then return orig_queue_dialog(self, id, ...) end

			local needed_chem = {
				pln_rt1_20 = "methlab_bubbling", pln_rt1_22 = "methlab_caustic_cooler", pln_rt1_24 = "methlab_gas_to_salt",
				Play_loc_mex_cook_03="methlab_bubbling", Play_loc_mex_cook_04="methlab_caustic_cooler", Play_loc_mex_cook_05="methlab_gas_to_salt"
			}
			local chemical = needed_chem[id]

			-- auto cook
			if chemical and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
				for _, unit in pairs(managers.interaction._interactive_units) do
					local interaction = unit and unit.interaction and unit.interaction(unit)
					if interaction and interaction.tweak_data == chemical then
						interaction.can_interact = function() return true end
						interaction:interact(managers.player:player_unit())
						interaction.can_interact = nil
						managers.mission._fading_debug_output:script().log('Add ' .. chemical ,  Color.yellow)
						return
					end
				end
			end

			return orig_queue_dialog(self, id, ...)
		end
	elseif RequiredScript == "lib/managers/objectinteractionmanager" then
		local orig_add_unit = ObjectInteractionManager.add_unit
		function ObjectInteractionManager:add_unit(unit, ...)
			if not global_autocook_toggle then return orig_add_unit(self, unit, ...) end

			orig_add_unit(self, unit, ...)

			DelayedCalls:Add("autocooker " .. tostring(unit), 0.2, function()
				local interaction = unit and alive(unit) and unit.interaction and unit.interaction(unit)

				-- take the meth if not carrying bag
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "taking_meth" and not managers.player:is_carrying() then
					managers.mission._fading_debug_output:script().log('Bag Meth',  Color.yellow)
					interaction:interact(managers.player:player_unit())
					local heist = Global.level_data and Global.level_data.level_id
					local position = interaction:interact_position()
					local spawn_meth_pos = Vector3(position.x + (heist == "alex_1" and -50 or 0), position.y, position.z + 10)
					drop_bag_at_position(spawn_meth_pos)
				end
			end)
		end
	else
		local function keep_light_and_flare()
			DelayedCalls:Add("keep_lights_on", 1.5, function()
				if not global_autocook_toggle then
					return
				end
				for _, unit in pairs(managers.interaction._interactive_units) do
					local interaction = unit and unit.interaction and unit.interaction(unit)
					if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "circuit_breaker" then
						interaction:interact(managers.player:player_unit())
						managers.mission._fading_debug_output:script().log('Turn Light On' ,  Color.yellow)
					elseif managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == "place_flare" then
						interaction:interact(managers.player:player_unit())
						managers.mission._fading_debug_output:script().log('Place Flare' ,  Color.yellow)
					end
				end
				keep_light_and_flare()
			end)
		end
		toggle_autocook()
		keep_light_and_flare()
	end

elseif Global.game_settings and ( Global.game_settings.level_id == "crojob2" or Global.game_settings.level_id == "mia_1" ) and managers.interaction then -- for The Bomb: Dockyard and Hotline Miami
	local function check_and_cook_next()
		DelayedCalls:Add("check_and_cook_next", 1.5, function()
			if not global_autocook_toggle then
				return
			end
			global_current_cooking_phase = global_current_cooking_phase or 1
			local interactions = {'methlab_bubbling', 'methlab_caustic_cooler', 'methlab_gas_to_salt', "taking_meth"}
			for _, unit in pairs(managers.interaction._interactive_units) do
				local interaction = unit and unit.interaction and unit.interaction(unit)
				if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and interaction and interaction.tweak_data == interactions[global_current_cooking_phase] then
					if global_current_cooking_phase < 4 then
						managers.mission._fading_debug_output:script().log('Add Chemical: step ' .. tostring(global_current_cooking_phase) ,  Color.yellow)
						interaction.can_interact = function() return true end
						interaction:interact(managers.player:player_unit())
						interaction.can_interact = nil
						global_current_cooking_phase = global_current_cooking_phase + 1
					elseif global_current_cooking_phase == 4 and not managers.player:is_carrying() then
						managers.mission._fading_debug_output:script().log('Bag Meth',  Color.yellow)
						interaction:interact(managers.player:player_unit())
						local position = interaction:interact_position()
						local spawn_meth_pos = Vector3(position.x, position.y, position.z + 10)
						drop_bag_at_position(spawn_meth_pos)
						global_current_cooking_phase = 1
					end
					break
				end
			end
			check_and_cook_next()
		end)
	end
	toggle_autocook()
	check_and_cook_next()

elseif Global.game_settings and ( Global.game_settings.level_id == "cane" ) then
	local elves = {	["4b02693553a926c3"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_1/civ_male_helper_1
					["28f247256e821a74"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_2/civ_male_helper_2
					["23bb5d4857a1a16c"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_3/civ_male_helper_3
					["871dae12e3cddbd8"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_4/civ_male_helper_4
	}
	local function check_shout_and_bag()
		DelayedCalls:Add("check_shout_and_bag", 1.5, function()
			if not global_autocook_toggle then
				return
			end

			local local_player = managers.player and managers.player:local_player()

			-- auto shout elves
			for _,unit in pairs(World:find_units_quick("all", 21)) do
				if unit and unit.name and unit:name().key and elves[unit:name():key()] and unit.anim_data and not unit:anim_data().unintimidateable then
					if local_player and alive(local_player) then
						if Network:is_client() then
							for i=1,5 do unit:network():send_to_host("long_dis_interaction", math.huge, local_player) end
						else
							unit:brain():on_intimidated(tweak_data.player.long_dis_interaction.intimidate_strength or 0.5, local_player, true)
						end
						managers.mission._fading_debug_output:script().log('Intimidate Elves',  Color.yellow)
					end
				end
			end

			-- auto bag presents, bag one by one, carry too many bags in short time might detect as cheater cause of lag
			for _,unit in pairs(managers.interaction._interactive_units) do
				local interaction = unit and unit.interaction and unit.interaction(unit)
				if interaction and interaction.tweak_data == "hold_pku_present" and interaction._active and managers.player and not managers.player:is_carrying() then
					if local_player and alive(local_player) then
						managers.mission._fading_debug_output:script().log('Bag Meth',  Color.yellow)
						interaction:interact(local_player)
						local position = interaction:interact_position()
						local spawn_meth_pos = Vector3(position.x, position.y, position.z + 10)
						drop_bag_at_position(spawn_meth_pos)
						break
					end
				end
			end
			check_shout_and_bag()
		end)
	end
	toggle_autocook()
	check_shout_and_bag()
end
