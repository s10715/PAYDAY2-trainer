local special_equipments = {"take_keys","gen_pku_saw","gen_pku_crowbar","c4_bag","hold_take_gas_can","gen_pku_thermite","gen_pku_blow_torch","take_confidential_folder","hold_take_blueprints","pickup_asset","press_printer_ink","press_printer_paper"}
local doors = {"invisible_interaction_open","cas_open_door","cas_security_door","cas_open_securityroom_door","open_door_with_keys","open_door","open_from_inside","zipline_mount","hold_open_window","cut_fence","cut_glass","mcm_break_planks","pick_lock_easy","pick_lock_easy_no_skill","pick_lock_hard","pick_lock_hard_no_skill","hold_open_vault","pick_lock_deposit_transport","crate_loot","crate_loot_crowbar","open_train_cargo_door","timelock_panel","timelock_numpad","hold_open_the_safe","dah_panicroom_keycard","mcm_panicroom_keycard","mcm_panicroom_keycard_2","hold_open_xmas_present","vit_remove_painting","gen_pku_warhead_box","press_use_lrm_safe_keycard"}
local ecm_doors = {"requires_ecm_jammer","requires_ecm_jammer_atm","requires_ecm_jammer_double"} -- this interact need ECM
local small_loots = {"safe_loot_pickup","diamond_pickup","tiara_pickup","money_wrap_single_bundle","mus_pku_artifact","weapon_case","cash_register","diamond_single_pickup_axis","take_pardons","gage_assignment"}
local big_loots = {"trai_printing_plates_carry","diamond_pickup","red_diamond_pickup","diamonds_pickup_full","diamonds_pickup","shape_charge_plantable","gen_pku_cocaine_pure","money_small","money_scanner","money_luggage","money_wrap","money_bag","hold_pku_drk_bomb_part","hold_take_server","weapon","ammo","painting","old_wine","ordinary_wine","drk_bomb_part","evidence_bag","coke","coke_pure","diamond_necklace","diamonds","artifact_statue","prototype","yayo","meth_half","samurai_armor","turret","roman_armor","samurai_suit","weapons","carry_drop","painting_carry_drop","money_wrap","gen_pku_jewelry","taking_meth","gen_pku_cocaine","take_weapons","gold_pile","hold_take_painting","invisible_interaction_open","gen_pku_artifact","gen_pku_artifact_statue","gen_pku_artifact_painting","gen_pku_warhead"}
local pagers = {"corpse_alarm_pager"}
local corpses = {"corpse_dispose"}
local drills = {"drill","drill_upgrade","drill_jammed","hold_pickup_lance","lance","lance_upgrade","lance_jammed","gen_pku_lance_part","huge_lance","huge_lance_jammed","c4"}
local shaped_sharges = {"shaped_sharge"} -- this interact need shaped charges
local hacks = {"born_plug_in_powercord","circuit_breaker","rewire_electric_box","hospital_phone","gen_prop_container_a_vault_seq","vit_search","start_hacking","hold_hack_comp","bus_wall_phone","security_station","security_station_keyboard","big_computer_server","big_computer_hackable","mcm_laptop","mcm_laptop_code","numpad","timelock_hack","hold_type_in_password","hack_ipad","hack_ipad_jammed","hack_suburbia_outline","votingmachine2","votingmachine2_jammed","place_harddrive","crane_joystick_left","crane_joystick_release"}

function interactbytweak(interaction_table)
	local player = managers.player._players[1]
	if not player then
		return
	end
	local interactives = {}
	local tweaks = {}
	for _,arg in pairs(interaction_table) do
		tweaks[arg] = true
	end
	for key,unit in pairs(managers.interaction._interactive_units) do
		local interaction = unit.interaction
		interaction = interaction and interaction(unit)
		if interaction and tweaks[interaction.tweak_data] then
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
			if interaction.tweak_data == "corpse_alarm_pager" then
				local u_id = managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()).u_id
				managers.network:session():send_to_host("alarm_pager_interaction", u_id, interaction.tweak_data, 1) -- 1=start 2=interrupted, 3=complete
			end

			table.insert(interactives, interaction)
		end
	end
	for _,i in pairs(interactives) do
		-- can't carry 2 bags at a time, need to drop first
		if managers.player:is_carrying() then
			managers.player:drop_carry()
		end
		-- can't carry 2 possessions at a time, stop taking
		local if_stop_taking = false
		if i._tweak_data.special_equipment_block and managers.player._equipment.specials[i._tweak_data.special_equipment_block] then
			if_stop_taking = true
		end
		-- do interact
		if not if_stop_taking then
			i:interact(player)
		end
	end
	managers.player:drop_carry() -- drop the last bag
end

function grabspecialequipments()
	-- interactbytweak("pickup_keycard") -- keycard is special, it can grab 2, but the other will disappear
	interactbytweak(special_equipments)
end
function openalldoors()
	interactbytweak(doors)
	interactbytweak(ecm_doors) 
end
function grabsmallloots()
	interactbytweak(small_loots)
end
function graballbigloots()
	interactbytweak(big_loots)
end
function pagersandcorpses()
	interactbytweak(pagers)
	interactbytweak(corpses)
end
function drillandhack()
	interactbytweak(drills)
	interactbytweak(shaped_sharges)
	interactbytweak(hacks)
end
function grabeverything()
	grabspecialequipments()
	openalldoors()
	grabsmallloots()
	graballbigloots() -- bags will drop in front of you
	if managers.groupai:state():whisper_mode() then
		-- only need to answer pagers and pack corpses in stealth
		pagersandcorpses()
	else
		-- drill and shaped sharge are not safe in stealth
		-- be careful of, this might hack the wrong thing
		drillandhack()
	end
	managers.mission._fading_debug_output:script().log('Interact With Everything',  Color.yellow)
end
grabeverything()
