global_dmg_reflect_toggle = not global_dmg_reflect_toggle 

local reflection_damage =  20	--higher = higher unit dmg%
local reflection_damage_special = 38	--higher = higher unit dmg%
local unit_reflection_damage = nil
local unit_table = {"spooc","taser","cloaker","shield","tank","tank_mini","tank_medic","tank_hw","piggydozer","sniper","heavy_swat_sniper","gangster","cop","cop_female","security","medic","gensec","swat","heavy_swat","zeal_swat","zeal_heavy_swat","fbi","fbi_swat","fbi_heavy_swat","marshal_marksman","marshal_shield","city_swat","mobster_boss","mobster","hector_boss","hector_boss_no_armor","biker_boss","chavez_boss","biker","bolivian","bolivian_indoors_mex","bolivians","phalanx_vip","phalanx_minion","shadow_spooc","drug_lord_boss","drug_lord_boss_stealth","drunk_pilot","spa_vip","spa_vip_hurt","captain","captain_female","civilian_mariachi","mute_security_undominatable","security_undominatable","escort","escort_criminal","escort_undercover","triad","triad_boss","deep_boss","snowman_boss","biker_escape"}

function reflect_damage(attack_data)
	local attacker_unit = attack_data.attacker_unit
	local attacker_unit_dmg = attack_data.damage
	if not (attacker_unit or alive(attacker_unit) or attacker_unit_dmg) then
		return
	end
	local unit_damage = attacker_unit:character_damage()
	local all_enemies = managers.enemy:all_enemies()
	for _,data in pairs(all_enemies) do
		local unit = data.unit
		if unit and alive(unit) and (attacker_unit == unit) then
			local enemy = unit:base()._tweak_table
			for _,v in pairs(unit_table) do
				if (v == enemy) then
					if tweak_data.character[enemy] and tweak_data.character[enemy].tags and tweak_data.character[enemy].tags[3] and (tweak_data.character[enemy].tags[3] == "special") then
						unit_reflection_damage = (attacker_unit_dmg * reflection_damage_special) / 100
					else
						unit_reflection_damage = (attacker_unit_dmg * reflection_damage) / 100
					end
					local action_data = {
						damage = unit_reflection_damage,
						attacker_unit = managers.player:player_unit(),
						attack_dir = Vector3(0,0,0),
						variant = "melee", 
						name_id = 'cqc',
						col_ray = {
							position = unit:position(),
							body = unit:body("body"),
						}
					}
					unit_damage:damage_melee(action_data)
					if not alive(attacker_unit) then
						managers.network:session():send_to_peers_synched("remove_unit", unit)
					end
					break
				end
			end
		end
	end
end

local orig_damage_bullet = PlayerDamage.damage_bullet
function PlayerDamage.damage_bullet(self, attack_data)
	if global_dmg_reflect_toggle then	
		reflect_damage(attack_data)
	else
		orig_damage_bullet(self, attack_data)
	end
end

if global_dmg_reflect_toggle then
	managers.mission._fading_debug_output:script().log('Reflect Enemy Damage - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Reflect Enemy Damage - Deactivated',  Color.red)
end
