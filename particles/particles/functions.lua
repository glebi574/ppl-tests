	
	require("/dynamic/functions.lua")
	require("/dynamic/math.lua")
	
	particles = {}
	entities = {}
	particle_points = {}

function add_following_entity(id)
	local x, y = pewpew.entity_get_position(id)
	table.insert(entities,{
		id = id,
		x = x, y = y, dx = 0fx, dy = 0fx,
		lenght = 0fx
	})
end

function update_following_entities_info()
	local to_remove = {}
	for i = 1, #entities do
		if pewpew.entity_get_is_alive(entities[i].id) then
			local x, y = pewpew.entity_get_position(entities[i].id)
			entities[i].dx = x - entities[i].x
			entities[i].dy = y - entities[i].y
			entities[i].lenght = entities[i].lenght + count_lenght(entities[i].dx, entities[i].dy, 0fx, 0fx)
			entities[i].x = x
			entities[i].y = y
		else
			table.insert(to_remove, i)
		end
	end
	for i = #to_remove, 1, -1 do
		table.remove(entities, to_remove[i])
	end
end

function find_following_entity(id)
	for i = 1, #entities do
		if entities[i].id == id then return i end
	end
	return 1
end

function stop_following_entity(id)
	table.remove(entities, find_following_entity(id))
end

--[[
	particle type:
	
		-square
		
		-triangle
		
		-dot
		-line
		
		-circle
		
		-wide_circle
	
	movement type:
		
		-linear
		-spiral
		-static
		-rotation		rotation around point
		-r_delay		delay + random 
	
	generation type:
		
		-square			a1
		-circle			r = a1
		-ring			r = a1 -> a2
	
	generation condition:
		
		-chance
		-lenght
	
	modifier:
		
		--resizing type
		-null
		-linear
		-pm_v		plus minus value
		
		--rotating type
		-null
		-abs_null
		-linear
		-pm_v
	
	
	parametres:
		
		id, generation, color, particle's type, movement type, lifetime, modifier
		
		generation -> {a1, a2, generation type, param, condition}
		color -> "random" or 0x...
		lifetime -> {value, randomness}
		modifier -> {delta size, resizing type, delta angle, rotating type}
		particle's type -> {type,...}
		movement type -> {dx, dy, randomness, type}
		
]]--

