-- Global Variables
settings = {
    resolution = { 1024, 768 }
  }

-- Modules
anim8 = require "anim8"
scenes = require "scenes"

-- ******************************
--  LOAD
-- ******************************
function love.load()
  

  font = love.graphics.newFont(12)
  fontheader1 = love.graphics.newFont(24)
  love.graphics.setFont(font)

  love.physics.setMeter(1000)
  world = love.physics.newWorld(world, 0, 0, true)

  
  scenes:create("overworld", {
      fnInit = function () end
      ,fnUpdate = function (dt) end
      ,fnDraw = function () end
      ,fnKeyPress = function (key, scancode) end
    })
end

-- ******************************
--  DRAW
-- ******************************
function love.draw()
  scenes:draw()
end

-- ******************************
--  UPDATE
-- ******************************
function love.update(dt)
   scenes:update(dt)
end