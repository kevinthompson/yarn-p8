world={
  init=function(self)
    self:reset_palette()

    clouds = {}
    homes = {}
    world_width = ((#levels-1) * 32) + 48

    for i=1,#levels/2 do
      homes[i] = {flr(rnd(255)), flr(rnd(255))}
    end

    set_menu_items({
      {
        1, "return to title", function()
          transition:animate(function()
            load_scene(title)
          end)
        end
      }
    })

    for i=1,32 do
      create_cloud(rnd(world_width), rnd(16) + -4, -1* (rnd()/10), rnd({-2,-1.5,-1,1,1.5,2,3}))
    end

    for i=1,32 do
      create_cloud(rnd(world_width), rnd(16) + 120, -1* (rnd()/10), rnd({-2,-1.5,-1,1,1.5,2,3}))
    end

    move_world_camera(0)
  end,

  update=function(self)
    move_world_camera()

    if btnp(⬅️) then
      if level_id > 1 then
        sfx(33)
        level_id-=1
      else
        invalid()
      end
    elseif btnp(➡️) then
      if level_id < #levels then
        sfx(33)
        level_id+=1
      else
        invalid()
      end
    elseif action() then
      if level_id <= max_level_id then
        transition:animate(function()
          load_scene(game)
        end)
      else
        invalid()
      end
    end

    for cloud in all(clouds) do
      cloud.x += cloud.speed.x

      if cloud.x < - (24 * cloud.scale) then
        cloud.x = world_width
      end
    end
  end,

  draw=function(self)
    cls(1)
    local bits = {16,4,2,32,8,1,128,64}
    local offsets = {{0,-6},{8,2},{-8,2},{16,10},{0,10},{-16,10},{8,18},{-8,18}}

    for x=flr(cam.x)-48,flr(cam.x)+176 do
      local y=48+(triangle(x/128)*96)
      circfill(x,y,12,0)
    end

    -- houses
    for id=1, #homes do
      local x = 24+((id*2)-1)*32
      local y = 8+((triangle((x+64)/128)*128) * 1.25)
      local house = homes[id]
      local display = house[1]
      local style = house[2]

      for i=1,#bits do
        spr(
          style & bits[i] == bits[i] and 128 or 160,
          x + offsets[i][1],
          y + offsets[i][2] + 4,
          2,
          2
        )
      end

      spr(162,x - 2,y + 26,2,2)

      for i=1,#bits do
        local tall = style & bits[i] == bits[i]

        if (display & bits[i] == bits[i]) then
          spr(
            tall and 132 or 130,
            x + offsets[i][1],
            y + offsets[i][2] + (tall and -8 or 0),
            2,
            tall and 3 or 2
          )
        end
      end
    end

    for i=max(level_id-3,1),min(level_id+3,#levels) do
      draw_level_icon(i)
    end

    draw_clouds()
  end,

  reset_palette = function(self)
    pal()
    pal(1,129,1)
    pal(2,136,1)
    pal(3,130,1)
    pal(5,141,1)
    pal(9,9,1)
    pal(11,138,1)
    pal(15,13,1)
    pal(13,137,1)
  end
}

function move_world_camera(speed)
  speed=speed or .75
  local x=mid(0, ((level_id-1)*32)-40, world_width - 128)
  x=max(0,x)
  cam.x=lerp(cam.x,x,speed)
  cam.y=0
end

function draw_level_icon(id)
  local data=tostr(dget(id))
  local star_count=tonum(sub(data,1,1))
  local x=24+(id-1)*32
  local y=47+(triangle(x/128)*96)

  draw_button(x, y, id, level_id == id, id > max_level_id)

  for i=1,star_count do
    spr(68,x+((i-1)*7)-9,y+cos((i+1)*.5)-15)
  end

  for i=star_count+1,3 do
    spr(67,x+((i-1)*7)-9,y+cos((i+1)*.5)-15)
  end
end

function draw_button(x, y, text, selected, disabled)
  if disabled then
    draw_disabled_button(x, y, selected)
  else
    draw_enabled_button(x, y, selected)
  end

  if type(text) == "function" then
    text(x-3,y-3)
  else
    local half_text = (#tostr(text) * 4) / 2
    print(text, x - half_text + 1, 1 + y - 2, disabled and 15 or 4)
    print(text, x - half_text + 1, y - 2, 7)
  end
end

function draw_enabled_button(x,y,selected)
  local r=7

  if selected then
    circfill(x, y, r + 2, 7)
    circfill(x, y + 2, r + 2, 7)
  end

  circfill(x, y + 2, r, 13)
  circfill(x, y, r, 9)
end

function draw_disabled_button(x,y,selected)
  local r=7

  if selected then
    circfill(x, y, r + 2, 15)
    circfill(x, y + 2, r + 2, 15)
  end

  circfill(x, y + 2, r, 3)
  circfill(x, y, r, 5)

  pset(x+r,y,11)
  pset(x+r-1,y,11)
  pset(x+r-1,y+1,11)
  pset(x+r,y+1,11)
  pset(x+r,y+2,11)

  pset(x-5,y+5,11)
  pset(x-6,y+4,11)
  pset(x-6,y+5,11)
  pset(x-6,y+6,11)

  pset(x,y+r,11)
  pset(x,y+r+1,11)
end

function triangle(x)
  x=band(x, 0x.ffff)
  if (x>=0.5) x=1-x
  return x
end

function invalid()
  sfx(24)
  shake(.075)
end