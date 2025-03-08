if not Global.level_data or Global.level_data.level_id ~= "welcome_to_the_jungle_2" then
	return
end

local function print_engine_host()
	local PossibleOne = {
		id_103703 = {	name="Engine 1",	waypoint=Vector3(-1830, -2182, -313.492)	},
		id_103704 = {	name="Engine 2",	waypoint=Vector3(-1200, -2050, -313.492)	},
		id_103705 = {	name="Engine 3",	waypoint=Vector3(-1849, -1869, -313.492)	},
		id_103706 = {	name="Engine 4",	waypoint=Vector3(-1200, -1735, -313.492)	},
		id_103707 = {	name="Engine 5",	waypoint=Vector3(-1849, -1429, -313.492)	},
		id_103708 = {	name="Engine 6",	waypoint=Vector3(-1200, -1415, -313.492)	},
		id_103709 = {	name="Engine 7",	waypoint=Vector3(-175, -2025, -313.492)		},
		id_103711 = {	name="Engine 8",	waypoint=Vector3(24.9999, -1350, -313.492)	},
		id_103714 = {	name="Engine 9",	waypoint=Vector3(-175, -1675, -313.492)		},
		id_103715 = {	name="Engine 10",	waypoint=Vector3(35, -1733, -314)			},
		id_103716 = {	name="Engine 11",	waypoint=Vector3(-175, -1350, -313.492)		},
		id_103717 = {	name="Engine 12",	waypoint=Vector3(25, -2050, -313.492)		}
	}

	if  managers and managers.chat and managers.mission then
		local id = "id_" .. tostring(managers.mission:script("default")._elements[103718]._values.on_executed[1].id)
		managers.chat:_receive_message(1, "Correct Engine is ", PossibleOne[id].name, Color.green)

		managers.hud:add_waypoint("correct_engine_waypoint", {
			icon = "wp_target",
			position = PossibleOne[id].waypoint,
			present_timer = 0,
			state = "present",
			radius = 10,
			blend_mode = "add"
		})
		DelayedCalls:Add("remove_correct_engine_waypoint", 10, function()
			managers.hud:remove_waypoint("correct_engine_waypoint")
		end)
	end
end


local function print_engine_client(engines, engineid, loceng, loceng2)
	if engines and engines~="" and engineid and loceng then
		local waypoint_1, waypoint_2 = "", ""
		local function add_waypoint(name, position, id)
			if name and position and id then
				waypoint_1 = string.format("%s_%s_1", name, id)
				managers.hud:add_waypoint(
					waypoint_1, {
					icon = 'equipment_vial',
					distance = true,
					position = position,
					no_sync = true,
					present_timer = 0,
					state = "present",
					radius = 800,
					color = Color.white,
					blend_mode = "add"
				})
			end
		end
		local function add_waypoint2(name, position, id)
			if name and position and id then
				waypoint_2 = string.format("%s_%s_2", name, id)
				managers.hud:add_waypoint(
					waypoint_2, {
					icon = 'equipment_vial',
					distance = true,
					position = position,
					no_sync = true,
					present_timer = 0,
					state = "present",
					radius = 800,
					color = Color.white,
					blend_mode = "add",
				})
			end
		end

		if loceng2 then
			add_waypoint(engines, loceng, engineid)
			add_waypoint2(engines, loceng2, engineid)
			DelayedCalls:Add("remove_waypoints_timer2", 10, function() 
				managers.hud:remove_waypoint(waypoint_1) 
				managers.hud:remove_waypoint(waypoint_2) 
			end)
		else
			add_waypoint(engines, loceng, engineid)
			DelayedCalls:Add("remove_waypoints_timer", 10, function() 
				managers.hud:remove_waypoint(waypoint_1) 
			end)
		end
		
		local function show_message(str)
			if managers.chat then
				managers.chat:feed_system_message(ChatManager.GAME, (str or "error"))
			end
		end
		local _name = string.gsub(engines, "_", " ")
		show_message(string.format("Correct one is: %s", _name))
	end
end

local function print_engine_menu_client()
	local dialog_data = {    
		title = "Engine Menu For Client",
		text = "Select Correct Clue",
		button_list = {}
	}

	local all_engines = {
		{id = '1', gastext = "Nitrogen is yellow, Deterium is blue, Helium is green",   enginetext = "", loc = "",  loc2 = ""},
		{id = '2', gastext = "1H - Nitrogen - <5812: Engine 1", enginetext = "engine_01", loc = Vector3(-1830, -2182, -313.492)},
		{id = '3', gastext = "1H - Deterium - >5783: Engine 2", enginetext = "engine_02", loc = Vector3(-1200, -2050, -313.492)},
		{id = '1', gastext = "",   enginetext = "", loc = "",  loc2 = ""},
		{id = '4', gastext = "2H - Nitrogen - <5812: Engine 4", enginetext = "engine_04", loc = Vector3(-1200, -1735, -313.492)},
		{id = '5', gastext = "2H - Deterium - <5812: Engine 5", enginetext = "engine_05", loc = Vector3(-1849, -1429, -313.492)},
		{id = '6', gastext = "2H - Helium - <5812: Engine 3", enginetext = "engine_03", loc = Vector3(-1849, -1869, -313.492)},
		{id = '7', gastext = "2H - Helium - >5783: Engine 6", enginetext = "engine_06", loc = Vector3(-1200, -1415, -313.492)},
		{id = '1', gastext = "",   enginetext = "", loc = "",  loc2 = ""},
		{id = '8', gastext = "3H - Nitrogen - <5812: Engine 8", enginetext = "engine_08", loc = Vector3(24.9999, -1350, -313.492)},
		{id = '9', gastext = "3H - Nitrogen - >5783: Engine 11", enginetext = "engine_11", loc = Vector3(-175, -1350, -313.492)},
		{id = '10', gastext = "3H - Deterium - <5812: Engine 9", enginetext = "engine_09", loc = Vector3(-175, -1675, -313.492)},
		{id = '11', gastext = "3H - Deterium - >5783: Engine 12", enginetext = "engine_12", loc = Vector3(25, -2050, -313.492)},
		{id = '12', gastext = "3H - Helium - <5812: Engine 7", enginetext = "engine_07", loc = Vector3(-175, -2025, -313.492)},
		{id = '13', gastext = "3H - Helium - <=5812: Engine 10", enginetext = "engine_10", loc = Vector3(35, -1733, -314)},
		{id = '14', gastext = "3H - Helium - ?: Engine 7 or 10", enginetext = "engine_07_or_engine_10", loc = Vector3(-175, -2025, -313.492), loc2 = Vector3(35, -1733, -314)},
	}

	for _, engine in pairs(all_engines) do
		if engine then
			table.insert(dialog_data.button_list, {
				text = engine.gastext,
				callback_func = function()
					print_engine_client(engine.enginetext, engine.id, engine.loc, engine.loc2)
				end,
			})
		end
	end

	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:force_close_all()
	managers.system_menu:show_buttons(dialog_data)
end




if Network:is_server() then
	print_engine_host()
else
	print_engine_menu_client()
end
