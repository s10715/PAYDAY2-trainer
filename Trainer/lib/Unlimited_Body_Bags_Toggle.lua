-- Unlimited Body Bags
global_infBodybags_toggle = global_infBodybags_toggle or false
originBodybagsFunction = originBodybagsFunction or nil

function PlayerManager:__enable_unlimited_body_bag()
	if global_infBodybags_toggle == false then
		global_infBodybags_toggle = true
		managers.player:add_body_bags_amount(1) -- gives you 1 bag on activation, so if you forget to activate it and run out of bags there's no problem
		if originBodybagsFunction == nil then
			originBodybagsFunction = PlayerManager.on_used_body_bag
		end
		function PlayerManager:on_used_body_bag()
			self:_set_body_bags_amount(self._local_player_body_bags)
		end
		managers.mission._fading_debug_output:script().log('Unlimited Body Bags - Activated',  Color.green)
		-- managers.hud:show_hint( { text = "Unlimited Body Bags - Activated" } )
		-- managers.chat:_receive_message(1, "Unlimited Body Bags ", "Activated", Color.green)
	else
		global_infBodybags_toggle = false
		if originBodybagsFunction ~= nil then
			PlayerManager.on_used_body_bag = originBodybagsFunction
		end
		managers.mission._fading_debug_output:script().log('Unlimited Body Bags - Deactivated',  Color.red)
		-- managers.hud:show_hint( { text = "Unlimited Body Bags - Deactivated" } )
		-- managers.chat:_receive_message(1, "Unlimited Body Bags ", "Deactivated", Color.green)
	end
end

managers.player:__enable_unlimited_body_bag()