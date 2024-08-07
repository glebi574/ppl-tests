require'/dynamic/param.lua'
meshes = {}
ti(meshes, {vertexes = {}, segments = {}})
v = {}
for i = bli, 0, -1 do
  ti(v, {i * psi})
end
for i = 1, 2 ^ bli - 1 do
  s, o, t = {}, {}, i
  for k = 0, bli - 1 do
    if t % 2 == 1 then
      ti(o, k)
    end
    t = t >> 1
  end
  t = {o[1]}
  for k = 2, #o do
    local r = o[k]
    if r - o[k - 1] > 1 then
      ti(t, o[k - 1] + 1)
      ti(s, t)
      t = {r}
    end
  end
  ti(t, o[#o] + 1)
  ti(s, t)
  ti(meshes, {vertexes = v, segments = s})
end
