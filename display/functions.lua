function mpath(path)
  return string.format('%s%s%s', '/dynamic/', path ,'.lua')
end

local _r = require
function require(path)
  return _r(mpath(path))
end

local _p = print
function print(...) -- adds ability to use fx numbers with print ; doesn't fix negative fx numbers being printed incorrectly
  local arg_amount = select('#', ...)
  local output = {select(1, ...)}
  for i = 1, arg_amount do
    if type(output[i]) == 'number' then
      output[i] = string.format(output[i])
    elseif output[i] == nil then
      output[i] = 'nil'
    end
  end
  _p(table.unpack(output))
end

function debug_print_contents(arr)
  local contents = {}
  for key, value in pairs(arr) do
    table.insert(contents, {tostring(key), tostring(value)})
  end
  table.sort(contents, function(a, b) return b[1]:sub(1, 1) > a[1]:sub(1, 1) end)
  for _, line in ipairs(contents) do
    print(line[1] .. ' - ' .. line[2])
  end
  print(string.format('\u{2705} %i entries', #contents))
end

function get_memory_usage()
  local a = collectgarbage'count'
  return string.format('%i%s %i%s', a // 1, 'KB', a % 1 * 1024, 'B')
end

function add_memory_print()
  pewpew.add_update_callback(function()
    collectgarbage'collect'
    print(get_memory_usage())
  end)
end

camera_distance = 0fx
camera_x = 0fx
camera_y = 0fx
pewpew.configure_player(0, {camera_distance = camera_distance})

function mod_camera_distance()
  local _, _, sa, sd = pewpew.get_player_inputs(0)
  if sd then
    local sin = fmath.sincos(sa)
    camera_distance = camera_distance + sin * sd * 10fx
    pewpew.configure_player(0, {camera_distance = camera_distance})
  end
end

function control_camera()
  local ma, md = pewpew.get_player_inputs(0)
  if md then
    local sin, cos = fmath.sincos(ma)
    camera_x = camera_x + cos * md
    camera_y = camera_y + sin * md
    pewpew.configure_player(0, {camera_x_override = camera_x, camera_y_override = camera_y})
  end
end

function add_camera_callback()
  return pewpew.add_update_callback(function()
    mod_camera_distance()
    control_camera()
  end)
end

function create_mesh(x, y, path, index)
  local id = pewpew.new_customizable_entity(x, y)
  pewpew.customizable_entity_set_mesh(id, mpath(path), index or 0)
  return id
end
