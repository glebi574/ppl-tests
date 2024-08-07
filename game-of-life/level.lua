require'/dynamic/functions.lua'

ne = pewpew.new_customizable_entity
esc = pewpew.entity_set_update_callback
sm = pewpew.customizable_entity_set_mesh
sp = pewpew.entity_set_position
ri = fmath.random_int

--add_memory_print()
add_camera_callback()

require'param'
b = mpath'b'

as = '0123456789abcdefghijklmnopqrstuvwxyz'
s = #as
a = {} -- more optimized way to access alphabet
for i = 1, s do
  ti(a, as:sub(i, i))
end
ar = {} -- reversed alphabet
for i = 1, s do
  ar[a[i]] = i - 1
end
function f36(str)
  return ar[str:sub(1, 1)] * 1296 + ar[str:sub(2, 2)] * 36 + ar[str:sub(3, 3)]
end

ss = ps * bl
w = 10fx
h = 1200fx // w

wi = to_int(w)
hi = to_int(h)

e = wi * hi

gx = 0fx
gy = 0fx

g = {}

function spec(d)
  sm(d, b, g[d])
  sp(d, gx + (wi + d - 1) % wi * ss, gy - to_fx((d - 1) // wi) * ps)
end

function create_screen(x, y) -- creates screen ; (x; y) - top left corner and (0; 0) coordinate of screen
  for k = 1, e do
    local id = ne(x, y)
    esc(id, spec)
    ti(g, 0)
  end
  gx, gy = x, y
end

function set_strip(x, y, v)
  g[x + y * wi + 1] = v
end

function get_pixel(px, py)
  return (g[px // bli + py * wi + 1] >> (bli - px % bli - 1)) % 2
end

function load_uncompressed(file)
  local f = require(file)
  w = to_fx(f36(f:sub(1, 3)))
  h = 1200fx // w
  wi = to_int(w)
  hi = to_int(h)
  for i = 1, wi * hi do
    g[i] = f36(f:sub(i * 3 + 1, i * 3 + 3))
  end
  camera_x = ss * w / 2fx
  camera_y = 20fx + h * ps / 2fx
end

camera_x = ss * w / 2fx
camera_y = 20fx + h * ps / 2fx
camera_distance = 300fx

create_screen(0fx, h * ps)

for y = 0, hi - 1 do
  for x = 0, wi - 1 do
    set_strip(x, y, ri(0, 2 ^ bli - 1))
  end
end

mpw = wi * bli - 1
mph = hi - 1
mbli = bli - 1

time = 0

local pv, strip = 0, 0 -- pixel value ; current strip
local bxl, bxr, byu, byd = 0, 0, 0, 0 -- borders: left, right, up, down
local ng = {} -- new grid

pewpew.add_update_callback(function()
  time = time + 1
  if time % 6 ~= 0 then
    return nil
  end
  for y = 0, mph do
    for x = 0, mpw do
      
      bxl = x == 0 and mpw or x - 1
      bxr = x == mpw and 0 or x + 1
      byu = y == 0 and mph or y - 1
      byd = y == mph and 0 or y + 1
      
      pv = get_pixel(bxl, byu) + get_pixel(x, byu) + get_pixel(bxr, byu)
         + get_pixel(bxl, y)                       + get_pixel(bxr, y)
         + get_pixel(bxl, byd) + get_pixel(x, byd) + get_pixel(bxr, byd)
      
      if pv == 2 then
        strip = strip + get_pixel(x, y)
      elseif pv == 3 then
        strip = strip + 1
      end
      if x % bli == mbli then
        ti(ng, strip)
        strip = 0
      else
        strip = strip << 1
      end
    end
  end
  g = ng
  ng = {}
end)

collectgarbage'collect'
