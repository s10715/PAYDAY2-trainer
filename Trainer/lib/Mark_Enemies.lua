-- mark civilians and enemies
local function mark_all()
	for u_key,u_data in pairs(managers.enemy:all_civilians()) do
		u_data.unit:contour():add("mark_enemy", true)
	end
	for u_key,u_data in pairs(managers.enemy:all_enemies()) do
		u_data.unit:contour():add("mark_enemy", true)
	end
	for u_key,unit in pairs(managers.groupai:state()._security_cameras) do
		unit:contour():add("mark_enemy", true)
	end
end

local function mark_all_remove()
	for u_key,u_data in pairs(managers.enemy:all_civilians()) do
		u_data.unit:contour():remove("mark_enemy", true)
	end
	for u_key,u_data in pairs(managers.enemy:all_enemies()) do
		u_data.unit:contour():remove("mark_enemy", true)
	end
	for u_key,unit in pairs(managers.groupai:state()._security_cameras) do
		unit:contour():remove("mark_enemy", true)
	end
end

-- mark special units in line of sight
local function mark_special_units_in_fov()
	-- Get the player and camera objects
	local player = managers.player:local_player()
	if not player then return end
	local camera = player:camera()
	if not camera then return end

	-- Define FOV and distance
	local fov_angle = 60 -- Field of view angle (in degrees)
	local max_distance = 5000 -- Maximum distance to search

	-- Camera position and direction
	local camera_pos = camera:camera_object():position()
	local camera_dir = camera:forward()

	-- Use a collision mask for enemies
	local mask = managers.slot:get_mask("enemies")

	-- Find units in the camera cone
	local units_in_fov = World:find_units("camera_cone", camera:camera_object(), camera_dir, fov_angle, max_distance, mask)

	for _, unit in ipairs(units_in_fov) do
		if alive(unit) and unit:base() and unit:base()._tweak_table then
			local unit_type = unit:base()._tweak_table

			-- Check if the unit is a special type
			if unit_type == "taser" or unit_type == "cloaker" or unit_type == "sniper" or  unit_type == "spooc" or unit_type == "tank" or unit_type == "tank_mini" or unit_type == "tank_medic" or unit_type == "tank_hw" or unit_type == "shield" or unit_type == "marshal_marksman" or unit_type == "marshal_shield"  then
				-- Add a contour (highlight) to the unit
				if not unit:contour():has_id("mark_enemy") then
					unit:contour():add("mark_enemy", true) -- True for sync if needed
					log("Marked special unit: " .. tostring(unit_type))
				end
			end
		end
	end
end


if managers.groupai:state():whisper_mode() then -- mark all units in stealth
	local if_mark = true
	for _,u_data in pairs(managers.enemy:all_enemies()) do
		if u_data.unit:contour():has_id("mark_enemy") then
			if_mark = false
			break
		end
	end
	if if_mark then -- if not mark any enemy yet, mark them all
		mark_all()
		managers.mission._fading_debug_output:script().log("Mark Enemies",  Color.yellow)
	else -- if already mark some enemies, remove all the mark
		mark_all_remove()
		managers.mission._fading_debug_output:script().log("Remove Enemies' Mark",  Color.yellow)
	end
else -- mark special units in loud
	mark_special_units_in_fov()
	managers.mission._fading_debug_output:script().log("Mark Special Enemies",  Color.yellow)
end
