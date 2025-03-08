global_onehitkill_toggle = not global_onehitkill_toggle

function check_and_melee_kill(unit)
	if alive(unit) and global_onehitkill_toggle then
		unit:character_damage():damage_melee({
			damage = unit:character_damage()._HEALTH_INIT,
			attacker_unit = managers.player._players[1],
			attack_dir = Vector3(0,0,0),
			variant = "melee",
			name_id = 'cqc',
			col_ray = {position = unit:position(), body = unit:body("body")}
		})
	end
end

orig_damage_bullet = orig_damage_bullet or CopDamage.damage_bullet
function CopDamage.damage_bullet(self, attack_data, ...)
	check_and_melee_kill(self._unit)
	return orig_damage_bullet(self, attack_data, ...)
end

orig_damage_fire = orig_damage_fire or CopDamage.damage_fire
function CopDamage.damage_fire(self, attack_data, ...)
	check_and_melee_kill(self._unit)
	return orig_damage_fire(self, attack_data, ...)
end

orig_damage_explosion= orig_damage_explosion or CopDamage.damage_explosion
function CopDamage.damage_explosion(self, attack_data, ...)
	check_and_melee_kill(self._unit)
	return orig_damage_explosion(self, attack_data, ...)
end

orig_damage_melee = orig_damage_melee or CopDamage.damage_melee
function CopDamage.damage_melee(self, attack_data, ...)
	if global_onehitkill_toggle then attack_data.damage = attack_data.damage * math.huge end
	return orig_damage_melee(self, attack_data, ...)
end

if global_onehitkill_toggle then
	managers.mission._fading_debug_output:script().log('One Hit Kill - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('One Hit Kill - Deactivated',  Color.red)
end
