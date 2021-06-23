player={
  new=function(self,x,y)
    local prev_pos={}
    for i=1,6 do
      prev_pos[i]={x=x, y=y}
    end

    return create_entity(1,{
      type="player",

      x=x,
      y=y,
      width=8,
      height=8,
      ground=true,
      wall=true,
      flip=false,

      prev_pos=prev_pos,

      speed={
        x=0,
        y=0
      },

      hitbox = {
        x=1,
        y=1,
        width=6,
        heght=7
      },

      animations={
        idle={
          fps=1,
          frames={48},
        },
        jump={
          fps=6,
          frames={16,32,48},
        }
      },

      sprite=48,

      init=function(self)
        self:animate("idle")
      end,

      update=function(self)
        if frame%2==0 then
          for i=1,#self.prev_pos-1 do
            self.prev_pos[i]=self.prev_pos[i+1]
          end

          self.prev_pos[#self.prev_pos]={ x=self.x, y=self.y }
        end

        if (self.wall and self.speed.y>0) then
          self.speed.y=.33
        else
          self.speed.y+=gravity
        end

        if self.speed.x<0 then
          self.flip=true
        else
          self.flip=false
        end

        self:resolve_map_collision()
        self:detect_ground()
        self:detect_wall()
      end,

      draw=function(self)
        transparent(function()
          for i=1, #self.prev_pos do
            local pos=self.prev_pos[i]
            local r=ceil(((i-1)/#self.prev_pos)*2)
            circfill(pos.x+4, pos.y+7-r, r, 7)
          end
        end)

        palt(0, false)
        palt(11, true)
        spr(self.sprite,self.x,self.y,1,1,self.flip)
        palt()
      end,

      jump=function(self)
        local sounds={21,22,23}
        local jump_sound=rnd(sounds)

        if self.ground and self.wall then
          self:animate("jump")
          self.speed.y=-1.125
          self.jump_available=false
          sfx(jump_sound)
        elseif self.ground then
          self:animate("jump")
          self.speed.y=-1.35
          self.jump_available=false
          sfx(jump_sound)
        elseif self.wall then
          self.speed.y=-1.35
          self.speed.x*=-1
          self.jump_available=false
          sfx(jump_sound)
        end
      end,

      resolve_map_collision=function(self)
        local speed=self.speed
        local max_speed=max(abs(speed.x),abs(speed.y))
        local steps=ceil(max_speed/8)

        for step=1,steps do
          if speed.x~=0 then
            self.x+=speed.x/steps
            self:on_map_collision(function(tile)
              self.x=tile.x-(8*sgn(speed.x))
            end)
          end

          if speed.y~=0 then
            self.y+=speed.y/steps
            self:on_map_collision(function(tile)
              self.y=tile.y-(8*sgn(speed.y))
              self.speed.y=0
            end, self.speed.y > 0)
          end
        end
      end,

      on_map_collision=function(self,callback,include_semi_solid)
        local x,y,width,height=self.x,self.y,self.width,self.height

        for tile in all(tiles(x,y,x+width-1,y+height-1)) do
          local solid = fget(tile.sprite,0)
          local semi_solid = include_semi_solid and flr(self.prev_pos[#self.prev_pos].y + self.height) <= tile.y and fget(tile.sprite,2)
          local collision = solid or semi_solid

          if collision then
            callback(tile)
            break
          end
        end
      end,

      detect_ground=function(self)
        local was_ground=self.ground
        self.ground=false

        for tile in all(tiles(self.x,self.y+8,self.x+7,self.y+8)) do
          if fget(tile.sprite,0) or fget(tile.sprite,2) then
            if (not was_ground) self:impact({ x = self.x + 3 })
            self.ground=true
            self:animate("idle")
            break
          end
        end
      end,

      detect_wall=function(self)
        local was_wall=self.wall
        self.wall=false
        local offset=self.speed.x>0 and 8 or -1

        for tile in all(tiles(self.x+offset,self.y,self.x+offset,self.y+7)) do
          if fget(tile.sprite,0) then
            if (not was_wall) then
              self:impact({
                x = (self.flip and self.x or (self.x + self.width)),
                y = self.y + 6,
              })
            end

            self.wall=true
            break
          end
        end
      end,

      impact = function(self, opts)
        opts = opts or {}

        local x = opts.x or (self.x + (self.flip and self.width or 0))
        local y = opts.y or self.y + self.height
        local dx = opts.dx
        local dy = opts.dy

        create_dust({
          x = x,
          y = y,
          dx = dx,
          dy = dy,
          life = 30
        })

        sfx(25)
      end
    })
  end
}