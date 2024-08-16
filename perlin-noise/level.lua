--PPO_NDEBUG = true
require'/dynamic/ppol/.lua'

local offset_z = -2000fx -- 700fx
camera.speed = 32fx
camera.mode = camera_mode.free

require'param'

local fx_pixel_size = to_fx(pixel_size * 4096 // 1) / 4096fx
local fx_grid_size = to_fx(grid_size)
local fx_mesh_size = fx_pixel_size * (fx_grid_size - 1fx)
local fx_offset_m = to_fx(variation_size + 1) / 2fx

local variation_i = random(0, variation_amount - 1)
for x = 1, variation_size do
  for y = 1, variation_size do
    local id = new_entity((x - fx_offset_m) * fx_mesh_size, (y - fx_offset_m) * fx_mesh_size)
    entity_set_mesh(id, 'meshes/' .. variation_i .. '/' .. (x - 1) * variation_size + y - 1)
  end
end

add_update_callback(function()
  camera.offset_z = offset_z + inputs.sd * 2500fx
end)