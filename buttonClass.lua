Button = Object:extend()

function Button:new(x, y, width, height, name)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.name = name
end

local modeDraw = "line"
local time = 0
function Button:update(dt)
  if modeDraw == "fill" then
    
    if time < 0.2 then
      time = time + dt
    else
      modeDraw = "line"
      time = 0
    end
  end
end

function Button:draw()
  love.graphics.rectangle(modeDraw, self.x, self.y,
                          self.width-1, self.height-1)
  love.graphics.print(self.name, self.x + 2, self.y + 1 - self.height/2)
  --modeDraw = "line"
end

function Button:mousepressed()
  local buttonPressed = false
  if  mouseX > self.x and mouseX < (self.x + self.width)  and
      mouseY > self.y and mouseY < (self.y + self.height) then
    buttonPressed = true
    modeDraw = "fill"
  end    
  return buttonPressed
end