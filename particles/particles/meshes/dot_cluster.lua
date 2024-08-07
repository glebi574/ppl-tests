
local a = 2.203

local c_vertexes = {}
local c_segments = {}
meshes = {}

local num = 20

for i = 2, num + 2 do
	local mesh = {vertexes = {}, segments = {}}
	local index = 0
	for f = 0, i - 1 do
		for k = 0, i - 1 do
			if math.random(0,10) < 2 then
				table.insert(mesh.vertexes, {(-i / 2 + 1 + f) * a, (-i / 2 + 1.5 + k) * a})
				table.insert(mesh.vertexes, {(-i / 2 + 2 + f) * a, (-i / 2 + 1.5 + k) * a})
				table.insert(mesh.segments, {index, index + 1})
				index = index + 2
				break
			end
		end
	end
	table.insert(meshes, mesh)
end