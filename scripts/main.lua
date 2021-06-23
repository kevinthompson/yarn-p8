cartdata("yarn")

-- palette
poke(0x5f2e,1)

-- globals
scene=nil
level=nil
state=nil
entities={}
gravity=0.05
input_enabled=true
stars=0
score=0
points=0
points_y=24
high_score=0
shake_offset=0
seed=flr(rnd(999999999))
cam={x=0,y=0}
debug=false
frame=1
show_transparent=true
win_screen_y=-160
win_screen_target_y=-160
star_sounds={28,29,30}
transparency_enabled=dget(62) or 0

-- lifecycle
function _init()
  music(0)
  set_menu_items()
  load_cart_data()
  load_scene(title)
  transition:init()
end

function _update60()
  scene:update()

  show_transparent=not show_transparent
  frame=frame >= 60 and 1 or frame + 1

  for timer in all(timers) do
    timer[1]-=1
    if timer[1]<=0 then
      timer[2]()
      del(timers,timer)
    end
  end

  transition:update()
end

function _draw()
  screen_shake()
  camera(cam.x,cam.y)
  scene:draw()
  transition:draw()

  if debug then
    each_entity(function(entity)
      rect(
        entity.x + entity.hitbox.x,
        entity.y + entity.hitbox.y,
        entity.x + entity.hitbox.x + entity.hitbox.width - 1,
        entity.y + entity.hitbox.y + entity.hitbox.height - 1,
        8
      )
    end)
  end
end

function reset_cart_data()
  for i=0,#levels do
    dset(i,0)
  end

  dset(63,0)
end

function load_cart_data()
  max_level_id=mid(1,dget(63),#levels)
  level_id=max_level_id
end

function load_scene(new_scene)
  if scene~=new_scene then
    timers={}
    scene=new_scene
    scene:init()
  end
end

function set_menu_items(items)
  items = items or {}

  for i=1,5 do
    menuitem(i)
  end

  for item in all(items) do
    menuitem(item[1], item[2], item[3])
  end

  menuitem(4, transparency_enabled == 1 and "transparency off" or "transparency on", function()
    transparency_enabled = transparency_enabled == 1 and 0 or 1
    dset(62, transparency_enabled)
    set_menu_items(items)
  end)

  menuitem(5, debug and "debug off" or "debug on", function()
    debug = not debug
    set_menu_items(items)
  end)
end