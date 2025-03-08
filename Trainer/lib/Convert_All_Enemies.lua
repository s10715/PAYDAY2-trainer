-- host only
if not Network:is_server() then
	return
end

local function convert_all_enemies()
	-- add 500 max count of convert enemies each time
	local orig_upgrade_value_ = PlayerManager.upgrade_value
	function PlayerManager:upgrade_value(category, upgrade, default) 
		local r = orig_upgrade_value_(self, category, upgrade, default) 
		if category == "player" and upgrade == "convert_enemies" then
			return true
		elseif category == "player" and upgrade == "convert_enemies_max_minions" then
			return r+500
		else 
			return r
		end 
	end

	-- convert enemies
	for _,ud in pairs(managers.enemy:all_enemies()) do
		if alive(ud.unit) and not ud.unit:brain()._logic_data.is_converted then
			managers.groupai:state():convert_hostage_to_criminal(ud.unit)
			managers.groupai:state():sync_converted_enemy(ud.unit)
			unit:contour():add("friendly", true)
		end
	end
	managers.mission._fading_debug_output:script().log('Convert All Enemies',  Color.yellow)
end
convert_all_enemies()
