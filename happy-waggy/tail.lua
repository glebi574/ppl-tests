cw = 0xffffffff
co = 0xff6000ff
ce = 0xffff00ff
meshes = {
  {
    vertexes = {{0, 0}, {7, 4}, {14, 6}, {20, 7}, {26, 6}, {32, 4}, {36, 0}, {32, -4}, {26, -6}, {20, -7}, {14, -6}, {7, -4}, {22, 0}},
    segments = {{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0}, {4, 12, 8}},
    colors = {co, co, co, co, cw, cw, cw, cw, cw, co, co, co, cw}
  },
  {
    vertexes = {{0, 3}, {8, 11}, {18, 11}, {30, 1}, {34, 1}, {36, -1}, {36, -3}, {34, -5}, {30, -5}, {17, 6}, {9, 6}, {0, -3}},
    segments = {{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}},
    colors = {ce, ce, ce, ce, ce, ce, ce, ce, ce, ce, ce, ce}
  }
}

--[[
vx = {7, 14, 20, 26, 32}
vy = {4, 6, 7, 6, 4}
vc = {co, co, co, cw, cw}
meshes = {{
  vertexes = {{0, 0}, {36, 0}},
  segments = {{0}},
  colors = {co, cw}
}}
v = meshes[1].vertexes
s = meshes[1].segments
c = meshes[1].colors
for i = 1, #vx do
  table.insert(v, {vx[i], vy[i]})
  table.insert(s[1], i + 1)
  table.insert(c, vc[i])
end
table.insert(s[1], 1)
for i = 1, #vx do
  table.insert(v, {vx[#vx - i + 1], -vy[#vx - i + 1]})
  table.insert(s[1], i + 1 + #vx)
  table.insert(c, vc[#vx - i + 1])
end
table.insert(s[1], 0)
t = #v / 2
table.insert(v, {22, 0})
table.insert(s, {t - 1, #v - 1, t + 2})
]]--