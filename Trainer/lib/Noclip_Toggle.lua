if not rawget(_G, "no_clip_managers") then
	rawset(_G, "no_clip_managers", {})

	no_clip_managers.noclip = {
		toggle = false,
		axis_move = { x = 0, y = 0, z = 0 },
		speed = 5
	}

	function no_clip_managers:in_chat()
		if managers.hud._chat_focus == true then
			return true
		end
	end

	local orig_func_damage_fall = PlayerDamage.damage_fall
	function PlayerDamage:damage_fall(data)
		if no_clip_managers["toggle"] then
			return false
		end
		return orig_func_damage_fall(self, data)
	end

	function no_clip_managers:update_position()
		local camera_rot = managers.player:player_unit():camera():rotation()
		local move_dir = camera_rot:x() * self.noclip.axis_move.y + camera_rot:y() * self.noclip.axis_move.x + camera_rot:z() * self.noclip.axis_move.z
		local move_delta = move_dir * 10
		local pos_new = managers.player:player_unit():position() + move_delta

		managers.player:warp_to( pos_new, camera_rot, 1, Rotation(0, 0, 0) )
	end

	function no_clip_managers:noclip_update()
		local kb = Input:keyboard()
		local kb_down = kb.down

		if not managers.player:player_unit() then
			return
		end

		self:update_position()
		
		if not self:in_chat() then
			self.noclip.axis_move.x = (kb_down( kb, Idstring("w") ) and self.noclip.speed) or (kb_down( kb, Idstring("s") ) and -self.noclip.speed) or 0
			self.noclip.axis_move.y = (kb_down( kb, Idstring("d") ) and self.noclip.speed) or (kb_down( kb, Idstring("a") ) and -self.noclip.speed) or 0
			self.noclip.axis_move.z = (kb_down( kb, Idstring("space") ) and self.noclip.speed) or (kb_down( kb, Idstring("left ctrl") ) and -self.noclip.speed) or 0
		end
	 end

	if MenuManager then
		if not MenuManager.update_mm_noclip then MenuManager.update_mm_noclip = MenuManager.update end
		no_clip_managers.mm_toggle = no_clip_managers.mm_toggle or function(self, t, dt)
			MenuManager.update_mm_noclip(self, t, dt)
			
			if no_clip_managers["toggle"] then
				no_clip_managers:noclip_update() 
			end
		end
	end

	function no_clip_managers:_toggle()
		if not self["toggle"] then
			MenuManager.update = no_clip_managers.mm_toggle
			managers.mission._fading_debug_output:script().log(string.format("Noclip - Activated"), Color.green)
		else
			if MenuManager.update_mm_noclip then MenuManager.update = MenuManager.update_mm_noclip end
			managers.mission._fading_debug_output:script().log(string.format("Noclip - Deactivated"), Color.red)
		end
		self.toggle = not self.toggle
	end
	no_clip_managers:_toggle()
else
	no_clip_managers:_toggle()
end