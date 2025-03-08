-- host only
if not Network:is_server() then
	return
end

fast_zipline_enable = not fast_zipline_enable

function ZipLine:update(unit, t, dt)
	if fast_zipline_enable then
		self._speed = 5000
	else
		self._speed = 1000
	end
	self:_update_total_time()
	self:_update_sled(t, dt)
	self:_update_sounds(t, dt)
	if ZipLine.DEBUG then
		self:debug_draw(t, dt)
	end
end

if fast_zipline_enable then
	managers.mission._fading_debug_output:script().log('Fast Zipline - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Fast Zipline - Deactivated',  Color.red)
end