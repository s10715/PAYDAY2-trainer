global_stringidreveal_toggle = not global_stringidreveal_toggle

orig_text_actual = orig_text_actual or LocalizationManager.text
function LocalizationManager:text(string_id, ...)
	return (not global_stringidreveal_toggle) and orig_text_actual(self, string_id, ...) or string_id
end

if global_stringidreveal_toggle then
	managers.mission._fading_debug_output:script().log('Reveal String ID - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Reveal String ID - Deactivated',  Color.red)
end




