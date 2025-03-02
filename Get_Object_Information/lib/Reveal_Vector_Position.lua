function show_waypoint(_vector)
	local waypoint_name = "default_reveal_vector_position"
	managers.hud:remove_waypoint(waypoint_name)
	if _vector then
		managers.hud:add_waypoint(
			waypoint_name, {
			icon = 'equipment_vial',
			distance = true,
			position = _vector,
			no_sync = true,
			present_timer = 0,
			state = "present",
			radius = 50,
			color = Color.gray,
			blend_mode = "add"
		})
	end
end

-- local _vector = Vector3(800, -2125, 173)
show_waypoint(_vector)
