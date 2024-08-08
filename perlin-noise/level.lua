--PPO_NDEBUG = true
require'/dynamic/ppol/.lua'

camera.offset_z = 0fx -- 700fx
camera.mode = camera_mode.free

local id = new_entity(0fx, 0fx)
entity_set_mesh(id, 'mesh')

add_update_callback(function()
  --camera.offset_z = inputs.sd * 800fx
end)