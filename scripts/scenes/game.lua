game={
  winning=false,

  init=function(self)
    self:reset_palette()
    self.win_word=""
    particles = {}

    set_menu_items({
      {
        1, "restart level", function()
          self:init()
        end
      },
      {
        1, "return to world", function()
          transition:animate(function()
            load_scene(world)
          end)
        end
      }
    })

    load_level(level_id)
    state=states.ready
    cam={x=0,y=0}
    new_high_score = false

    self.winning=false
  end,

  update=function(self)
    local target=self.player or {x=cam.x, y=cam.y, speed={ x=0 }}

    state.update(self)

    each_entity(function(entity)
      entity:update()
      animate(entity)
    end)

    for particle in all(particles) do
      particle:update()
    end

    points_y=lerp(points_y, 32, .98)

    cam={
      x=lerp(cam.x,mid(0,flr(target.x-64+(sgn(target.speed.x)*32)),(level_width*8)-128),.95),
      y=lerp(cam.y,mid(0,flr(target.y-64),(level_height*8)-128),.95)
    }
  end,

  draw=function(self)
    cls(1)
    rectfill(8,8,(level_width * 8) - 8, (level_height * 8) - 8, 12)

    for x=8, (level_width * 8) - 8, 8 do
      for y=8, (level_height * 8) - 8, 8 do
        spr(73,x,y)
      end
    end

    map(0,0,0,0,level_width,level_height)

    for particle in all(particles) do
      particle:draw()
    end

    each_entity(function(entity)
      entity:draw()
    end)

    state.draw(self)
  end,

  draw_interface=function(self)
    self:draw_top_interface()
    self:draw_bottom_interface()
  end,

  draw_top_interface=function(self)
    local y=4

    for star in all(ui_stars) do
      star:draw()
    end

    transparent(function()
      if points > 0 and points_y < 26 then
        local point_str="+"..tostr(points)
        print(point_str,cam.x+121-(#tostr(point_str)*4),cam.y+points_y,6)
      end
    end)

    print("score",cam.x+101,cam.y+y+5,3)
    print("score",cam.x+101,cam.y+y+4,6)
    print(score,cam.x+121-(#tostr(score)*4),cam.y+y+13,3)
    print(score,cam.x+121-(#tostr(score)*4),cam.y+y+12,7)
  end,

  draw_bottom_interface=function(self)
    local y=107

    if high_score > 0 and not new_high_score then
      print("high score",cam.x+8,cam.y+y+1,3)
      print("high score",cam.x+8,cam.y+y,6)
      print(high_score,cam.x+8,cam.y+y+9,3)
      print(high_score,cam.x+8,cam.y+y+8,7)
    end
  end,

  draw_prompt=function(self)
    local prompt = prompts[level_id] or "press ❎ to start"
    rectfill(cam.x,cam.y+88,cam.x+128,cam.y+101,0)
    print(prompt,cam.x+8,cam.y+93,5)
    print(prompt,cam.x+8,cam.y+92,7)
  end,

  reset_palette=function(self)
    pal()
    pal(0,129,1)
    pal(1,141,1)
    pal(2,136,1)
    pal(3,130,1)
    pal(11,138,1)
    pal(14,140,1)
    pal(5,13,1)
    pal(13,137,1)
    pal(15,143,1)
  end
}

states={
  ready={
    update=function(self)
      if action() then
        state=states.playing
        game.player.speed.x=.65
      end
    end,

    draw=function(self)
      self:draw_interface()
      self:draw_prompt()
    end
  },

  playing={
    update=function(self)
      local player=game.player
      score=max(0, score-1)

      if action() and player.jump_available then
        player:jump()
      elseif not btn(❎) then
        player.jump_available=true
      end

      each_entity(function(entity,layer)
        if entity~=game.player and collide(game.player,entity) then
          if entity.type=="star" then
            del(entities[layer], entity)
              stars+=1
            sfx(star_sounds[stars])
            sfx(32)
            sfx(34)
            add_points(100)
            ui_stars[stars]:animate("collected")
            create_dust({
              x = entity.x + 3,
              y = entity.y + 3,
              dy = -1,
              d = 3,
              c = 10
            })
          elseif entity.type=="cat" then
            state=states.win
            create_dust({
              x = entity.x + 8,
              y = entity.y + 8,
              d = 4
            })
            shake(.15)
            entity:die()
            del(entities[layer], entity)
          elseif fget(entity.sprite,2) then
            state=states.lose
            shake()
            sfx(26)
            score = 0
            player:destroy()

            create_dust({
              x = entity.x + 3,
              y = entity.y + 3,
              dy = -1,
              d = 4,
            })

            set_timer(30, function()
              game:init()
            end)
          end
        end
      end)
    end,

    draw=function(self)
      self:draw_interface()
    end
  },

  lose={
    update=function(self)

    end,

    draw=function(self)
      self:draw_interface()
    end
  },

  win={
    update=function(self)
      if not self.winning then
        local words={"oh yeah", "fantastic", "brilliant", "wonderful", "woot", "swell", "nice", "awesome", "super", "great", "wow", "pawsome"}

        self.win_word=rnd(words)
        self.winning=true

        input_enabled = false
        set_timer(30, function()
          transition:animate(function()
            win_screen_target_y=0
          end, -128)
        end)

        if score>high_score then
          high_score = score
          new_high_score = true
        end

        dset(level_id, tonum(min(3, max(stars, prev_stars))..score))

        if level_id>=max_level_id then
          max_level_id=level_id+1
          dset(63,max_level_id)
        end
      end

      win_screen_y=lerp(win_screen_y, win_screen_target_y, .90)

      if win_screen_y >= 0 then
        input_enabled = true
      end

      game.player.speed.x *= .95

      if input_enabled then
        if btnp(0) then
          menu_id = max(1, menu_id - 1)
        end

        if btnp(1) then
          menu_id = min(3, menu_id + 1)
        end

        if action() then
          transition:animate(function()
            if menu_id == 3 then
              if level_id < #levels then
                level_id+=1
                self:init()
              else
                load_scene(ending)
              end
            elseif menu_id == 2 then
              self:init()
            elseif menu_id == 1 then
              if level_id < #levels then
                level_id+=1
              end

              load_scene(world)
            end
          end, 192, false)
        end
      end
    end,

    draw=function(self)
      local x = cam.x
      local y = cam.y + win_screen_y

      self:draw_interface()

      rectfill(x + 4, y , x + 123, y + 116, 0)
      rectfill(x + 12, y + 101, x + 115, y + 123, 0)

      palt(0, false)
      palt(11, true)
      spr(1,x + 4, y + 116, 1, 1, false, true)
      spr(1,x + 116, y + 116, 1, 1, true, true)
      palt()

      pal(11, 0)
      for i=stars + 1,3 do
        spr(74, x + 22 + ((i - 1) * 30), y + 50, 3, 3)
      end

      pal(11, 10)
      pal(6, 10)
      for i=1,stars do
        spr(74, x + 22 + ((i - 1) * 30), y + 50, 3, 3)
      end
      self:reset_palette()

      local high_score_text= new_high_score and "new high score!" or "high score: " .. high_score
      sprint(self.win_word, x + 64 - ((#self.win_word/2) * 8), y + 35, 5, 2)
      sprint(self.win_word, x + 64 - ((#self.win_word/2) * 8), y + 34, 7, 2)
      print(score, x + 64 - ((#tostr(score)/2) * 4), y + 81, 5)
      print(score, x + 64 - ((#tostr(score)/2) * 4), y + 80, 7)
      print(high_score_text, x + 64 - ((#high_score_text/2) * 4), y + 89, 6)

      draw_button(x + 40, y + 107, function(x,y) spr(135,x,y) end, menu_id == 1)
      draw_button(x + 64, y + 107, function(x,y) spr(136,x,y) end, menu_id == 2)
      draw_button(x + 88, y + 107, function(x,y) spr(137,x,y) end, menu_id == 3)
    end
  }
}