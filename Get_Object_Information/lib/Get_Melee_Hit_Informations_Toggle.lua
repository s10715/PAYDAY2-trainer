global_getmeleehitunitinformations_toggle = not global_getmeleehitunitinformations_toggle

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

local function get_information()
	local player_unit = managers.player:player_unit()
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = player_unit:movement():m_head_pos()
	local to = from + player_unit:movement():m_head_rot():y() * range
	local raytrace = player_unit:raycast("ray", from, to, "slot_mask", InstantBulletBase:bullet_slotmask(), "ignore_unit", {}, "ray_type", "body bullet lock")

	if raytrace and raytrace.unit then
		managers.chat:_receive_message(1, "Melee Hit Informations", "hit_position=" .. print_table(raytrace.position) .. " ,hit_unit=" .. print_table(raytrace.unit), tweak_data.system_chat_color)
	else
		managers.chat:_receive_message(1, "Head Position Informations", "player_head_position=" .. print_table(player_unit:movement():m_head_pos()), tweak_data.system_chat_color)
	end
end


orig__do_action_melee = orig__do_action_melee or PlayerStandard._do_action_melee
function PlayerStandard:_do_action_melee(...)
	if global_getmeleehitunitinformations_toggle then
		get_information()
	end
	orig__do_action_melee(self, ...)
end

if global_getmeleehitunitinformations_toggle then
	managers.mission._fading_debug_output:script().log('Get Melee Hit Unit Informations - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Get Melee Hit Unit Informations - Deactivated',  Color.red)
end
