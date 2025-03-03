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
			local player = managers.player:player_unit()

			-- auto cook
			if chemical and alive(player) then
				for _, unit in pairs(managers.interaction._interactive_units) do
					local interaction = alive(unit) and unit.interaction and unit:interaction()
					if interaction and interaction.tweak_data == chemical then
						interaction.can_interact = function() return true end
						interaction:interact(player)
						interaction.can_interact = nil
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
				local interaction = alive(unit) and unit.interaction and unit:interaction()

				-- take the meth if not carrying bag
				if interaction and interaction.tweak_data == "taking_meth" and managers.player:player_unit() and not managers.player:is_carrying() then
					local player = managers.player:player_unit()
					local position = interaction:interact_position()
					local heist = Global.game_settings.level_id
					local forward = player:camera():forward()
					local rotation = Rotation(math.random(-180,180), math.random(-180,180), 0)
					local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
					local carry_data = tweak_data.carry.meth
					local spawn_meth_pos = Vector3(position.x + (heist == "alex_1" and -50 or 0), position.y, position.z + 10)
					interaction:interact(player)

					if Network:is_client() then
						managers.network:session():send_to_host("server_drop_carry", "meth", carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, spawn_meth_pos, rotation, forward, throw_force, nil)
					else
						managers.player:server_drop_carry("meth", carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, spawn_meth_pos, rotation, forward, throw_force, nil, managers.network:session():local_peer())
					end
					managers.player:clear_carry()
				end
			end)
		end
	else
		global_autocook_toggle = not global_autocook_toggle

		if global_autocook_toggle then
			managers.mission._fading_debug_output:script().log('Auto Cook - Activated',  Color.green)
		else
			managers.mission._fading_debug_output:script().log('Auto Cook - Deactivated',  Color.red)
		end
	end
elseif Global.game_settings and ( Global.game_settings.level_id == "crojob2" or Global.game_settings.level_id == "mia_1" ) and managers.interaction then -- for The Bomb: Dockyard and Hotline Miami
	global_current_cooking_phase = global_current_cooking_phase or 1
	local interactions = {'methlab_bubbling', 'methlab_caustic_cooler', 'methlab_gas_to_salt', "taking_meth"}
	for _, unit in pairs(managers.interaction._interactive_units) do
		if unit:interaction().tweak_data == interactions[global_current_cooking_phase] then
			if global_current_cooking_phase < 4 then
				managers.mission._fading_debug_output:script().log('Add Chemical: step ' .. tostring(global_current_cooking_phase) ,  Color.green)
				unit:interaction().can_interact = function() return true end
				unit:interaction():interact(managers.player:player_unit())
				unit:interaction().can_interact = nil
				global_current_cooking_phase = global_current_cooking_phase + 1
			elseif global_current_cooking_phase == 4 and not managers.player:is_carrying() then
				managers.mission._fading_debug_output:script().log('Pack Meth',  Color.green)
				unit:interaction():interact(managers.player:player_unit())
				global_current_cooking_phase = 1
			end
			break
		end
	end
end
