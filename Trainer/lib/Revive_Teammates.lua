local function revive_teammates()
	local player = managers.player:player_unit() -- managers.player._players[1]
	if not player or not alive(player) then return end

	-- for yourself
	local state = managers.player:current_state()
	if state == "arrested" or state == "bleed_out" or state == "incapacitated" or state == "fatal" then
		managers.player:set_player_state("standard")
		player:base():replenish()
		managers.mission._fading_debug_output:script().log("Revive" .. tostring(player:name()),  Color.yellow)
	end

	-- for other teammates, you can't revive yourself when you're down
	for _,unit in pairs(managers.interaction._interactive_units) do
		if tostring(unit:name()) ~= tostring(player:name()) and unit.interaction and unit:interaction() and unit:interaction().tweak_data == "free" or unit:interaction().tweak_data == "revive" then
			unit:interaction():interact(player)
			managers.mission._fading_debug_output:script().log("Revive" .. tostring(unit:name()),  Color.yellow)
		end
	end
end

revive_teammates()
