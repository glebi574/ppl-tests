function fx_abs(a)
  return fmath.abs_fixedpoint(a)
end

fx_tau = fmath.tau()

function test_tails()
  pewpew.set_level_size(1000fx, 1000fx)
  local ship_id = pewpew.new_player_ship(500fx, 500fx, 0)
  local tail_id = create_mesh(500fx, 500fx, 'tail')
  pewpew.customizable_entity_set_position_interpolation(tail_id, true)
  
  local tip_id = pewpew.new_customizable_entity(500fx, 570fx)
  pewpew.customizable_entity_set_string(tip_id, 'Use shooting joystick to change tail')
  local list_id = pewpew.new_customizable_entity(500fx, 540fx)
  pewpew.customizable_entity_set_string(list_id, 'Current tails: fox, cat(alpha)')
  local feature1_id = pewpew.new_customizable_entity(500fx, 460fx)
  pewpew.customizable_entity_set_string(feature1_id, 'Stand still for 3 seconds and tail will wag')
  local feature2_id = pewpew.new_customizable_entity(500fx, 430fx)
  pewpew.customizable_entity_set_string(feature2_id, 'Move and tail will wag')
  
  local dx, dy = 1fx, 0fx
  local tail_attachment_distance = 20fx
  local last_movement_angle = 0fx
  
  local tail_rotation = 0fx
  local max_tail_rotation = 0.3072fx
  local tail_acceleration = 0.64fx
  local tail_speed = 0fx
  local max_tail_speed = 0.384fx
  local friction = 0.3968fx
  local min_tail_velocity_sum = 0.192fx
  
  local standby_counter = 0
  local current_tail_counter = 0
  
  pewpew.add_update_callback(function()
    local ma, md, sa, sd = pewpew.get_player_inputs(0)
    if sd ~= 0fx then
      current_tail_counter = current_tail_counter + 1
      pewpew.customizable_entity_set_mesh(tail_id, mpath'tail', current_tail_counter // 4 % 2)
    end
    if md == 0fx then
      standby_counter = standby_counter + 1
    else
      standby_counter = 0
      dy, dx = fmath.sincos(ma)
      local movement_angle_change = ma - last_movement_angle
      if movement_angle_change ~= 0fx then
        tail_speed = tail_speed - movement_angle_change / fx_abs(movement_angle_change) * max_tail_speed
      end
      last_movement_angle = ma
    end
    
    if fx_abs(tail_speed) + fx_abs(tail_rotation) < min_tail_velocity_sum then
      tail_speed = 0fx
      tail_rotation = 0fx
    end
    if fx_abs(tail_rotation) > tail_acceleration then
      tail_speed = tail_speed - tail_rotation / fx_abs(tail_rotation) * tail_acceleration
    end
    if fx_abs(tail_speed) > max_tail_speed then
      tail_speed = tail_speed / fx_abs(tail_speed) * max_tail_speed
    end
    tail_rotation = tail_rotation + tail_speed
    if fx_abs(tail_rotation) > max_tail_rotation then
      tail_rotation = tail_rotation / fx_abs(tail_rotation) * max_tail_rotation
    end
    if standby_counter < 90 then
      tail_rotation = tail_rotation * friction
      tail_speed = tail_speed * friction
    else
      if fx_abs(tail_speed) + fx_abs(tail_rotation) == 0fx then
        tail_speed = max_tail_speed
      end
    end
    
    local x, y = pewpew.entity_get_position(ship_id)
    pewpew.entity_set_position(tail_id, x - dx * tail_attachment_distance, y - dy * tail_attachment_distance)
    pewpew.customizable_entity_set_mesh_angle(tail_id, last_movement_angle + tail_rotation - fx_tau / 2fx, 0fx, 0fx, 1fx)
  end)
end

test_tails()