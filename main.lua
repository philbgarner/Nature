-- Modules
anim8 = require "anim8"
scenes = require "scenes"
resources = require "resources"

suit = require 'suit'

-- Globals

engine = require "NatureEngine"
require "prefabs_io"
paused = true      -- When not paused, show UI.

-- UI methods need access to the engine object.
ui = require "ui"


canvas = nil

time = 0
time_dir = 1

pixel = [[
        extern float time;
        extern float waterline;
        extern float offsetY;
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
          float factor = 0.003;
          float water_norm = (waterline - offsetY) / 768;
          if (texture_coords.y > water_norm)
          {
            vec2 tc = texture_coords;
            
            tc.x = tc.x + sin(tc.x * time) * factor;
            tc.y = tc.y + cos(tc.y * time) * factor;
              
            return Texel(texture, vec2(tc.x, water_norm * 2 + tc.y * -1.0)) * vec4(0.5, 0.6, 1.0, 1.0);
          }
          else
          {
            return Texel(texture, texture_coords);
          }
        }
      ]] 

-- ******************************
--  LOAD
-- ******************************
function love.load()
  
  font = love.graphics.newFont(12)
  fontheader1 = love.graphics.newFont(24)
  love.graphics.setFont(font)
  print("getIdentity:", love.filesystem.getIdentity( ))
  engine:create("mockup1", {0, 0, 5000, 2000})  -- mockup1 is the asset pack (folder maps to /NatureEngine/prefabs/mockup1"
                                                -- second param is the world boundaries for the camera.
  
  shader = love.graphics.newShader(pixel)
  shader:send("waterline", 1700)
  
  canvas = love.graphics.newCanvas(1024, 768)

end

-- ******************************
--  DRAW
-- ******************************
function love.draw()
  
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  engine:draw()

  love.graphics.setCanvas()

  love.graphics.setShader(shader)
  
    love.graphics.draw(canvas)
  
  love.graphics.setShader()

  suit:draw()
end

-- ******************************
--  UPDATE
-- ******************************
function love.update(dt)
   local cx, cy = engine.camera:getPosition()
   cy = cy - 390
  
  time = time + dt * time_dir
  if time > 10 then
    time_dir = -1
  elseif time < -10 then
    time_dir = 1
  end
	shader:send("time", time * 9)
	shader:send("offsetY", cy)
   
   -- UI Layout
  if paused then
    ui:drawPrefabs(engine.assetlist)
    ui:drawObjects(engine.layers)
    ui:drawSelected(engine.camera_target)
  else
    engine:update(dt)
  end

end

function love.textinput(t)
    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key, scancode)
    -- forward keypressed to SUIT
    suit.keypressed(key)
    
    if scancode == "escape" then
      paused = not paused
    end
end

function love.mousemoved(x, y, dx, dy)
  
  if ui.editor_state == 2 and engine.camera_target ~= nil then
    engine.camera_target.body:setPosition(engine.camera_target.body:getX() + dx, engine.camera_target.body:getY() + dy)
    local wx, wy, wd = love.window.getPosition()
    local mw, mh, mf = love.window.getMode()
  end
  
end

function love.mousepressed(x, y, button, istouch)
  
  if ui.editor_state == 2 then
    love.mouse.setGrabbed(false)
    ui.editor_state = 1 
  end
end