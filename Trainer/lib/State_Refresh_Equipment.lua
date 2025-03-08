
if alive(managers.player:player_unit()) then
	--health, ammo
	managers.player:player_unit():base():replenish()
	--player state
	managers.player:set_player_state('standard')
	--body bags
	managers.player:add_body_bags_amount(3)
	--cable tie
	if (managers.player._global.synced_cable_ties[managers.network:session():local_peer():id()].amount < 5) then
		managers.player:add_special({name = "cable_tie", silent = true, amount = 1})
	end
	if managers.hud then
		--granade amount
		managers.player:add_grenade_amount(3)
		--deployable
		-- won't give you deployable unless you are the host
		if Network:is_server() then
			managers.player:clear_equipment()
			managers.player._equipment.selections = {}
			managers.player:add_equipment({silent = true, equipment = managers.player:equipment_in_slot(1), slot = 1})
			if managers.player:has_category_upgrade("player", "second_deployable") then
				managers.player:add_equipment({silent = true, equipment = managers.player:equipment_in_slot(2), slot = 2})
			end
		end
	end
	managers.mission._fading_debug_output:script().log('Refresh Equipment',  Color.yellow)
end