function __ray_line_reflection(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy) -- ray AB, line segment CD, intersection point K
	local ABk, CDk, ABb, CDb, Kx, Ky, W
	local ABdx, ABdy, CDdx, CDdy = Bx - Ax, By - Ay, Dx - Cx, Dy - Cy
	--r - reverse coordinate system(YX), k - tangent, W - tangent of angles of 2ABk and CDk
	if ABdx ~= 0 then
		ABk = ABdy / ABdx
	end
	if CDdx ~= 0 then
		CDk = CDdy / CDdx
	end
	if ABk == CDk then return nil end
	
	if ABk then
		ABb = Ay - Ax * ABk
	end
	if CDk then
		CDb = Cy - Cx * CDk
	end
	
	if ABb and CDb then
		Kx = (CDb - ABb) / (ABk - CDk)
		Ky = Ay + (Kx - Ax) * ABk
		if abs(CDk) == 1 then
			W = -1 / ABk
		else
			local CD2k = 2 * CDk / (CDk ^ 2 - 1)
			local ABkCD2kd = 1 - ABk * CD2k
			if ABkCD2kd == 0 then
				return Kx, Ky, Kx, Ky + CDk
			else
				W = (ABk + CD2k) / ABkCD2kd
			end
		end
		
		if (Ay > CDk * Ax + CDb) == (Ky - W ^ 2 > CDk * (Kx + W) + CDb) then
			return Kx, Ky, Kx + W, Ky - W ^ 2
		else
			return Kx, Ky, Kx - W, Ky + W ^ 2
		end
	elseif ABb then --CDb = inf
		Ky = Cx * ABk + ABb
		if ABk == 0 then
			return Cx, Ay, Ax, Ay
		end
		Kx = (Ky - ABb) / ABk
		return Kx, Ky, Ax, 2 * Ky - Ay
	elseif CDb then --ABk = inf
		Ky = Ax * CDk + CDb
		if CDk == 0 then
			return Ax, Cy, Cx, Cy
		end
		Kx = (Ky - CDb) / CDk
		if CDk < 0 then
			return Kx, Ky, Kx - 1, Ky + 1 / CDk
		else
			return Kx, Ky, Kx + 1, Ky - 1 / CDk
		end
	end
end

function __reflect_ray(Ax, Ay, Bx, By, N)
	local ABdx, ABdy = Bx - Ax, By - Ay
	local reflections = {}
	for _, line in ipairs(lines) do
		local Kx, Ky, Px, Py = __ray_line_reflection(Ax, Ay, Bx, By, line[1], line[2], line[3], line[4])
		if Kx then
			if Kx then
			if ABdx * (Kx - Ax) >= __s and ABdy * (Ky - Ay) >= __s and (Kx - line[1]) * (Kx - line[3]) <= __s and (Ky - line[2]) * (Ky - line[4]) <= __s then
				table.insert(reflections, {Kx, Ky, Px, Py, line = line})
			end
		end
		end
	end
	if #reflections == 0 then
		return nil
	end
	
	local new_ray = reflections[1]
	for i = 2, #reflections do
		if (new_ray[1] - reflections[i][1]) * (new_ray[1] + reflections[i][1] - 2 * Ax) > (reflections[i][2] - new_ray[2]) * (new_ray[2] + reflections[i][2] - 2 * Ay) then
			new_ray = reflections[i]
		end
	end
	
	local Q
	if abs(new_ray.line.dx) == 0 then
		Q = ceil((new_ray[2] - new_ray.line[2]) / new_ray.line.dy)
	else
		Q = ceil((new_ray[1] - new_ray.line[1]) / new_ray.line.dx)
	end
	if new_ray.line.segments.brightness[Q] then
		new_ray.line.segments.brightness[Q] = new_ray.line.segments.brightness[Q] + 1
	end
	
	if N > 1 then
		return __reflect_ray(new_ray[1], new_ray[2], new_ray[3], new_ray[4], N - 1)
	end
end