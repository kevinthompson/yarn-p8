star={
  new=function(self,x,y)
    create_entity(2,{
      type="star",

      x=x,
      y=y,
      width=8,
      height=8,
      animations={
        idle={
          fps=6,
          frames={17,33,49,49,33},
          loop=true,
        }
      },

      init=function(self)
        self:animate("idle")
      end,

      update=function(self)

      end,

      draw=function(self)
        local offset=self.frame>3 and -1 or 0
        spr(self.sprite,self.x+offset,self.y,1,1,self.frame>3)
      end
    })
  end
}