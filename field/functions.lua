
function area(lines_arr,delta_dist,coords,ship_id)

local int_delta_dist=fmath.to_int(delta_dist)

local int_x=fmath.to_int(coords.x)
local int_y=fmath.to_int(coords.y)

local x_average=fmath.to_fixedpoint(int_x-int_x%int_delta_dist)
local y_average=fmath.to_fixedpoint(int_y-int_y%int_delta_dist)

local num=fmath.to_int(500fx/delta_dist)

for i=#lines_arr,1,-1 do
pewpew.entity_destroy(lines_arr[i])
table.remove(lines_arr,i)
end

for i=1,num do

for n=1,num do

local lx=fmath.to_fixedpoint(i)*delta_dist+x_average-250fx
local ly=fmath.to_fixedpoint(n)*delta_dist+y_average-250fx
local id=pewpew.new_customizable_entity(lx,ly)
pewpew.customizable_entity_start_spawning(id,0)
pewpew.customizable_entity_set_mesh(id,"/dynamic/line.lua",0)
pewpew.customizable_entity_set_mesh_z(id,fmath.random_fixedpoint(-10fx,10fx))
table.insert(lines_arr,id)

end

end

for i=1,#lines_arr do

  if r_close(ship_id,lines_arr[i],250fx) then
  local ex,ey=pewpew.entity_get_position(lines_arr[i])
  local dx=fmath.abs_fixedpoint(coords.x-ex)
  local dy=fmath.abs_fixedpoint(coords.y-ey)
  local d=fmath.sqrt(dx*dx+dy*dy)
  pewpew.customizable_entity_set_mesh_color(lines_arr[i],make_color(255,255,255,129-fmath.to_int(d/2fx)))
  local ang=fmath.atan2((ey-coords.y),(ex-coords.x))
  pewpew.customizable_entity_set_mesh_angle(lines_arr[i],ang,0fx,0fx,1fx)
  else
  pewpew.customizable_entity_set_mesh_color(lines_arr[i],0x00000000)
  end

end

end

function movement(id,coords,a)
local ang1,m1,no1,no2=pewpew.get_player_inputs(0)
if m1~=0fx then
local sin1,cos1=fmath.sincos(ang1)
local s1=m1*a
local rx=coords.x+s1*cos1
local ry=coords.y+s1*sin1
pewpew.entity_set_position(id,rx,ry)
coords.x=rx
coords.y=ry
else
pewpew.entity_set_position(id,coords.x,coords.y)
end
end

function r_close(ship_id,entity_id,r)
local px,py=pewpew.entity_get_position(ship_id)
local ex,ey=pewpew.entity_get_position(entity_id)
local dx=fmath.abs_fixedpoint(px-ex)
local dy=fmath.abs_fixedpoint(py-ey)
if dx*dx+dy*dy<r*r then return true
else return false end
end

function make_color(r, g, b, a)
  local color = r * 256 + g
  color = color * 256 + b
  color = color * 256 + a
  return color
end

function make_color_with_alpha(color, new_alpha)
  local alpha = color % 256
  color = color - alpha + new_alpha
  return color
end

function color_to_string(color)
  local s = string.format("%x", color)
  while string.len(s) < 8 do
    s = "0" .. s
  end
  return "#" .. s
end

function floating_message(x, y, text, scale, color, d_alpha)
  local id = pewpew.new_customizable_entity(x, y)
  local z = 0fx
  local alpha = 255
  pewpew.customizable_entity_set_mesh_scale(id, scale)


  pewpew.entity_set_update_callback(id, function()
    z = z + 20fx
    local color = make_color_with_alpha(color, alpha)
    local color_s = color_to_string(color)
    pewpew.customizable_entity_set_string(id, color_s .. text)
    pewpew.customizable_entity_set_mesh_z(id, z)
    alpha = alpha - d_alpha
    if alpha <= 0 then
      pewpew.entity_destroy(id)
    end
  end)
  return id
end