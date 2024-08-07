	require("/dynamic/functions.lua")
	require("/dynamic/particles/functions.lua")
	require("/dynamic/math.lua")
	
	pewpew.set_level_size(2000fx, 2000fx)
	local ship_id = pewpew.new_player_ship(0fx, 0fx, 0)
	--local s_id = pewpew.new_customizable_entity(0fx,0fx)
	pewpew.configure_player(0, {camera_distance = 100fx})
	--set_player_info(s_id,ship_id,true,"/dynamic/player_mesh.lua",10fx,2fx)
	
	local time = 0
	local death=false
	
	pewpew.add_update_callback(function() update_particle_points() end)
	pewpew.add_update_callback(function() update_following_entities_info() end)
	pewpew.add_update_callback(function() particles_engine() end)
	--pewpew.add_update_callback(function() control_player() end)

	create_text_box(250fx, 650fx, 4fx, "shoot :)", 512)
	
	create_particle_point(1, ship_id, 0x4444ffcf,
	{a1 = 10fx, a2 = 30fx, type = "circle", p = 1fx, condition = "lenght"}, {v = 51fx, r = 7fx}, {"dot_cluster"},
	{dx = 0fx, dy = 0fx, r = 0fx, type = "r_delay"}, {ds = 0fx, rs_type = "null", da = 0fx, r_type = "abs_null"})
	
	local ids = {}
	
	for i = 0fx, 2fx, 1fx do
		for n = 0fx, 2fx, 1fx do
			table.insert(ids, pewpew.new_customizable_entity(n * 250fx, i * 250fx))
		end
	end
	local ang = 0fx
	
	create_particle_point(11, ids[1], 0x9911f1cf,
	{a1 = 10fx, a2 = 30fx, type = "ring", p = 100, condition = "chance"}, {v = 63fx, r = 11fx}, {"dot"},
	{dx = 2fx, dy = 2fx, r = 2fx, type = "rotation"}, {ds = 0fx, rs_type = "null", da = 0fx, r_type = "abs_null"})
	
	create_particle_point(12, ids[2], 0xccccccaa,
	{a1 = 2fx, a2 = 0fx, type = "circle", p = 43, condition = "chance"}, {v = 31fx, r = 4fx}, {"square", "line"},
	{dx = 0fx, dy = 0fx, r = 1.1024fx, type = "linear"}, {ds = 0.64fx, rs_type = "linear", da = 0fx, r_type = "null"})
	
	create_particle_point(13, ids[3], 0x9911f1cf,
	{a1 = 40fx, a2 = 0fx, type = "circle", p = 34, condition = "chance"}, {v = 63fx, r = 11fx}, {"square", "dot"},
	{dx = 0fx, dy = 0fx, r = 0fx, type = "r_delay"}, {ds = 2fx, rs_type = "pm_v", da = 0.216fx, r_type = "pm_v"})
	
	create_particle_point(14, ids[4], 0x33cf33cf,
	{a1 = 40fx, a2 = 70fx, type = "ring", p = 67, condition = "chance"}, {v = 63fx, r = 11fx}, {"square", "dot"},
	{dx = 0fx, dy = 0fx, r = 0fx, type = "r_delay"}, {ds = 2fx, rs_type = "pm_v", da = 0.216fx, r_type = "pm_v"})
	
	create_particle_point(15, ids[5], 0x33cf33cf,
	{a1 = 65fx, a2 = 90fx, type = "ring", p = 67, condition = "chance"}, {v = 63fx, r = 11fx}, {"square", "dot"},
	{dx = 0fx, dy = 0fx, r = 0fx, type = "static"}, {ds = 3fx, rs_type = "pm_v", da = 0.216fx, r_type = "pm_v"})
	
	create_particle_point(16, ids[6], "random",
	{a1 = 2fx, a2 = 0fx, type = "circle", p = 43, condition = "chance"}, {v = 31fx, r = 4fx}, {"square", "line"},
	{dx = 0fx, dy = 0fx, r = 1.1024fx, type = "spiral"}, {ds = 0.64fx, rs_type = "linear", da = 0fx, r_type = "null"})
	
	create_particle_point(17, ids[7], 0xccccccaa,
	{a1 = 60fx, a2 = 0fx, type = "circle", p = 51, condition = "chance"}, {v = 44fx, r = 5fx}, {"square", "dot"},
	{dx = 0fx, dy = 0fx, r = 0fx, type = "static"}, {ds = 1.2048fx, rs_type = "pm_v", da = 0.128fx, r_type = "pm_v"})
	
	create_particle_point(18, ids[8], 0xcf2323ff,
	{a1 = 40fx, a2 = 50fx, type = "ring", p = 67, condition = "chance"}, {v = 63fx, r = 11fx}, {"dot"},
	{dx = 0fx, dy = 0fx, r = 0fx, type = "static"}, {ds = 0.2048fx, rs_type = "pm_v", da = 0.64fx, r_type = "pm_v"})
	
	create_particle_point(19, ids[9], 0xcaca23ff,
	{a1 = 80fx, a2 = 100fx, type = "ring", p = 67, condition = "chance"}, {v = 42fx, r = 8fx}, {"dot"},
	{dx = 0fx, dy = 0fx, r = 1fx, type = "spiral"}, {ds = 0.2048fx, rs_type = "pm_v", da = 0.64fx, r_type = "pm_v"})
	
	function level_tick()
		  local conf = pewpew.get_player_configuration(0)
		  if conf["has_lost"] == true then
				pewpew.stop_game()
				death=true
		  end
		if not death then
			time = time + 1
			
			ang = ang + 0.91fx
			--pewpew.entity_set_position(id1, 500fx + cos_fx(ang) * 50fx, 100fx + sin_fx(ang) * 50fx)
			
			if time % 20 == 0 then
				local x, y = pewpew.entity_get_position(ship_id)
				local n1, n2, ang, a = pewpew.get_player_inputs(0)
				if a ~= 0fx then 
					local id = pewpew.new_player_bullet(x, y, ang, 0)
					create_particle_point(id, id, "random",
					{a1 = 10fx, a2 = 0fx, type = "circle", p = 13fx, condition = "lenght"}, {v = 67fx, r = 4fx}, {"dot"},
					{dx = 2fx, dy = 2fx, r = 2fx, type = "static"}, {ds = 1fx, rs_type = "pm_v", da = 0.256fx, r_type = "pv_m"})
				end
			end
			
		end
	end

pewpew.add_update_callback(level_tick)