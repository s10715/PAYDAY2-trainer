local pack_corpse = false

local special_equipments = {"take_keys","stash_planks_pickup","gen_pku_saw","gen_pku_crowbar","c4_bag","hold_take_gas_can","gen_pku_thermite","gen_pku_blow_torch","take_confidential_folder","hold_take_blueprints","pickup_asset","press_printer_ink","press_printer_paper","stash_server_pickup","muriatic_acid","caustic_soda","hydrogen_chloride"}
local doors = {"invisible_interaction_open","cas_open_door","cas_security_door","cas_open_securityroom_door","open_door_with_keys","key","open_door","open_from_inside","zipline_mount","hold_open_window","cut_fence","cut_glass","mcm_break_planks","pick_lock_easy","pick_lock_easy_no_skill","pick_lock_hard","pick_lock_hard_no_skill","fake_pick_lock_easy_no_skill","chas_pick_lock_easy_no_skill","hold_open_vault","hold_open_vault_2s","pick_lock_deposit_transport","crate_loot","crate_loot_crowbar","open_train_cargo_door","timelock_panel","timelock_numpad","hold_open_the_safe","dah_panicroom_keycard","mcm_panicroom_keycard","mcm_panicroom_keycard_2","hold_open_xmas_present","vit_remove_painting","gen_pku_warhead_box","hold_open_shopping_bag","press_use_lrm_safe_keycard","trai_hold_picklock_toolsafe"}
local ecm_doors = {"requires_ecm_jammer","requires_ecm_jammer_atm","requires_ecm_jammer_double"} -- this interact need ECM
local small_loots = {"safe_loot_pickup","diamond_pickup","tiara_pickup","press_take_folder","money_wrap_single_bundle","mus_pku_artifact","weapon_case","cash_register","diamond_single_pickup_axis","take_pardons","pickup_tablet","pickup_phone","gage_assignment"}
local big_loots = {"trai_printing_plates_carry","diamond_pickup","red_diamond_pickup","diamonds_pickup_full","diamonds_pickup","shape_charge_plantable","gen_pku_cocaine_pure","money_small","money_scanner","money_luggage","money_bag","money_wrap","money_wrap_axis","hold_pku_drk_bomb_part","hold_take_server","weapon","ammo","painting","old_wine","ordinary_wine","drk_bomb_part","evidence_bag","coke","coke_pure","diamond_necklace","diamonds","artifact_statue","prototype","yayo","meth_half","samurai_armor","turret","roman_armor","samurai_suit","weapons","carry_drop","painting_carry_drop","gen_pku_jewelry","taking_meth","gen_pku_cocaine","take_weapons","gold_pile","hold_take_painting","invisible_interaction_open","gen_pku_artifact","gen_pku_artifact_statue","gen_pku_artifact_painting","gen_pku_warhead","hold_take_expensive_wine","hold_take_shoes","hold_take_diamond_necklace","hold_take_toy","hold_take_vr_headset","gen_pku_evidence_bag","hold_take_old_wine","corpse_dispose"}
local hacks_safe_in_stealth = {"corpse_alarm_pager","hospital_phone","vit_search","trai_connect_locke_walkietalkie","trai_hold_access_console","hack_electric_box","hold_disable_alarm","trai_hold_disable_alarm"}
local drills = {"drill","drill_upgrade","drill_jammed","hold_pickup_lance","lance","lance_upgrade","lance_jammed","gen_pku_lance_part","huge_lance","huge_lance_jammed","c4"}
local shaped_sharges = {"shaped_sharge","shape_charge_plantable"} -- this interact need shaped charges
local hacks_not_safe = {"born_plug_in_powercord","circuit_breaker","rewire_electric_box","place_flare","use_flare","gen_prop_container_a_vault_seq","start_hacking","hold_hack_comp","bus_wall_phone","security_station","security_station_keyboard","big_computer_server","big_computer_hackable","mcm_laptop","mcm_laptop_code","numpad","timelock_hack","hold_type_in_password","hack_ipad","hack_ipad_jammed","hack_suburbia_outline","votingmachine2","votingmachine2_jammed","place_harddrive","crane_joystick_left","crane_joystick_release","hold_moon_untie","open_slash_close_sec_box","hold_pull_switch","iphone_answer","use_computer","hold_use_computer","use_server_device","hold_blow_torch","hack_trai_outline","hack_ship_control"}

