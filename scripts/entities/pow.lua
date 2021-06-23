pow={
  new=function(self,x,y)
   create_entity(0,{
    type="pow",

    x=x,
    y=y,
    width=16,
    height=16,

    init=function(self)
      self.frame=0
    end,

    update=function(self)
      self.frame+=1
    end,

    draw=function(self)
      palt(0, false)
      palt(11, true)

      if self.frame < 4 then
        if frame%2==0 then
          spr(69,self.x+4,self.y+4)
        end
      elseif self.frame < 8 then
        if frame%2==0 then
          spr(70,self.x+4,self.y+4)
        end
      else
        spr(71,self.x,self.y,2,2)
      end

      palt()
    end,
   })
  end
 }
