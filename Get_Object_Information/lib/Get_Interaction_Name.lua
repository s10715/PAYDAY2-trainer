global_getinteractionname_toggle = not global_getinteractionname_toggle

local function print_table(table)
	local str = ""
	if type(table) == 'table' then
		str = '{ '
		for key,value in pairs(table) do
			str = str .. tostring(key) .. '=' .. tostring(value) .. ', '
		end
		str = str .. ' }'
	else
		str = tostring(table)
	end
	return str
end

orig_interact = orig_interact or BaseInteractionExt.interact
if global_getinteractionname_toggle then
	function BaseInteractionExt:interact(player)
		managers.chat:_receive_message(1, "Interaction Name", tostring(self.tweak_data) .. " , tweak_table=" .. tostring(print_table(self._tweak_data)), tweak_data.system_chat_color)
		orig_interact(self, player)
	end
	managers.mission._fading_debug_output:script().log('Get Interaction Name - Activated',  Color.green)
else
	BaseInteractionExt.interact = orig_interact
	managers.mission._fading_debug_output:script().log('Get Interaction Name - Deactivated',  Color.red)
end