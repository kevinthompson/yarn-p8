title={
  init=function(self)
    cam={x=0,y=0}

    pal()
    pal(3,129,1)
    pal(10,135,1)
    pal(11,138,1)
    pal(12,133,1)
    pal(13,137,1)
    pal(14,136,1)
    pal(15,132,1)

    set_menu_items({
      {
        1, "reset progress", function()
          reset_cart_data()
          load_cart_data()
        end
      }
    })

    clouds = {}
    for i=1,8 do
      create_cloud()
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
    spr(196,6,54,2,2)
    spr(196,100,58,2,2,true)

    -- logo
    spr(151,28,6,9,7)

    -- character
    draw_character()

    -- prompt
    draw_x_button(58, 106)
    print("press",30,104,3)
    print("press",30,103,7)
    print("to start",68,104,3)
    print("to start",68,103,7)

    draw_score_ui()

    palt()
  end
}