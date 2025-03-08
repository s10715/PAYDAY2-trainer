-- doesn't change your name locally in the end-game menu (where you pick cards), though others still see the spoofed name.

local name = "Unknown"

function update_name()
	if Steam and Steam.username and managers.network and managers.network.session() then
		-- userid = Steam.userid(Steam)
		return Steam:username(managers.network:session():local_peer()._user_id)
	else
		return name
	end
end

function spoof_name()
	if managers.network and managers.network:session() and managers.network:session():local_peer() then
		local session = managers.network:session()
		local my_peer = session:local_peer()
		my_peer:set_name(name)
		for _, peer in pairs(session._peers) do
			if not peer:loaded() or not my_peer:loaded() then
				peer:send("request_player_name_reply", name)
			end
		end
	end
end

-- update_name()
spoof_name()
