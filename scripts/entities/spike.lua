spike={
  new=function(self,x,y,sprite)
    sprite = sprite or 83
    
    create_entity(0,{
      type="spike",

      x=x,
      y=y,
      width=8,
      height=8,
      sprite=sprite,

      hitbox = {
        x = 0,
        y = 2,
        width = 8,
        height = 6
      },

      init=function(self)
        if self.sprite == 82 then
          self.hitbox = { x = 4, y = 3, width = 8, height = 5 }
        elseif self.sprite == 84 then
          self.hitbox = { x = 0, y = 3, width = 5, height = 5 }
        end
      end,

      draw=function(self)
        spr(self.sprite,self.x,self.y)
      end
    })
  end
}