function particle_type(id, p_type)
	local m = p_type[fmath.random_int(1, #p_type)]
	local f = 0
	if m == "dot_cluster" then
		f = fmath.random_int(2,4)
		pewpew.customizable_entity_set_mesh_angle(id, 3.580fx / 2fx * fmath.to_fixedpoint(fmath.random_int(0, 3)), 0fx, 0fx, 1fx)
	end
	pewpew.customizable_entity_set_mesh(id, "/dynamic/particles/meshes/"..m..".lua", f)
	pewpew.customizable_entity_set_position_interpolation(id, true)
end

function create_particle(x,y,dx,dy,color,lifetime,p_type,m_type,modifier)
	local id = pewpew.new_customizable_entity(x, y)
	pewpew.customizable_entity_start_spawning(id, 0)
	particle_type(id, p_type)
	pewpew.customizable_entity_set_mesh_color(id, color)
	if modifier.r_type ~= "abs_null" then
		pewpew.customizable_entity_set_mesh_angle(id, fmath.atan2(dy,dx), 0fx, 0fx, 1fx)
	end
	
	table.insert(particles,{
		id = id,
		dx = dx, dy = dy,
		alpha = 255, da = fmath.to_int(255fx / lifetime),
		lifetime = lifetime,
		color = color, type = m_type,
		size = 1fx, modifier = modifier,
		ds_a = 0fx, da_a = 0fx, dp_a = 0fx
	})
end

function create_particle_point(index, id, color, generation, lifetime, p_type, m_type, modifier)
	table.insert(particle_points, {
	index = index, id = id, color = color,
	generation = generation, lifetime = lifetime,
	p_type = p_type, m_type = m_type, modifier = modifier
	})
	add_following_entity(id)
end

function destroy_particle_point(n)
	for i = 1, #particle_points do
		if particle_points[i].index == n then
			pewpew.entity_destroy(particle_points[i].id)
			break
		end
	end
end

function update_particle_points()
	local to_remove = {}
	for i = 1, #particle_points do
		if pewpew.entity_get_is_alive(particle_points[i].id) then
			local x, y = pewpew.entity_get_position(particle_points[i].id)
			local lifetime = particle_points[i].lifetime.v + fmath.random_fixedpoint(-particle_points[i].lifetime.r, particle_points[i].lifetime.r)
			local dx = particle_points[i].m_type.dx + fmath.random_fixedpoint(-particle_points[i].m_type.r * 100fx, particle_points[i].m_type.r * 100fx) / 100fx
			local dy = particle_points[i].m_type.dy + fmath.random_fixedpoint(-particle_points[i].m_type.r * 100fx, particle_points[i].m_type.r * 100fx) / 100fx
			
			local rx = 10000fx ry = 10000fx
			if particle_points[i].generation.type == "square" then
				rx = fmath.random_fixedpoint(-particle_points[i].generation.a1, particle_points[i].generation.a1)
				ry = fmath.random_fixedpoint(-particle_points[i].generation.a1, particle_points[i].generation.a1)
			elseif particle_points[i].generation.type == "circle" then
				while rx * rx + ry * ry > particle_points[i].generation.a1 * particle_points[i].generation.a1 do
					rx = fmath.random_fixedpoint(-particle_points[i].generation.a1, particle_points[i].generation.a1)
					ry = fmath.random_fixedpoint(-particle_points[i].generation.a1, particle_points[i].generation.a1)
				end
			else
				while rx * rx + ry * ry < particle_points[i].generation.a1 * particle_points[i].generation.a1 or
				      rx * rx + ry * ry > particle_points[i].generation.a2 * particle_points[i].generation.a2 do
					rx = fmath.random_fixedpoint(-particle_points[i].generation.a2, particle_points[i].generation.a2)
					ry = fmath.random_fixedpoint(-particle_points[i].generation.a2, particle_points[i].generation.a2)
				end
			end
			x = x + rx
			y = y + ry
			
			local color
			if particle_points[i].color == "random" then
				color = make_color(fmath.random_int(10,255), fmath.random_int(10,255), fmath.random_int(10,255), 256)
			else
				color = particle_points[i].color
			end
			
			local if_create = false
			if particle_points[i].generation.condition == "chance" then
				if_create = chance(particle_points[i].generation.p)
			else
				local i1 = find_following_entity(particle_points[i].id)
				if entities[i1].lenght > particle_points[i1].generation.p then
					if_create = true
					entities[i].lenght = 0fx
				end
			end
			if if_create then
				create_particle(x,y,dx,dy,color,lifetime,particle_points[i].p_type,particle_points[i].m_type.type,particle_points[i].modifier)
			end
		else
			table.insert(to_remove, i)
		end
	end
	for i = #to_remove, 1, -1 do
		table.remove(particle_points, to_remove[i])
	end
end

function particles_engine()
	local to_remove = {}
	for i = 1, #particles do
		if particles[i].type ~= "static" then
			if particles[i].type == "spiral" then
				particles[i].dy, particles[i].dx = fmath.sincos(fmath.atan2(particles[i].dy, particles[i].dx) + 0.91fx)
			end
			
			if particles[i].type == "rotation" then
				particles[i].dp_a = particles[i].dp_a + 0.512fx
				particles[i].dy, particles[i].dx = fmath.sincos(particles[i].dp_a)
			end
			local x, y = pewpew.entity_get_position(particles[i].id)
			if particles[i].type == "r_delay" then
				if chance(5) then
					particles[i].type = "linear"
					particles[i].dx = fmath.random_fixedpoint(-1000fx,1000fx) / 750fx
					particles[i].dy = fmath.random_fixedpoint(-1000fx,1000fx) / 750fx
				end
			else
				x = x + particles[i].dx
				y = y + particles[i].dy
				pewpew.entity_set_position(particles[i].id, x, y)
			end
			
			if particles[i].modifier.r_type == "null" then
				ang = fmath.atan2(particles[i].dy, particles[i].dx)
				pewpew.customizable_entity_set_mesh_angle(particles[i].id, fmath.atan2(particles[i].dy, particles[i].dx), 0fx, 0fx, 1fx)
			end
		end
		
		if particles[i].modifier.rs_type == "linear" then
			particles[i].size = particles[i].size + particles[i].modifier.ds
			pewpew.customizable_entity_set_mesh_scale(particles[i].id, particles[i].size)
		elseif particles[i].modifier.rs_type == "pm_v" then
			particles[i].ds_a = particles[i].ds_a + 0.246fx
			local size = particles[i].size + particles[i].modifier.ds * sin_fx(particles[i].ds_a)
			pewpew.customizable_entity_set_mesh_scale(particles[i].id, size)
		end
		
		if particles[i].modifier.r_type == "linear" then
			pewpew.customizable_entity_add_rotation_to_mesh(particles[i].id, particles[i].modifier.da, 0fx, 0fx, 1fx)
		elseif particles[i].modifier.r_type == "pm_v" then
			particles[i].da_a = particles[i].da_a + 0.246fx
			local ang = particles[i].modifier.da * particles[i].da_a
			pewpew.customizable_entity_add_rotation_to_mesh(particles[i].id, ang, 0fx, 0fx, 1fx)
		end
		
		particles[i].alpha = particles[i].alpha - particles[i].da
		if particles[i].alpha <= 0 then particles[i].alpha = 0 end
		particles[i].color = change_alpha(particles[i].color, particles[i].alpha)
		pewpew.customizable_entity_set_mesh_color(particles[i].id, particles[i].color)
		
		if particles[i].lifetime ~= -11fx then
			particles[i].lifetime = particles[i].lifetime - 1fx
			if particles[i].lifetime <= 0fx then
				pewpew.entity_destroy(particles[i].id)
				table.insert(to_remove, i)
			end
		end
	end
	for i = #to_remove, 1, -1 do
		table.remove(particles, to_remove[i])
	end
end
