	
	require("/dynamic/math.lua")
	
	player = {
		id = 0, ship_id = 0,
		x = 0fx, y = 0fx, dx = 0fx, dy = 0fx, ang = 0fx,
		max_speed = 10fx, a = 5fx,
		if_custom = false
	}
	
	boxes = {}
	
function make_color(r, g, b, a)
  local color = r * 256 + g
  color = color * 256 + b
  color = color * 256 + a
  return color
end

function change_alpha(color, new_alpha)
  local alpha = color % 256
  color = color - alpha + new_alpha
  return color
end

function in_radius(r,a1,b1,a2,b2)
	if b2 == 0fx then
		local x2, y2 = pewpew.entity_get_position(a2)
		if count_lenght(a1,b1,x2,y2) <= r then return true end
	elseif a2 == 0fx then
		local x1, y1 = pewpew.entity_get_position(a1)
		local x2, y2 = pewpew.entity_get_position(b1)
		if count_lenght(x1,y1,x2,y2) <= r then return true end
	else
		if count_lenght(a1,b1,a2,b2) <= r then return true end
	end
	return false
end

function set_player_info(id,ship_id,if_custom,way,max_speed,a)
	player.id = id
	player.ship_id = ship_id
	player.max_speed = max_speed
	player.a = a
	player.if_custom = if_custom
	if if_custom then pewpew.customizable_entity_set_mesh(id, way, 0) end
end

function control_player()
	local m_ang,ma,s_ang,sa = pewpew.get_player_inputs(0)
	if ma ~= 0fx then
		player.ang = m_ang
		player.dx = player.dx + cos_fx(m_ang) * player.a * ma
		player.dy = player.dy + sin_fx(m_ang) * player.a * ma
		if player.dx > player.max_speed then player.dx = player.max_speed elseif player.dx < -player.max_speed then player.dx = -player.max_speed end
		if player.dy > player.max_speed then player.dy = player.max_speed elseif player.dy < -player.max_speed then player.dy = -player.max_speed end
	end
	if abs_fx(player.dx) > 0.1024fx then
		player.dx = player.dx / 1.512fx
	else
		player.dx = 0fx
	end
	if abs_fx(player.dy) > 0.1024fx then
		player.dy = player.dy / 1.512fx
	else
		player.dy = 0fx
	end
	player.x = player.x + player.dx
	player.y = player.y + player.dy
	pewpew.entity_set_position(player.id, player.x, player.y)
	pewpew.entity_destroy(player.ship_id)
	player.ship_id = pewpew.new_player_ship(player.x, player.y, 0)
	pewpew.customizable_entity_set_mesh_angle(player.id, player.ang, 0fx, 0fx, 1fx)
end

function create_text_box(x,y,scale,text,index)
	local id1 = pewpew.new_customizable_entity(x, y)
	pewpew.customizable_entity_set_mesh(id1, "/dynamic/box.lua", 0)
	pewpew.customizable_entity_set_mesh_xyz_scale(id1, scale, 1fx, 1fx)
	local id2 = pewpew.new_customizable_entity(x, y)
	pewpew.customizable_entity_set_string(id2, text)
	table.insert(boxes, {
		box = id1, text = id2, index = index,
		x1 = x - scale * 20fx, x2 = x + scale * 20fx,
		y1 = y - 20fx, y2 = y + 20fx
	})
end

function find_box(index)
	for i = 1, #boxes do if boxes[i].index == index then return i end end
	return 1
end

function check_box_collision(index, id)
	local i = find_box(index)
	local x, y = pewpew.entity_get_position(id)
	if x >= boxes[i].x1 and x <= boxes[i].x2 and y >= boxes[i].y1 and y <= boxes[i].y2 then return true end
	return false
end

function destroy_box(index, time)
	local i = find_box(index)
	pewpew.customizable_entity_start_exploding(boxes[i].box, time)
	pewpew.entity_destroy(boxes[i].text)
end
