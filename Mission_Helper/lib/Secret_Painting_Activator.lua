if Global.level_data and Global.level_data.level_id == "vit" then
	if RequiredScript == "lib/managers/custom_safehouse/unoachievementchallenge" then
		UnoAchievementChallenge = UnoAchievementChallenge or class()
		function UnoAchievementChallenge:attempt_access_notification()
			managers.mission:call_global_event("uno_access_granted")
		end
		if managers and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Secret Painting", Color.green)
		end
	else
		for _, script in pairs(managers.mission:scripts()) do
			for id, element in pairs(script:elements()) do
				for _, trigger in pairs(element:values().trigger_list or {}) do
					if trigger.notify_unit_sequence == "glowing" then
						if Network:is_server() then
							element:on_executed()
						else
							managers.network:session():send_to_host("to_server_mission_element_trigger", element:id(), managers.player:player_unit())
						end
					end
				end
			end
		end
		if managers and managers.chat then
			managers.chat:_receive_message(1, "Activated", "Secret Painting Element", Color.green)
		end
	end
end