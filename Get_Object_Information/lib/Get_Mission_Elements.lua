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

local function get_mission_elements(save_file_name)
	local save_file_name = save_file_name
	local mission_id = ""
	if Global.level_data and Global.level_data.level_id then
		mission_id = tostring(Global.level_data.level_id) .. "-"
	end
	if not save_file_name then
		save_file_name = "MissionElements-" .. mission_id .. os.date("%Y%m%d-%H%M%S") .. '.txt'
	end
	save_file_name = tostring(ModPath) .. tostring(save_file_name)
	local file, err_msg = io.open(save_file_name, 'w')
	if file then
		for data_name, data in pairs(managers.mission._scripts) do
			for id, element in pairs(data:elements()) do
				local str = 'data_name=' .. tostring(data_name) .. ', '
				for k,v in pairs(element) do
					str = str .. k .. '=' .. print_table(v) .. ', '
				end
				file:write(str .. '\n\n')
			end
		end
		file:close()
		managers.chat:_receive_message(1, "File save to", tostring(save_file_name), Color.green)
	else
		managers.chat:_receive_message(1, "File save error", tostring(err_msg), Color.green)
	end
end

get_mission_elements()
