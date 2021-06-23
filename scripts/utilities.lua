function autotile(map_x,map_y,map_w,map_h,flag,rules)
  for x=map_x,map_x+map_w-1 do
    for y=map_y,map_y+map_h-1 do
      if fget(mget(x,y),flag) then
        local bitmask=0

        for dy = -1, 1 do
          for dx = -1, 1, dy==0 and 2 or 1 do
            local bit = (1 - dy) * 3 + 1 - dx
            bit = shl(1, bit < 4 and bit or bit - 1)
            if fget(mget(x+dx, y+dy),flag) or
            x+dx<map_x or x+dx>=map_x+map_w or
            y+dy<map_y or y+dy>=map_y+map_h then
              bitmask = bor(bitmask, bit)
            end
          end
        end

        for rule in all(rules) do
          local rulemask=rule[1]
          local sprite=rule[2]

          if type(sprite)=="table" then
            sprite=rnd(sprite)
          end

          if (band(bitmask,rulemask)==rulemask) then
            mset(x,y,sprite)
          end
        end
      end
    end
  end
end

function tiles(x1,y1,x2,y2)
  local tiles={}

  for x=flr(x1/8),flr(x2/8) do
    for y=flr(y1/8),flr(y2/8) do
      add(tiles, tget(x,y))
    end
  end

  return tiles
end

function tget(mx,my)
  return {
    x=mx*8,
    y=my*8,
    mx=mx,
    my=my,
    sprite=mget(mx,my)
  }
end

function log(obj)
  printh(tostring(obj))
end

function tostring(obj)
  if type(obj)=="table" then
    local str="{"
    local add_comma=false

    for k,v in pairs(obj) do
      str=str..(add_comma and ", " or " ")
      str=str..k.."="..tostring(v)
      add_comma=true
    end

    return str.." }"
  else
    return tostr(obj)
  end
end

function load_level(id)
  data=tostr(dget(id))
  stars=0
  prev_stars=tonum(sub(data,1,1))
  high_score=tonum(sub(data,2)) or 0
  score=1000
  level_id=id
  level=levels[id]

  win_screen_y=-160
  win_screen_target_y=-160
  points_y=32
  menu_id=3

  clear_map_data()
  load_map_data()
  autotile(0,0,level_width,level_height,tilemap["w"],tilesets[1])

  ui_stars={}
  for i=1,3 do
    add(ui_stars, ui_star:new(4+((i-1)*16), 4))
  end
end

function clear_map_data()
  entities={}
  memset(0x2000,0,0x2fff-0x2000)
end

function load_map_data()
  local data=""
  local count=""

  level_width = 0

  for c=1,#level do
    local char = tostr(sub(level,c,c))

    if tilemap[char] then
      level_width += 1
    elseif char == "\n" and level_width > 0 then
      break
    end
  end

  for i=1,5 do
    for j=1,level_width do
      data=data.."w"
    end
  end

  for i=1,#level do
    local char = sub(level,i,i)

    if tonum(char) then
      count = count..char
    elseif tilemap[char] then
      for j=1,max(1,tonum(count)) do
        data = data..char
      end

      count=""
    end
  end

  for i=1,6 do
    for j=1,level_width do
      data=data.."w"
    end
  end

  level_height = #data/level_width

  for y=0,level_height-1 do
    for x=0,level_width-1 do
      local i=(y*level_width)+x+1
      local char=sub(data,i,i)
      local value=tilemap[char]

      if value then
        if type(value) == "function" then
          value(x,y)
        elseif type(value) == "table" then
          mset(x,y,rnd(value))
        else
          mset(x,y,value)
        end
      end
    end
  end
end

function create_entity(layer, table)
  entities[layer]=entities[layer] or {}
  local entity=merge({{
    animations={},
    animation=nil,
    frame=1,

    hitbox = {
      x = 0,
      y = 0,
      width = 8,
      height = 8
    },

    init=function(self)
      -- noop
    end,

    update=function(self)
      -- noop
    end,

    draw=function(self)
      -- noop
    end,

    destroy=function(self)
      del(entities[layer], self)
    end,

    animate=function(self, name)
      self.animation=self.animations[name]
      self.frame=1
    end
  }, table})

  entity:init()

  add(entities[layer], entity)
  return entity
end

function each_entity(callback)
  for layer,group in pairs(entities) do
    for entity in all(group) do
      callback(entity, layer)
    end
  end
end

function collide(obj,other)
  return other.x + other.hitbox.x < obj.x + obj.hitbox.x + obj.hitbox.width - 1
  and other.x + other.hitbox.x+other.hitbox.width - 1 > obj.x + obj.hitbox.x
  and other.y + other.hitbox.y < obj.y + obj.hitbox.y + obj.hitbox.height - 1
  and other.y + other.hitbox.y + other.hitbox.height > obj.y + obj.hitbox.y
end

function screen_shake()
  local fade = 0.95
  local offset_x=16-rnd(32)
  local offset_y=16-rnd(32)
  offset_x*=shake_offset
  offset_y*=shake_offset

  cam.x=cam.x+offset_x
  cam.y=cam.y+offset_y

  shake_offset*=fade
  if shake_offset<0.05 then
    shake_offset=0
  end
