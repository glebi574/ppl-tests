require'/dynamic/ppol/.lua'

def_meshes(1)
mesh = meshes[1]

function __b32b(a, b)
  local result = 0
  local bitval = 1
  while a > 0 and b > 0 do
    if a % 2 + b % 2 == 2 then
      result = result + bitval
    end
    bitval = bitval * 2
    a = a // 2
    b = b // 2
  end
  return result
end

perlin = {}
perlin.p = {}

local permutation = {151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180}

for i=0, 255 do
  perlin.p[i] = permutation[i + 1]
  perlin.p[i + 256] = permutation[i + 1]
end

function perlin:noise(x, y, z)
  y = y or 0
  z = z or 0

  local xi = __b32b(x // 1, 255)
  local yi = __b32b(y // 1, 255)
  local zi = __b32b(z // 1, 255)

  x = x - x // 1
  y = y - y // 1
  z = z - z // 1

  local u = self.fade(x)
  local v = self.fade(y)
  local w = self.fade(z)

  local p = self.p
  local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
  A   = p[xi] + yi
  AA  = p[A] + zi
  AB  = p[A + 1] + zi
  AAA = p[AA]
  ABA = p[AB]
  AAB = p[AA + 1]
  ABB = p[AB + 1]

  B   = p[xi + 1] + yi
  BA  = p[B] + zi
  BB  = p[B + 1] + zi
  BAA = p[BA]
  BBA = p[BB]
  BAB = p[BA + 1]
  BBB = p[BB + 1]

  return self.lerp(w,
    self.lerp(v,
      self.lerp(u,
        self:grad(AAA, x, y, z),
        self:grad(BAA, x - 1, y, z)
      ),
      self.lerp(u,
        self:grad(ABA, x, y - 1, z),
        self:grad(BBA, x - 1, y - 1, z)
      )
    ),
    self.lerp(v,
      self.lerp(u,
        self:grad(AAB, x, y, z - 1), self:grad(BAB, x - 1, y, z - 1)
      ),
      self.lerp(u,
        self:grad(ABB, x, y - 1, z - 1), self:grad(BBB, x - 1, y - 1, z - 1)
      )
    )
  )
end

perlin.dot_product = {
  function(x, y, z) return  x + y end,
  function(x, y, z) return -x + y end,
  function(x, y, z) return  x - y end,
  function(x, y, z) return -x - y end,
  function(x, y, z) return  x + z end,
  function(x, y, z) return -x + z end,
  function(x, y, z) return  x - z end,
  function(x, y, z) return -x - z end,
  function(x, y, z) return  y + z end,
  function(x, y, z) return -y + z end,
  function(x, y, z) return  y - z end,
  function(x, y, z) return -y - z end,
  function(x, y, z) return  y + x end,
  function(x, y, z) return -y + z end,
  function(x, y, z) return  y - x end,
  function(x, y, z) return -y - z end
}

function perlin:grad(hash, x, y, z)
  return self.dot_product[__b32b(hash, 15) + 1](x, y, z)
end

function perlin.fade(t)
  return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
  return a + t * (b - a)
end


require'param'

local size = grid_size
local offset = -size / 2 - 0.5
local scale = noise_scale

local grid = {}
local _min = 1
local _max = -1

--[[
  
  local v = (grid[x][y] + 1) * 255 // 2 -- direct color
  
  local v = (grid[x][y] - _min) * 255 // __v_r -- offset color
  
  local v = (grid[x][y] - _min) / __v_r * 2 -- smoothed offset color
  v * v * 255 // 4
  
  local v = (grid[x][y] - _min) / __v_r // color_layer_approximator / color_layer_amount -- approximated offset color
  grid[x][y] = v
  255 * v // 1
  
]]

function create_grid()
  for x = 1, size do
    grid[x] = {}
    for y = 1, size do
      local v = perlin:noise(x / scale + rx, y / scale + ry)
      grid[x][y] = v
      _min = min(_min, v)
      _max = max(_max, v)
    end
  end

  local __v_r = (_max - _min)
  for x = 1, size do
    for y = 1, size do
      mesh:add_vertex{(x + offset) * pixel_size, (y + offset) * pixel_size}
      local v = (grid[x][y] + 1) / 2 // color_layer_approximator / color_layer_amount
      grid[x][y] = v
      mesh:add_color(make_color(0, v * 255 // 1, 0, 255))
    end
  end
end

function def_segments_layers1()
  connections = {}
  for x = 1, size do
    for y = 1, size do
      if x ~= size and grid[x][y] == grid[x + 1][y] then
        connections[x - 1 .. ' ' .. y - 1 .. ' ' .. x .. ' ' .. y - 1] = 0
      end
      if y ~= size and grid[x][y] == grid[x][y + 1] then
        connections[x - 1 .. ' ' .. y - 1 .. ' ' .. x - 1 .. ' ' .. y] = 0
      end
    end
  end

  for x = 0, size - 2 do
    local segment = {}
    for y = 0, size - 2 do
      if connections[x .. ' ' .. y  .. ' ' .. x .. ' ' .. y + 1] then
        table.insert(segment, x * size + y)
      elseif #segment > 0 then
        table.insert(segment, x * size + y)
        mesh:add_segment(segment)
        segment = {}
      end
    end
  end

  for y = 0, size - 2 do
    local segment = {}
    for x = 0, size - 2 do
      if connections[x .. ' ' .. y  .. ' ' .. x + 1 .. ' ' .. y] and grid[x + 1][y + 1] ~= 0 then
        table.insert(segment, x * size + y)
      elseif #segment > 0 then
        table.insert(segment, x * size + y)
        mesh:add_segment(segment)
        segment = {}
      end
    end
  end
end

function def_segments_layers2()
  connections = {}
  for x = 1, size - 1 do
    for y = 1, size - 1 do
      if grid[x][y] == 0 then
        goto __sl2_no_color
      end
      local on_border = false
      for i = -1, 1 do
        for j = -1, 1 do
          if (i ~= 0 or j ~= 0) and x + i ~= 0 and y + j ~= 0 and grid[x][y] ~= grid[x + i][y + j] then
            on_border = true
            goto __sl2_e
          end
        end
      end
      ::__sl2_e::
      if on_border then
        for i = -1, 1 do
          for j = -1, 1 do
            if (i ~= 0 or j ~= 0) and x + i ~= 0 and y + j ~= 0 and grid[x][y] == grid[x + i][y + j] then
              connections[x .. ' ' .. y .. ' ' .. x + i .. ' ' .. y + j] = 0
            end
          end
        end
      end
      ::__sl2_no_color::
    end
  end
  for v, _ in pairs(connections) do
    local x1, y1, x2, y2 = v:match'(%d+) (%d+) (%d+) (%d+)'
    x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
    connections[x2 .. ' ' .. y2 .. ' ' .. x1 .. ' ' .. y1] = nil
    connections[x1 .. ' ' .. y2 .. ' ' .. x2 .. ' ' .. y1] = nil
    connections[x2 .. ' ' .. y1 .. ' ' .. x1 .. ' ' .. y2] = nil
    mesh:add_segment{(x1 - 1) * size + y1 - 1, (x2 - 1) * size + y2 - 1}
  end
end

function def_segments_linear_grid()
  for x = 0, size - 2 do
    local segment = {}
    for y = 0, size - 1 do
      table.insert(segment, x + y * size)
    end
    mesh:add_segment(segment)
  end
end

function create_mesh(variation_i, file_i)
  rx, ry = table.unpack(variations[variation_i])
  rx = rx + (file_i // variation_size) * (size - 1) / scale
  ry = ry + (file_i % variation_size) * (size - 1) / scale
  create_grid()
  def_segments_layers2()
end

return create_mesh