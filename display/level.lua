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

load_uncompressed'example'

collectgarbage'collect'
