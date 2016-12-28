local  upscalingFactor = 3--2
local  screenWidth = 144--256*2--256 
local  centerScreenX = screenWidth / 2
local  screenHeight = 144--144*2--144 
local  centerScreenY = screenHeight / 2
local  polyTable =  { -4 ,  2 ,
                       0 ,  6 ,
                       4 ,  2 }
                     
function love.load()
  Object = require "classic"
  require "buttonClass"
  
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  
  local fontSize = 16
  love.graphics.setFont(love.graphics.newFont("m5x7.ttf", fontSize))
  
  love.graphics.setLineStyle("rough")
  
  love.graphics.setPointSize(2)
  
  --Set windows size accordingly to upscalingFactor: 
    love.window.setMode(screenWidth * upscalingFactor,
                        screenHeight * upscalingFactor)
                      
  --Create Canvas so I can draw everything on it and then upscale it as 
  --I want to. Then set filter to nearest:
    canvas = love.graphics.newCanvas(screenWidth, screenHeight)
    
  for i = 1, #polyTable, 2 do
    polyTable[i]    = polyTable[i]    + centerScreenX
    polyTable[i+1]  = polyTable[i+1]  + centerScreenY
  end
  
  --opens the given file (in read mode) and sets it as the current output file:
  io.output("save.txt")

  --CREATE BUTTONS:
  local width = 40
  local height = 10
  save = Button(screenWidth - width, 2, width, height, "save")
end

function love.update(dt)
  save:update(dt)
end

function love.draw()
  --Set the draw target to the canvas
  love.graphics.setCanvas(canvas)
  --Is necesary to clear the screen because the canvas will still have what
  --was draw on it during the past frame:
  love.graphics.clear()
------------------------------------------------------
  
  mouseX = math.floor( love.mouse.getX() / upscalingFactor )
  mouseY = math.floor( love.mouse.getY() / upscalingFactor )
  xTrans = mouseX - centerScreenX
  yTrans = mouseY - centerScreenY

  love.graphics.line(0, mouseY, screenWidth, mouseY)  --x line
  love.graphics.print("Y = " .. yTrans , 0, mouseY)
  love.graphics.line(mouseX, 0, mouseX, screenHeight) --y line
  love.graphics.print(" X = " .. xTrans , mouseX, 0)
  
  love.graphics.polygon("line", polyTable)
  love.graphics.setColor(0, 0, 255)
  love.graphics.points(centerScreenX, centerScreenY)
  love.graphics.setColor(127, 0, 127)
  love.graphics.points(polyTable)
  love.graphics.setColor(255, 255, 255)
  
  --DRAW BUTTONS
  save:draw()
  
------------------------------------------------------
  --This sets the target back to the screen.
  --(Once you draw on the offscreen canvas, you have to draw the canvas
  --on the visible screen)
    love.graphics.setCanvas() 
  --DRAW UPSCALED CANVAS.
    love.graphics.draw(canvas, 0, 0, 0, upscalingFactor, upscalingFactor)
end

function love.mousepressed()
  if save:mousepressed() then
    io.write("{ ")
    
    for i = 1, #polyTable - 2, 2 do
      io.write(      polyTable[i]    - centerScreenX,
              ", ",  polyTable[i+1]  - centerScreenY, ", ")
    end
    
    io.write(     polyTable[#polyTable - 1]  - centerScreenX,
            ", ", polyTable[#polyTable]      - centerScreenY, " }\n") 
            
  else
    table.insert(polyTable, mouseX)
    table.insert(polyTable, mouseY)
  end
end

function love.keypressed()
  love.event.quit()
end