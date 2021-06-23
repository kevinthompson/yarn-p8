ending={
  init=function(self)
    cam={x=0,y=0}

    pal()
    pal(3,129,1)
    pal(10,135,1)
    pal(11,13,1)
    pal(12,133,1)
    pal(13,137,1)
    pal(14,136,1)
    pal(15,132,1)

    clouds = {}
    for i=1,8 do
      create_cloud(nil, rnd(2) * 16)
    end

    initialize_eyes()
    update_eye_position()
  end,

  update=function(self)
    if action() then
      transition:animate(function()
        load_scene(world)
      end)
    end

    for cloud in all(clouds) do
      cloud.x+=cloud.speed.x

      if cloud.x < -24 then
        cloud.x=136
      end
    end
  end,

  draw=function(self)
    srand(seed)
    cls(1)

    -- moon
    circfill(16,56,32,10)

    draw_clouds()
    draw_buildings()

    -- cats
    spr(77,4,54,2,2)
    spr(77,100,58,2,2,true)

    draw_character(68)

    -- prompt
    draw_x_button(52, 108)
    print("press",24,106,3)
    print("press",24,105,7)
    print("to continue",62,106,3)
    print("to continue",62,105,7)

    for i=1,3 do
      local x = 8 + sin((time() - (i * .75))/2) * 3
      local y = 60 + cos((time() - (i * .75))/2)
      pset(x, y, 10)
    end

    for i=1,3 do
      local x = 112 + sin((time() - (i * .75))/2) * 3
      local y = 64 + cos((time() - (i * .75))/2)
      pset(x, y, 10)
    end

    rectfill(16,12,111,45,3)

    for i=16,104,8 do
      spr(121,i,6)
      spr(121,i,44,1,1,false,true)
    end

    for i=12,40,8 do
      spr(122,8,i)
      spr(122,112,i,1,1,true,false)
    end

    spr(123,112,40)
    spr(123,9,42,1,1,true)
    spr(123,9,10,1,1,true,true)
    spr(123,112,10,1,1,false,true)

    printc("you've won... for now.", 16, 7, 11)
    printc("play more on ios at:", 28, 6, 1)
    printc("https://is.gd/yarngame", 36, 7, 1)

    draw_score_ui()

    palt()
  end
}