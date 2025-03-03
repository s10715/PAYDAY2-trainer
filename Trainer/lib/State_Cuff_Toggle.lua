_Cuff = not _Cuff

if _Cuff then
	managers.player:set_player_state("arrested")
	managers.mission._fading_debug_output:script().log(string.format("Cuff - Activated"), Color.green)
else
	managers.player:set_player_state("standard")
	managers.mission._fading_debug_output:script().log(string.format("Cuff - Deactivated"), Color.red)
end