end

function shake(amount)
  shake_offset=amount or .1
end

function lerp(pos,tar,perc)
  return (1-perc)*tar + perc*pos
end

function set_timer(frames,func)
  timers=timers or {}
  add(timers, {frames,func})
end

function animate(entity)
  local animation = entity.animation

  if animation then
    local fps = animation.fps ~= nil and animation.fps or 15

    if frame%(60/fps)==0 then
      if (entity.frame<#animation.frames) then
        entity.frame+=1
      elseif animation.loop then
        entity.frame=1
      end
    end

    entity.sprite=animation.frames[entity.frame]
  end
end

function merge(tables)
  local result={}

  for t in all(tables) do
    for k,v in pairs(t) do
      if (type(result[k])=="table" and type(v)=="table") then
        result[k]=merge({result[k],v})
      else
        result[k]=v
      end
    end
  end

  return result
end

function add_points(pts)
  points=pts
  points_y=16
  score+=points
end

function transparent(callback)
  if transparency_enabled == 0 or show_transparent then
    callback()
  end
end

function mcpy(dest,src)
  for i=0,319,4 do
    poke4(dest+i,peek4(src+i))
  end
end

function sprint(text,x,y,col,factor)
  poke(0x4580,peek(0x5f00+col))
  poke2(0x4581,peek2(0x5f00))
  poke4(0x4583,peek4(0x5f28))
  poke2(0x4587,peek2(0x5f31))
  poke(0x4589,peek(0x5f33))
  poke(0x5f00+col,col)
  poke2(0x5f00,col==0 and 0x1100 or 0x0110)
  mcpy(0x4440,0x0)
  mcpy(0x0,0x6000)
  camera()
  fillp(0)
  rectfill(0,0,127,4,(16-peek(0x5f00))*0x0.1)
  print(text,0,0,col)
  mcpy(0x4300,0x6000)
  mcpy(0x6000,0x0)
  mcpy(0x0,0x4300)
  camera(peek2(0x4583),peek2(0x4585))
  sspr(0,0,128,5,x,y,128*factor,5*factor)
  mcpy(0x0,0x4440)
  poke(0x5f00+col,peek(0x4580))
  poke2(0x5f00,peek2(0x4581))
  fillp(peek2(0x4587)+peek(0x4589)*0x.8)
end

function action()
  return btnp(🅾️) or btnp(❎)
end

function create_dust(opts)
  opts = opts or {}

  local x = opts.x
  local y = opts.y
  local dx = opts.dx or 0
  local dy = opts.dy or 0
  local life = opts.life or 15
  local count = opts.count or 10
  local d = opts.d or 2

  for i=1,10 do
    local pdx = (dx + (rnd(0.5) - 0.25) * max(1,d)) or (rnd() - 1)
    local pdy = (dy + (rnd(0.5) - 0.25) * max(1,d)) or (rnd() - 1)

    add(particles, create_particle({
      x = x,
      y = y,
      vx = pdx,
      vy = pdy,
      d = rnd(d),
      life = life + rnd(30) - 15,
      c = opts.c
    }))
  end
end

function create_particle(opts)
  opts = opts or {}

  local x = opts.x
  local y = opts.y
  local vx = opts.vx or 0
  local vy = opts.vy or -1
  local d = opts.d or 1
  local c = opts.c or 7
  local life = opts.life or 15

  return {
    life = life,
    x = x,
    y = y,
    vx = vx,
    vy = vy,
    d = d,

    update = function(self)
      self.x += self.vx
      self.y += self.vy
      self.life -= 1
      self.vy += .025
      self.vx *= .95
      self.vy *= .95
      self.d *= .95

      if self.life <= 0 then
        del(particles, self)
      end
    end,

    draw = function(self)
      transparent(function()
        circfill(self.x, self.y, self.d, c)
      end)
    end
  }
end

function draw_bg_building(x,y)
  local windows=0

  rectfill(x,y,x+12,128,3)

  for wx=x+1,x+7,6 do
    for wy=y,y+24,8 do
      if rnd()>.8 then
        rectfill(wx+1,wy+2,wx+3,wy+6,6)
        rectfill(wx+2,wy+3,wx+2,wy+5,7)
      end
    end
  end
end

function draw_x_button(x,y)
  x = x or 58
  y = y or 106

  circfill(x,y,5,13)
  circfill(x,y-1,5,9)
  line(x-2,y-3,x+2,y+1,13)
  line(x+2,y-3,x-2,y+1,13)
  line(x-2,y-2,x+2,y+2,7)
  line(x+2,y-2,x-2,y+2,7)
end

function initialize_eyes()
  eye_pos=0
  eye_speed=.85
  eye_frames={
    {{58,74},{54,74},{58,74}}, -- white
    {{67,83},{58,80},{67,81}}, -- left eye
    {{73,83},{68,81},{76,81}}, -- right eye
  }
  eyes={
    {eye_frames[1][1][1], eye_frames[1][1][2]},
    {eye_frames[2][1][1], eye_frames[2][1][2]},
    {eye_frames[3][1][1], eye_frames[3][1][2]},
  }
end

function update_eye_position()
  eye_pos+=1

  if eye_pos>#eye_frames then
    eye_pos=1
  end

  set_timer(120, update_eye_position)
end

function draw_character(y)
  y = y or 62


  local offset=flr(sin(time()*.8)*1.5)
  sspr(0,96,32,32,48,y+offset,32,32-offset)

  eyes={
    {
      lerp(eyes[1][1],eye_frames[1][eye_pos][1],eye_speed),
      lerp(eyes[1][2],eye_frames[1][eye_pos][2],eye_speed)
    },
    {
      lerp(eyes[2][1],eye_frames[2][eye_pos][1],eye_speed),
      lerp(eyes[2][2],eye_frames[2][eye_pos][2],eye_speed)
    },
    {
      lerp(eyes[3][1],eye_frames[3][eye_pos][1],eye_speed),
      lerp(eyes[3][2],eye_frames[3][eye_pos][2],eye_speed)
    },
  }

  local eye_offset=flr(offset/2)
  spr(228,eyes[1][1],eyes[1][2]+eye_offset,3,2)
  circfill(eyes[2][1],eyes[2][2]+eye_offset,2,0)
  pset(eyes[2][1]+1,eyes[2][2]-1+eye_offset,7)
  circfill(eyes[3][1],eyes[3][2]+eye_offset,2,0)
  pset(eyes[3][1]+1,eyes[3][2]-1+eye_offset,7)
end

function create_cloud(x,y,speed,scale)
  clouds = clouds or {}

  add(clouds, {
    x=x or flr(rnd(8))*16,
    y=y or 8+(rnd(3)*16),
    speed={
      x=speed or -1*(rnd()/10)
    },
    scale=scale or 1
  })
end

function draw_clouds()
  for cloud in all(clouds) do
    if abs(cloud.scale) >= 2 then
      transparent(function()
        draw_cloud(cloud, 6)
      end)
    else
      draw_cloud(cloud, 6, 0, 1)
      draw_cloud(cloud)
    end
  end
end

function draw_cloud(cloud, color, offset_x, offset_y)
  color = color or 7
  offset_x = offset_x or 0
  offset_y = offset_y or 0

  local x,y,scale = cloud.x, cloud.y, cloud.scale

  circfill(x + (offset_x * scale), y + (offset_y * scale), 3 * scale, color)
  circfill(x + (6 * scale) + (offset_x * scale), y + (offset_y * scale), 4 * scale, color)
  circfill(x + (8 * scale) + (offset_x * scale), y - 4 + (offset_y * scale), 4 * scale, color)
  circfill(x + (10 * scale) + (offset_x * scale), y + (offset_y * scale), 5 * scale, color)
  circfill(x + (13 * scale) + (offset_x * scale), y + (offset_y * scale), 2 * scale, color)
  circfill(x + (16 * scale) + (offset_x * scale), y + (offset_y * scale), 3 * scale, color)
end

function draw_buildings()
  -- bg buildings
  local offsets={0,18,24,36,24,42,16,40,24,0,10}
  for i=1,10 do
    local x=(i-1)*13
    local y=48+offsets[i]
    draw_bg_building(x,y)
  end

  -- fg buildings
  rectfill(0,70,28,76,5)
  rectfill(0,77,26,78,15)
  rectfill(0,79,26,128,4)

  rectfill(98,74,128,80,5)
  rectfill(100,81,128,82,15)
  rectfill(100,83,128,128,4)

  spr(198,4,82,1,2)
  spr(198,16,82,1,2)
  spr(198,4,104,1,2)
  spr(198,16,104,1,2)

  spr(198,104,86,1,2)
  spr(198,116,86,1,2)
  spr(198,116,108,1,2)

  -- close building
  for w=48,112,2 do
    local x=64-(w/2)
    local y=84+((w-48)/2)
    rectfill(x,y,x+w,y,5)
  end

  rectfill(8,117,120,125,12)
  rectfill(12,126,116,128,15)

  palt(0,false)
  palt(15,true)
end

function printc(str,y,c,c2)
  y = y or 64
  c = c or 7
  c2 = c2 or 6
  local x = 64-flr((#str * 4) / 2)

  print(str, x, y+1, c2)
  print(str, x, y, c)
end

function draw_score_ui()
  if max_level_id >= #levels then
    local total_stars = 0
    local total_score = 0

    for i=1,#levels do
      local data = tostr(dget(i))
      total_stars += tonum(sub(data,1,1))
      total_score += tonum(sub(data,2)) or 0
      exit()
    end

    local score_string = tostr(total_score)

    print("stars: ", 11, 119, 7)
    print(total_stars .."/" .. #levels * 3, 36, 119, 6)
    print(score_string, 119 - #score_string * 4, 119, 6)
    print("score: ", 119 - (#score_string + #"score: ") * 4, 119, 7)
  end
end