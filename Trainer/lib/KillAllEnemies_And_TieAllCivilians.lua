-- destroy cameras to prevent alarm on stealth
local function destroy_cameras()
	local function dmg_cam(unit)
		local body
		do
			local i = -1
			repeat
				i = i+1
				body = unit:body(i)
			until (body and body:extension()) or (i >= 5)
		end
		if not body then return end
		body:extension().damage:damage_melee(unit, nil, unit:position(), nil, 10000)
		managers.network:session():send_to_peers_synched("sync_body_damage_melee", body, unit, nil, unit:position(), nil, 10000)
	end

	for _,unit in pairs(SecurityCamera.cameras) do
		pcall(dmg_cam,unit)
	end
	managers.mission._fading_debug_output:script().log('Destroy All Cameras',  Color.yellow)
end
destroy_cameras()


-- Kill All Enemies And Steal Pager
local function kill_all_enemies()
	local Vector3 = Vector3
	local managers = managers
	local M_player = managers.player
	local M_enemy = managers.enemy

	local function dmg_melee(unit)
		if unit then
			local action_data = {
				damage = math.huge, --(Ultra * math.huge) damage.
				damage_effect = unit:character_damage()._HEALTH_INIT * 2,
				attacker_unit = M_player:player_unit(),
				attack_dir = Vector3(0,0,0),
				name_id = 'rambo', --Only in rambo style bulldosers can be killed
				col_ray = {
					position = unit:position(),
					body = unit:body( "body" ),
				}
			}
			unit:unit_data().has_alarm_pager = false
			unit:character_damage():damage_melee(action_data)
		end
	end

	for _,ud in pairs(M_enemy:all_enemies()) do
		pcall(dmg_melee,ud.unit)
	end
	managers.mission._fading_debug_output:script().log('Kill All Enemies',  Color.yellow)
end
-- steal pager is host only, if it's stealth, only kill guards when you are host
if managers.groupai:state():whisper_mode() and Network:is_server() then
	kill_all_enemies()
elseif not managers.groupai:state():whisper_mode() then
	kill_all_enemies()
end


-- Tie All Civilians
function tie_all()
	local managers = managers
	local M_player = managers.player
	local M_enemy = managers.enemy
	local HUGE = math.huge
	local pairs = pairs

	local player = M_player:player_unit()
	local all_civilians = M_enemy:all_civilians()

	for u_key, u_data in pairs( all_civilians ) do	
		local unit = u_data.unit
		local brain = unit:brain()
		if not brain:is_tied() then
			local action_data = { type = "act", body_part = 1, clamp_to_graph = true, variant = "halt" }
			brain:action_request( action_data )
			brain._current_logic.on_intimidated( brain._logic_data, HUGE, player, true )
			brain:on_tied( player )
		end
	end
	managers.mission._fading_debug_output:script().log('Tie All Civilians',  Color.yellow)
end
tie_all()
