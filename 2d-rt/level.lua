require'/dynamic/math.lua'
require'/dynamic/functions.lua'
require'/dynamic/__functions.lua'
pewpew.configure_player(0, {camera_distance = 0fx})

local __rgb = make_color(255, 255, 255, 0)

lines = {
	{0, 0, 0, 500},
	{0, 500, 500, 500},
	{500, 500, 500, 0},
	{500, 0, 0, 0},
	{100, 100, 100, 200},
	{100, 200, 200, 200},
	{200, 200, 200, 100},
	{200, 100, 100, 100},
	{100, 400, 300, 400},
	{300, 400, 100, 350},
	{100, 350, 100, 400},
	{400, 20, 480, 80},
	{200, 20, 400, 20},
	{480, 280, 480, 80}
}

create_segments(1190)

local ray_amount = 628
local reflection_amount = 2
local da = tau / ray_amount
local max_brightness = 0
local Lx, Ly = 250, 250

local __sc_rt_dx, __sc_rt_dy = {}, {}
for i = 1, ray_amount do --compute angle projections to not repeat that every time
	local dy, dx = fmath.sincos(to_fx(da * (i - 1)))
	table.insert(__sc_rt_dx, fmath.to_int(dx * 4096fx))
	table.insert(__sc_rt_dy, fmath.to_int(dy * 4096fx))
end

local light_source = pewpew.new_customizable_entity(to_fx(Lx), to_fx(Ly))
pewpew.customizable_entity_set_mesh(light_source, '/dynamic/light_source.lua', 0)

pewpew.add_update_callback(function()
	pewpew.configure_player(0, {camera_x_override = 250fx, camera_y_override = 250fx})
	
	local ma, md, sa, sd = pewpew.get_player_inputs(0)
	
	if md ~= 0fx then --movement joystick movement
		local dy, dx = fmath.sincos(ma)
		Lx = Lx + to_int(dx)
		Ly = Ly + to_int(dy)
		pewpew.entity_set_position(light_source, to_fx(Lx), to_fx(Ly))
	end
	
	if sd ~= 0fx then --shooting joystick reflection amount change
		local dr = fmath.sincos(sa)
		reflection_amount = reflection_amount + to_int(dr) / 10
		pewpew.configure_player_hud(0, {top_left_line = 'reflection_amount: ' .. string.format('%i', floor(reflection_amount))})
	end
	
	if md ~= 0fx or sd ~= 0fx then --update scene
		
		for _, line in ipairs(lines) do
			for i = 1, #line.segments.brightness do
				line.segments.brightness[i] = 0
			end
		end
		
		for i = 1, ray_amount do
			__reflect_ray(Lx, Ly, Lx + __sc_rt_dx[i], Ly + __sc_rt_dy[i], reflection_amount)
		end
		
		max_brightness = 0
		for _, line in ipairs(lines) do
			for _, brightness in ipairs(line.segments.brightness) do
				if brightness > max_brightness then
					max_brightness = brightness
				end
			end
		end
		local __mbk = 255 / max_brightness
		
		if max_brightness ~= 0 then
			for _, line in ipairs(lines) do
				for i = 1, #line.segments.id do
					pewpew.customizable_entity_set_mesh_color(line.segments.id[i], __rgb + floor(line.segments.brightness[i] * __mbk))
				end
			end
		end
	end
end)