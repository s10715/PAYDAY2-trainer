global_meleesaw_toggle = not global_meleesaw_toggle

-- use saw to open lock at melee hit position
local function use_saw()
	local player_unit = managers.player:player_unit()
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = player_unit:movement():m_head_pos()
	local to = from + player_unit:movement():m_head_rot():y() * range
	local raytrace = player_unit:raycast("ray", from, to, "slot_mask", InstantBulletBase:bullet_slotmask(), "ignore_unit", {}, "ray_type", "body bullet lock")
	if raytrace then
		local damage = 200
		local hit_unit = raytrace.unit
		if hit_unit and hit_unit:damage() and raytrace.body:extension() and raytrace.body:extension().damage then
			-- apply saw usage at melee hit position
			raytrace.body:extension().damage:damage_lock(player_unit, raytrace.normal, raytrace.position, raytrace.direction, damage)
			-- sync to peers
			if hit_unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_lock", raytrace.body, damage)
			end
			if true then
				--spawn the fancy sawing particles
				local effect = World:effect_manager():spawn({
					effect = Idstring("effects/payday2/particles/weapons/saw/sawing"),
					position = raytrace.hit_position,
					normal = math.UP
				})
				--make the fancy sawing particles sod off
				DelayedCalls:Add("ParticleKill", 0.1, function() World:effect_manager():fade_kill(effect) end)
			end
		end
	end
end

orig__do_action_melee = orig__do_action_melee or PlayerStandard._do_action_melee
function PlayerStandard:_do_action_melee(...)
	if global_meleesaw_toggle then
		use_saw()
	end
	orig__do_action_melee(self, ...)
end

if global_meleesaw_toggle then
	managers.mission._fading_debug_output:script().log('Melee Saw - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Melee Saw - Deactivated',  Color.red)
end
