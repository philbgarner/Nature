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


end

-- ******************************
--  DRAW
-- ******************************
function love.draw()
  engine:draw()

  suit:draw()
end

-- ******************************
--  UPDATE
-- ******************************
function love.update(dt)
   
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