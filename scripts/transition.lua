transition={
  y=-192,
  color=11,
  speed=.92,
  running=false,
  executed=false,
  target=192,

  init=function(self)
    self.drips={}

    for i=15,0,-1 do
      add(self.drips, {
        x=i*8,
        y=flr(rnd(24))
      })
    end
  end,

  animate=function(self, callback, target, reset)
    if (reset == true or reset == nil) then
      self.y = -192
    end

    self.running=true
    self.executed=false
    self.callback=callback
    self.target=target or 192

    input_enabled = false

    if self.target == 192 then
      sfx(31)
    end
  end,

  update=function(self)
    if self.running then
      if abs(self.target-self.y) <= 1 then
        self.y=self.target
      elseif (self.executed or self.y<self.target/2) then
        self.y=lerp(self.y,self.target,self.speed)
      end

      if self.y >= -192+((self.target+192)/2) and not self.executed then
        self.executed=true

        if (self.callback) then
          self.callback()
        end
      end

      if self.y >= self.target then
        self.running=false
        input_enabled = true
      end
    end
  end,

  draw=function(self)
    for drip in all(self.drips) do
      circfill(cam.x+drip.x+4,cam.y+self.y-drip.y,4,self.color)
      circfill(cam.x+drip.x+4,cam.y+self.y+128+drip.y,4,self.color)
      rectfill(cam.x+drip.x,cam.y+self.y-drip.y,cam.x+drip.x+8,cam.y+self.y+128+drip.y,self.color)
    end
  end
}
