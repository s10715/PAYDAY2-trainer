global_instantinteract_toggle = not global_instantinteract_toggle

orig_selected_equipment_deploy_timer = orig_selected_equipment_deploy_timer or PlayerManager.selected_equipment_deploy_timer
orig__get_timer = orig__get_timer or BaseInteractionExt._get_timer
orig__check_use_item = orig__check_use_item or PlayerStandard._check_use_item
orig__action_interact_forbidden = orig__action_interact_forbidden or PlayerStandard._action_interact_forbidden
orig_carry_blocked_by_cooldown = orig_carry_blocked_by_cooldown or PlayerManager.carry_blocked_by_cooldown

if global_instantinteract_toggle then
	-- Instant deploy
	function PlayerManager:selected_equipment_deploy_timer(...) return 0 end

	-- Instant interaction (except pagers because it's host only)
	function BaseInteractionExt:_get_timer(...)
		if self.tweak_data == "corpse_alarm_pager" then
			if Network:is_server() then
				return 0
			else
				return orig__get_timer(...)
			end
		end
		return 0
	end

	-- no drop bag cooldown
	function PlayerStandard:_check_use_item(t, input)
		if input.btn_use_item_release and self._throw_time and t and t < self._throw_time then
			managers.player:drop_carry()
			self._throw_time = nil
			return true
		else return orig__check_use_item(self, t, input) 
		end
	end
	function PlayerStandard:_action_interact_forbidden()
		return false
	end
	function PlayerManager:carry_blocked_by_cooldown() 
		return false 
	end

	managers.mission._fading_debug_output:script().log('Instant Interact - Activated',  Color.green)
else
	PlayerManager.selected_equipment_deploy_timer = orig_selected_equipment_deploy_timer

	BaseInteractionExt._get_timer = orig__get_timer

	PlayerStandard._check_use_item = orig__check_use_item
	PlayerStandard._action_interact_forbidden = orig__action_interact_forbidden
	PlayerManager.carry_blocked_by_cooldown = orig_carry_blocked_by_cooldown

	managers.mission._fading_debug_output:script().log('Instant Interact - Deactivated',  Color.red)
end