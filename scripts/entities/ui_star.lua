ui_star={
  new=function(self,x,y)
    return create_entity(0,{
      type="ui_star",

      x=x,
      y=y,
      width=16,
      height=16,

      animations={
        idle={
          frames={4},
        },
        collected={
          frames={4,6,34,36,38},
          loop=false,
        }
      },

      init=function(self)
        self:animate("idle")
      end,

      update=function(self)

      end,

      draw=function(self)
        spr(self.sprite,cam.x+self.x,cam.y+self.y,2,2)
      end
    })
  end
}