local function interactbytweak(interaction_table)
	-- local player = managers.player._players[1]
	local player_unit = managers.player and managers.player:player_unit()
	local state = managers.player and managers.player._current_state
	if not player_unit or not alive(player_unit) or state == "bleed_out" or state == "incapacitated" or state == "fatal" or state == "arrested" then
		return
	end

	local interactives = {}
	local tweaks = {}
	for _,arg in pairs(interaction_table) do
		tweaks[arg] = true
	end
	for key,unit in pairs(managers.interaction._interactive_units) do
		local interaction = unit and unit.interaction
		interaction = interaction and interaction(unit)
		if interaction and tweaks[interaction.tweak_data] then
			local can_do_interact = true
			-- use ECM and shaped charges interaction without having them equipped
			if interaction.tweak_data == "requires_ecm_jammer" or interaction.tweak_data == "requires_ecm_jammer_atm" or interaction.tweak_data == "requires_ecm_jammer_double" or interaction.tweak_data == "shaped_sharge" then
				unit:interaction()._tweak_data.required_deployable = nil
				unit:interaction()._tweak_data.deployable_consume = false
			end
			-- open door,timelock,panicroom,crate,and so on, without equipment, and not consume the equipment
			if unit:interaction()._tweak_data.special_equipment then unit:interaction()._tweak_data.special_equipment = nil end
			if unit:interaction()._tweak_data.equipment_consume then unit:interaction()._tweak_data.equipment_consume = false end
			-- TODO: hack computer without seeing them first

			-- answer pager need send to host first
			if interaction.tweak_data == "corpse_alarm_pager" and interaction._unit:key() and managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()) then
				local u_id = managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()).u_id
				managers.network:session():send_to_host("alarm_pager_interaction", u_id, interaction.tweak_data, 1) -- 1=start 2=interrupted, 3=complete
			end

			if not pack_corpse and interaction.tweak_data == "corpse_dispose" then
				can_do_interact = false
			end

			if can_do_interact then
				table.insert(interactives, interaction)
			end
		end
	end
	for _,i in pairs(interactives) do
		-- can't carry 2 bags at a time, need to drop first
		if managers.player:is_carrying() then
			-- managers.loot:secure(managers.player:current_carry_id(), managers.money:get_bag_value(managers.player:current_carry_id())) -- this will get money but won't remove the bag
			managers.player:drop_carry()
		end
		-- can't carry 2 possessions at a time, stop taking
		local if_stop_taking = false
		if i._tweak_data.special_equipment_block and managers.player._equipment.specials[i._tweak_data.special_equipment_block] then
			if_stop_taking = true
		end
		-- do interact
		if not if_stop_taking then
			local orig_can_interact = i.can_interact
			i.can_interact = function() return true end
			i:interact(player_unit)
			i.can_interact = orig_can_interact
		end
	end
	managers.player:drop_carry() -- drop the last bag
end

local function grabspecialequipments()
	-- interactbytweak("pickup_keycard") -- keycard is special, it can grab 2, but the other will disappear
	interactbytweak(special_equipments)
end
local function openalldoors()
	interactbytweak(doors)
	interactbytweak(ecm_doors) 
end
local function grabsmallloots()
	interactbytweak(small_loots)
end
local function graballbigloots()
	interactbytweak(big_loots)
end
local function hack_safe_in_stealth()
	interactbytweak(hacks_safe_in_stealth)
end
local function drillandhack_not_safe()
	interactbytweak(drills)
	interactbytweak(shaped_sharges)
	interactbytweak(hacks_not_safe)
end
local function grabeverything()
	grabspecialequipments()
	openalldoors()
	grabsmallloots()
	graballbigloots() -- bags will drop in front of you
	hack_safe_in_stealth()
	if not managers.groupai:state():whisper_mode() then
		-- drill and shaped sharge are not safe in stealth
		-- be careful of, this might hack the wrong thing
		drillandhack_not_safe()
	end
	managers.mission._fading_debug_output:script().log('Interact With Everything',  Color.yellow)
end
grabeverything()
