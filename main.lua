settings = {
    resolution = { 1024, 768 }
  }

anim8 = require "anim8"

scenes = require "scenes"

function love.load()
  
  scenes:create("overworld", {
      fnInit = function () end
      ,fnUpdate = function (dt) end
      ,fnDraw = function () end
      ,fnKeyPress = function (key, scancode) end
    })
end

function love.draw()
  
end

function love.update(dt)
  
end