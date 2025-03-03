global_autoheal_toggle = not global_autoheal_toggle

-- auto heal
orig__check_bleed_out = orig__check_bleed_out or PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(...)
	if global_autoheal_toggle and self:get_real_health() == 0 then 
		if managers.player and managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") then
			-- set health to 1% if you have berserker skill
			self:change_health(self:_max_health() * self._healing_reduction / 100)
			-- start regenerate armor process
			-- self:_on_damage_event()
		else
			-- or else fully health yourself
			self:band_aid_health()
		end
	end
	return orig__check_bleed_out(self, ...)
end

-- remove screen shake effect when get hit
orig_play_shaker = orig_play_shaker or PlayerCamera.play_shaker
function PlayerCamera:play_shaker(effect, amplitude, frequency, offset)
	if global_autoheal_toggle then
		return
	else
		orig_play_shaker(self, effect, amplitude, frequency, offset)
	end
end

-- removes grey screen when you are on your last down
orig_set_post_composite = orig_set_post_composite or CoreEnvironmentControllerManager.set_post_composite
function CoreEnvironmentControllerManager:set_post_composite(t, dt)
	if global_autoheal_toggle then
		self._last_life = false
	end
	orig_set_post_composite(self, t, dt)
end

-- remove criminal concussion grenades tinnitus effcet
orig_on_concussion = orig_on_concussion or PlayerDamage.on_concussion
function PlayerDamage:on_concussion(mul, skip_disoriented_sfx, duration_tweak)
	if global_autoheal_toggle then
		return
	else
		orig_on_concussion(self, mul, skip_disoriented_sfx, duration_tweak)
	end
end

-- remove cop flashbang tinnitus effcet
orig_on_flashbanged = orig_on_flashbanged or PlayerDamage.on_flashbanged
function PlayerDamage:on_flashbanged(sound_eff_mul, skip_explosion_sfx)
	if global_autoheal_toggle then
		return
	else
		orig_on_flashbanged(self, sound_eff_mul, skip_explosion_sfx)
	end
end

-- auto counter cloaker's SPOOC
orig_on_SPOOCed = orig_on_SPOOCed or PlayerMovement.on_SPOOCed
function PlayerMovement:on_SPOOCed(enemy_unit)
	if global_autoheal_toggle then
		return "countered"
	else
		orig_on_SPOOCed(self, enemy_unit)
	end
end

-- cloaker's SPOOC no longer force your camera to face them
orig_clbk_aim_assist = orig_clbk_aim_assist or FPCameraPlayerBase.clbk_aim_assist
function FPCameraPlayerBase:clbk_aim_assist(col_ray)
	if global_autoheal_toggle then
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
	if global_autoheal_toggle then
		return false
	else
		orig_is_taser_attack_allowed(self)
	end
end


if global_autoheal_toggle then
	managers.mission._fading_debug_output:script().log('Auto Heal - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Auto Heal - Deactivated',  Color.red)
end
