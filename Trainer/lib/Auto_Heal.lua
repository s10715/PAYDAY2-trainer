global_autofirstaid_toggle = not global_autofirstaid_toggle

-- auto heal
orig__check_bleed_out = orig__check_bleed_out or PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(...)
	if global_autofirstaid_toggle and self:get_real_health() == 0 then 
		self:band_aid_health()
	end
	return orig__check_bleed_out(self, ...)
end

-- auto counter cloaker's SPOOC
orig_on_SPOOCed = orig_on_SPOOCed or PlayerMovement.on_SPOOCed
function PlayerMovement:on_SPOOCed(enemy_unit)
	if global_autofirstaid_toggle then
		return "countered"
	else
		orig_on_SPOOCed(self, enemy_unit)
	end
end

-- cloaker's kick no longer force your camera to face them
orig_clbk_aim_assist = orig_clbk_aim_assist or FPCameraPlayerBase.clbk_aim_assist
function FPCameraPlayerBase:clbk_aim_assist(col_ray)
	if global_autofirstaid_toggle then
		if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("aim_assist") then
			self:_start_aim_assist(col_ray, self._aim_assist)
		end
	else
		orig_clbk_aim_assist(self, col_ray)
	end
end

-- taser won't taze you, host only
orig_is_taser_attack_allowed = orig_is_taser_attack_allowed or PlayerMovement.is_taser_attack_allowed
function PlayerMovement:is_taser_attack_allowed()
	if global_autofirstaid_toggle then
		return false
	else
		orig_is_taser_attack_allowed(self)
	end
end


if global_autofirstaid_toggle then
	managers.mission._fading_debug_output:script().log('Auto Heal - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Auto Heal - Deactivated',  Color.red)
end
