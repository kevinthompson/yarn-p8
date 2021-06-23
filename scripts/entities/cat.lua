cat={
  new=function(self,x,y)
   create_entity(2,{
    type="cat",

    x=x,
    y=y-8,
    z=1,
    width=16,
    height=16,

    hitbox = {
      x = 0,
      y = 0,
      width = 16,
      height = 16
    },

    animations={
      idle={
        frames={2},
      }
    },

    init=function(self)
      self:animate("idle")
    end,

    draw=function(self)
      spr(self.sprite,self.x,self.y,2,2)
    end,

    die=function(self)
      sfx(27)
      sfx(26)
      --dust:new(self.x,self.y)
      pow:new(self.x+2, self.y+2)
      self:destroy()
    end
   })
  end
 }