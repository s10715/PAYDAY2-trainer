-- host only
if not Network:is_server() then
	return
end


if not managers.player:player_unit() then
	return
end

local from = managers.player:player_unit():movement():m_head_pos()
local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
if ray then
	local pos = ray.position
	local rot = managers.player:player_unit():rotation()

	-- first aid kit
	World:spawn_unit(Idstring("units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit"), pos, rot)

	-- body bag
	-- BodyBagsBagBase.spawn(pos, rot)

	-- grenade case
	-- World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate"), pos, rot)

	-- flash grenades
	-- managers.network:session():send_to_peers_synched("sync_smoke_grenade", pos, rot, 1, true)
	-- managers.groupai:state():sync_smoke_grenade(pos, rot, 1, true)
end
managers.mission._fading_debug_output:script().log('Spawn First Aid', Color.yellow)
