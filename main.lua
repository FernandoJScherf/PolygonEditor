local  upscalingFactor = 3--2
local  screenWidth = 144--256*2--256 
local  centerScreenX = math.floor(screenWidth / 3)--screenWidth / 2
local  screenHeight = 144--144*2--144 
local  centerScreenY = screenHeight / 2--screenHeight / 2
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

local selectedI = 0
function love.draw()
  --Set the draw target to the canvas
  love.graphics.setCanvas(canvas)
  --Is necesary to clear the screen because the canvas will still have what
  --was draw on it during the past frame:
  love.graphics.clear()
------------------------------------------------------
  
  mouseX = math.floor( (love.mouse.getX() / upscalingFactor) )
  mouseY = math.floor( (love.mouse.getY() / upscalingFactor) )
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
  
  love.graphics.setColor(255,0,0) --Mark the last point in table.
  love.graphics.points(polyTable[#polyTable-1],polyTable[#polyTable])
  love.graphics.setColor(0,255,0) --Mark the first point in table.
  love.graphics.points(polyTable[1],polyTable[2])
  
  love.graphics.setColor(127, 127, 127)
  
  local y = 16
  for i = 1, #polyTable, 2 do
    love.graphics.print(polyTable[i] - centerScreenX, screenWidth - 40, y)
    --love.graphics.line(screenWidth - 15, y + 5, screenWidth - 15, y + 10)
    love.graphics.print(";", screenWidth - 25, y)
    love.graphics.print(polyTable[i+1] - centerScreenY, screenWidth - 20, y)
    y = 20 + 4 * i
  end
  love.graphics.setColor(255, 255, 255)
  
  if selectedI == 0 then
    love.graphics.print("No point.", screenWidth - 50, y)
  else
    love.graphics.print(polyTable[selectedI] - centerScreenX,
      screenWidth - 40, y)
    love.graphics.print(polyTable[selectedI+1] - centerScreenY,
      screenWidth - 20, y)
  end
  
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

  
function love.mousepressed(x, y, button)
  if save:mousepressed() then
    io.write("{ ")
    
    for i = 1, #polyTable - 2, 2 do
      io.write(      polyTable[i]    - centerScreenX,
              ", ",  polyTable[i+1]  - centerScreenY, ", ")
    end
    
    io.write(     polyTable[#polyTable - 1]  - centerScreenX,
            ", ", polyTable[#polyTable]      - centerScreenY, " }\n")
    return
  end
  
  if button == 1 then               --Left Click: New Point
    if selectedI == 0 then  --An index table goes from 1, so it will never be
                            --0 unless we have not selected a point.
      table.insert(polyTable, mouseX)
      table.insert(polyTable, mouseY)
    else
      table.remove(polyTable, selectedI)
      table.remove(polyTable, selectedI)
      table.insert(polyTable, selectedI, mouseX)
      table.insert(polyTable, selectedI + 1, mouseY)
      selectedI = 0
      return
    end    
  elseif button == 2 then          --Right Click: Select Point.
    for i = 1, #polyTable, 2 do
      --if mouseX == polyTable[i] and mouseY == polyTable[i+1] then
      if math.abs(mouseX - polyTable[i]) < 3 and
         math.abs(mouseY - polyTable[i+1]) < 3 then
        selectedI = i
        return
      end
    end
  elseif button == 3 then          --Middle Click: Delete
    for i = 1, #polyTable, 2 do
      if math.abs(mouseX - polyTable[i]) < 3 and
         math.abs(mouseY - polyTable[i+1]) < 3 then
        if #polyTable > 6 then --If more than three vertices
          table.remove(polyTable, i)
          table.remove(polyTable, i)
          return
        end
      end
    end
  end
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "up" then
    table.insert(polyTable, 1, polyTable[#polyTable]) --Rotate table
    table.remove(polyTable, #polyTable)
    table.insert(polyTable, 1, polyTable[#polyTable])
    table.remove(polyTable, #polyTable)
  elseif key == "down" then
    table.insert(polyTable, polyTable[1]) --Rotate table
    table.remove(polyTable, 1)
    table.insert(polyTable, polyTable[1])
    table.remove(polyTable, 1)
  elseif key == "delete" and #polyTable > 6 then --If more than three vertices
    table.remove(polyTable)
    table.remove(polyTable)
  end
end