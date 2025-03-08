-- host only
-- having a bug that if you toggle alarms back, camera will keep disable
if not Network:is_server() then
	return
end

Disable_Alarms = not Disable_Alarms

-- backup the origin function
_on_successful_alarm_pager_bluff = _on_successful_alarm_pager_bluff or GroupAIStateBase.on_successful_alarm_pager_bluff
_on_police_called = _on_police_called or GroupAIStateBase.on_police_called
__say_call_the_police = __say_call_the_police or CopLogicArrest._say_call_the_police
_action_request = _action_request or CopMovement.action_request
_clbk_chk_call_the_police = _clbk_chk_call_the_police or CivilianLogicFlee.clbk_chk_call_the_police
__sound_the_alarm = __sound_the_alarm or CivilianLogicFlee.clbk_chk_call_the_police
__set_suspicion_sound = __set_suspicion_sound or SecurityCamera._set_suspicion_sound
_on_executed = _on_executed or ElementLaserTrigger.on_executed

if Disable_Alarms then
	-- Allow infinite pagers
	function GroupAIStateBase:on_successful_alarm_pager_bluff() end

	-- Makes guards & people in general stop calling the cops
	function GroupAIStateBase:on_police_called(called_reason) end
	
	-- Stops police from saying they are calling the police all the time
	function CopLogicArrest:_say_call_the_police(data, my_data) end

	-- Prevents panic buttons & intel burning (intercepting the 'run' action is the only way; for example, if you intercept events such as 'e_so_alarm_under_table' to prevent intel burning, the animation will not happen but the fire will still appear)
	function CopMovement.action_request(self, action_desc)
		if action_desc and action_desc.variant == "run" then return false end
		return _action_request(self, action_desc)
	end

	-- Stops civs from reporting you
	function CivilianLogicFlee:clbk_chk_call_the_police(ignore_this, data) end

	-- Make cameras not trigger the alarm
	function SecurityCamera:_sound_the_alarm(detected_unit) end

	-- Gets rid of the sound of the camera seeing you
	function SecurityCamera:_set_suspicion_sound(suspicion_level) end

	-- Disable cameras
	for _,unit in pairs( SecurityCamera.cameras ) do
		if unit:base()._last_detect_t ~= nil then 
			unit:base():set_update_enabled(false)
			unit:base():set_detection_enabled(flase, nil, nil)
		end
	end

	-- No alarm laser, but only work in some map, not all map, better don't touch laser
	function ElementLaserTrigger:on_executed(instigator, alternative) end

	managers.mission._fading_debug_output:script().log('Disable Alarms - Activated',  Color.green)
end

if not Disable_Alarms then
	GroupAIStateBase.on_successful_alarm_pager_bluff = _on_successful_alarm_pager_bluff
	GroupAIStateBase.on_police_called = _on_police_called
	CopLogicArrest._say_call_the_police = __say_call_the_police
	CopMovement.action_request = _action_request
	CivilianLogicFlee.clbk_chk_call_the_police = _clbk_chk_call_the_police
	SecurityCamera._sound_the_alarm = __sound_the_alarm
	SecurityCamera._set_suspicion_sound = __set_suspicion_sound
	for _,unit in pairs(SecurityCamera.cameras) do
		if unit:base()._last_detect_t ~= nil then 
			unit:base():set_update_enabled(true)
			unit:base():set_detection_enabled(true, nil, nil)
		end
	end
	ElementLaserTrigger.on_executed = _on_executed

	managers.mission._fading_debug_output:script().log('Disable Alarms - Deactivated',  Color.red)
end