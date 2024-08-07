function make_color(r, g, b, a)
	return ((r * 256 + g) * 256 + b) * 256 + a
end

function create_segments(entity_amount)
	local segments_amount = floor(entity_amount / #lines)
	for _, line in ipairs(lines) do
		line.segments = {id = {}, brightness = {}}
		line.dx = (line[3] - line[1]) / segments_amount
		line.dy = (line[4] - line[2]) / segments_amount
		local ang = fmath.atan2(to_fx(line.dy), to_fx(line.dx))
		for i = 1, segments_amount do
			local id = pewpew.new_customizable_entity(to_fx(line[1] + line.dx * (i - 1)), to_fx(line[2] + line.dy * (i - 1)))
			pewpew.customizable_entity_set_mesh(id, '/dynamic/mesh.lua', 0)
			pewpew.customizable_entity_set_mesh_angle(id, ang, 0fx, 0fx, 1fx)
			pewpew.customizable_entity_set_mesh_scale(id, fmath.sqrt(to_fx(line.dx * line.dx + line.dy * line.dy)))
			table.insert(line.segments.id, id)
			table.insert(line.segments.brightness, 0)
		end
	end
end

--[[
function lines_to_segments(lines, N)
	local segments_amount = floor(N / #lines)
	local segments = {}
	for _, line in ipairs(lines) do
		local segment = {
			x = line.p1[1],
			y = line.p1[2],
			dx = (line.p2[1] - line.p1[1]) / segments_amount,
			dy = (line.p2[2] - line.p1[2]) / segments_amount,
			chunks = {}
		}
		local ang = fmath.atan2(to_fx(segment.dy), to_fx(segment.dx))
		for i = 1, segments_amount do
			local id = pewpew.new_customizable_entity(to_fx(segment.x + segment.dx * (i - 1)), to_fx(segment.y + segment.dy * (i - 1)))
			pewpew.customizable_entity_set_mesh(id, '/dynamic/mesh.lua', 0)
			pewpew.customizable_entity_set_mesh_angle(id, ang, 0fx, 0fx, 1fx)
			pewpew.customizable_entity_set_mesh_scale(id, fmath.sqrt(to_fx(segment.dx * segment.dx + segment.dy * segment.dy)))
			table.insert(segment.chunks, {id = id, brightness = 0})
		end
		table.insert(segments, segment)
		line.segment = segment
	end
	
	return segments
end
]]--
--[[
function ray_line_reflection(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy) --AB - ray, CD - line segment, K - intersection point
	local ABk, CDk, CDk2, KB1k, Kx, Ky
	local ABdx, CDdx = Bx - Ax, Dx - Cx
	
	if abs(ABdx) > __s then
		ABk = (By - Ay) / ABdx
	else
		ABk = __b
	end
	if abs(CDdx) > __s then
		CDk = (Dy - Cy) / CDdx
	else
		CDk = __b
	end
	
	local ABb, CDb = Ay - Ax * ABk, Cy - Cx * CDk
	local ABk_CDk_d = ABk - CDk
	if abs(ABk_CDk_d) > __s then
		Kx = (CDb - ABb) / ABk_CDk_d
	else
		Kx = (CDb - ABb) / __s
	end
	Ky = Ay + (Kx - Ax) * ABk
	
	if abs(CDk) > __s then
		CDk2 = 2 * CDk / (1 - CDk ^ 2)
	else
		CDk2 = CDk * __s_tg2
	end
	
	local ABk_CDk_1md = 1 - CDk2 * ABk
	if abs(ABk_CDk_1md) > __s then
		KB1k = (CDk2 + ABk) / ABk_CDk_1md
	else
		KB1k = (CDk2 + ABk) / __s
	end
	print('A:', Ax, Ay)
	print('B:', Bx, By)
	print('C:', Cx, Cy)
	print('D:', Dx, Dy)
	print(Kx, Ky, -KB1k)
	if KB1k <= __s then KB1k = 0 end
	return Kx, Ky, -KB1k, CDk, CDb
end

function reflect_ray(lines, segments, ray, N)
	local dx, dy = ray[3] - ray[1], ray[4] - ray[2]
	local rays = {}
	for i = 1, #lines do
		local __ray = {line_num = i}
		__ray.x, __ray.y, __ray.k, __ray.__k, __ray.__b =
			ray_line_reflection(ray[1], ray[2], ray[3], ray[4], lines[i].p1[1], lines[i].p1[2], lines[i].p2[1], lines[i].p2[2])
		table.insert(rays, __ray) --get intersection point and new vector tangent
	end
	--print'OwO\n'
	for i = #rays, 1, -1 do
		if dx * (rays[i].x - ray[1]) < 0 then
		--print('__1', rays[i].x, rays[i].y)
			table.remove(rays, i) --check if intersection point is on the ray, not line
		elseif (rays[i].x - lines[i].p1[1]) * (rays[i].x - lines[i].p2[1]) > 0 and (rays[i].y - lines[i].p1[2]) * (rays[i].y - lines[i].p2[2]) > 0 then
		--print('__2', rays[i].x, rays[i].y)
			table.remove(rays, i) --check if intersection point is on the line segment, not line
		end
	end
	--print('Rays:', #rays, '\n')
	if #rays == 0 then
		return nil
	end
	
	local new_ray = rays[1]
	if #rays == 2 then
	--print('Kx:', rays[2].k)
	--print('Ky:', rays[2].k)
	--print('k:', rays[2].k)
	end
	for i = 2, #rays do --get closest intersection point
		if (new_ray.x - rays[i].x) * (new_ray.x + rays[i].x - 2 * ray[1]) < (rays[i].y - new_ray.y) * (new_ray.y + rays[i].y - 2 * ray[2]) then
			new_ray = rays[i]
		end
	end
	--print('Kx:', new_ray.x)
	--print('Ky:', new_ray.y)
	--print('k:', new_ray.k)
	local Q
	if abs(segments[new_ray.line_num].dx) > __s then --get part of line, color of which should be changed
		Q	= ceil((new_ray.x - segments[new_ray.line_num].x) / segments[new_ray.line_num].dx)
		--print'__dx'
	else
		Q	= ceil((new_ray.y - segments[new_ray.line_num].y) / segments[new_ray.line_num].dy)
		--print'__dy'
	end
	--print('Q:', Q)
	--print('dx new point:', new_ray.x - segments[new_ray.line_num].x)
	--print('dx:', segments[new_ray.line_num].dx)
	--print('dy new point:', new_ray.y - segments[new_ray.line_num].y)
	--print('dy:', segments[new_ray.line_num].dy)
	--print('num:', #segments[new_ray.line_num].chunks)
	print'\n'
	if segments[new_ray.line_num].chunks[Q] ~= nil then segments[new_ray.line_num].chunks[Q].brightness = segments[new_ray.line_num].chunks[Q].brightness + 1 end
	N = N - 1
	if N > 0 then
		if (ray[2] > new_ray.__k * ray[1] + new_ray.__b) == (new_ray.y + new_ray.k > new_ray.__k * (new_ray.x + 1) + new_ray.__b) then
			return reflect_ray(lines, segments, {new_ray.x, new_ray.y, new_ray.x + 1, new_ray.y + new_ray.k}, N)
		end
			return reflect_ray(lines, segments, {new_ray.x, new_ray.y, new_ray.x - 1, new_ray.y - new_ray.k}, N)
	end
end
]]--