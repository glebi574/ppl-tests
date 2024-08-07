local functions1=require("/dynamic/functions.lua")

pewpew.set_level_size(930fx, 930fx)

local ship_id=pewpew.new_player_ship(10fx,10fx,0)

local time = 0
local death=false

local coords={x=10fx,y=10fx}
local arr={}

function level_tick()
  local conf = pewpew.get_player_configuration(0)
  if conf["has_lost"] == true then
    pewpew.stop_game()
	death=true
  end
if not death then
 
 movement(ship_id,coords,10fx)
 
 area(arr,30fx,coords,ship_id)
 
end
end

pewpew.add_update_callback(level_tick)