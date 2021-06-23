saw={
  new=function(self,x,y,d)
    d = d or 'up'

    local hitbox = {}
    local frames = {}
    local flipx = false
    local flipy = false

    if d == 'right' then
      hitbox = { x = 0, y = 1, width = 5, height = 6 }
      frames = { 104, 105, 120 }
    elseif d == 'down' then
      hitbox = { x = 1, y = 0, width = 6, height = 5 }
      frames = { 99, 100, 115 }
      flipy = true
    elseif d == 'left' then
      hitbox = { x = 3, y = 1, width = 5, height = 6 }
      frames = { 104, 105, 120 }
      flipx = true
    else
      hitbox = { x = 1, y = 3, width = 6, height = 5 }
      frames = { 99, 100, 115 }
    end

    create_entity(0,{
      type="saw",

      x=x,
      y=y,
      z=1,
      width=8,
      height=8,
      sprite=99,
      hitbox = hitbox,

      animations={
        idle={
          fps=30,
          frames=frames,
          loop=true
        }
      },

      init=function(self)
        self:animate("idle")
      end,

      draw=function(self)
        palt(0,false)
        palt(11,true)
        spr(self.sprite, self.x, self.y, 1, 1, flipx, flipy)
        palt()
      end
    })
  end
}
