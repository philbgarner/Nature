-- Toggle for window objects that aren't always on.

wndLevelProps = false
wndNewLevel = false
level_menu_active = false

-- Modules
anim8 = require "anim8"
scenes = require "scenes"
resources = require "resources"

settings = require "settings"

suit = require 'suit'

-- Globals

engine = require "NatureEngine"
console = require "Console"
console_active = true
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
  console:create(function () -- Close console callback.
      console_active = false
    end
    ,function (command, args) -- Command callback (command controller function).

      if command == "help" then

        console:write("-= Help =-", console.color_yellow)
        console:write("game - This command gives access to the properties and objects inside the game engine.")
        console:write("       Example: Entering 'game name' will output the level name, while 'game name TestLevel1' will set the level name. ")

        return "help - Displays this help command."
      elseif command == "game" then

        if #args == 0 then return "Error: No game object reference provided in the first argument." end

        local cmd = "engine." .. args[1]


        if #args == 2 then
          local p1type = loadstring("return type(" .. cmd .. ")")
          local pt = p1type()
          if string.sub(pt, 1, 5) == "table" then
            local cmd = "return engine." .. args[1] .. "." .. args[2]

            local comm = loadstring(cmd)
            local v = comm()
            return "Get Value: " .. cmd .. " -> " .. tostring(v)
          else
            local vtype = loadstring("return type(" .. args[2] .. ")")
           
            if vtype() == "number" then
              cmd = cmd .. " = " .. args[2]
            elseif string.sub(vtype(), 1, 5) == "table" then
              console:write("TODO: List the members of this table and return that value to console.")
            elseif vtype() == "nil" and args[2] ~= nil then -- then we'll just assume it's a string and wrap it in quotes...
              cmd = cmd .. " = \"" .. args[2] .. "\""
            end
            local comm = loadstring(cmd)
            local v = comm()
            return "Successfully set value to " .. args[2] .. "."
          end
        elseif #args == 3 then 
          -- TODO: Set the value in the nested table (Example: game properties water_level 2500)
        elseif #args == 1 then
          local comm = loadstring("return " .. cmd)
          local v = comm()
          return "Get Value: " .. cmd .. " -> " .. tostring(v)
        end 

      end

      return "Command '" .. command .. "' not found."

    end)

  console:write("-= NatureEngine Loaded =-", console.color_yellow)
  console:write("Press " .. console.close_scancode .. " to close the console and return to the game, press tilde (` or ~) to reopen the console.", console.color_yellow)
  console:write("Type " .. console.help_command .. " to get a list of commands.", console.color_yellow)

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

  if console_active then
    console:draw()
    return
  end

  if paused then ui:drawMinimap() end
  
  ui:drawMenuSystem()
  if wndLevelProps then
    ui:drawLevelProperties(200, 200)
  end
  
  if wndNewLevel then
    ui:drawNewLevel(200, 200)
  end

  suit:draw()
  

  
end

-- ******************************
--  UPDATE
-- ******************************
function love.update(dt)

  if console_active then
    console:update(dt)
    return
  end

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


    if console_active then
      console:keyInput(t)
      return
    end  

    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key, scancode)


    if console_active then
      console:keypress(key, scancode)
      return
    end

    -- forward keypressed to SUIT
    suit.keypressed(key)
    
    if scancode == "escape" then
      paused = not paused
    elseif key == '`' then
      console_active = true
    end
end

function love.mousemoved(x, y, dx, dy)
  
    if console_active then
      console:mousemove(x, y, button)
      return
    end

  if ui.editor_state == 2 and engine.camera_target ~= nil then
    engine.camera_target.body:setPosition(engine.camera_target.body:getX() + dx, engine.camera_target.body:getY() + dy)
    local wx, wy, wd = love.window.getPosition()
    local mw, mh, mf = love.window.getMode()
  end
  
  if love.mouse.isDown(2) then
    local cx, cy = engine.camera:getPosition()
    
    engine.camera:setPosition(cx + dx * 1.5, cy + dy * 1.5)
  end
  
end

function love.mousepressed(x, y, button, istouch)

    if console_active then
      console:mouseclick(x, y, button)
      return
    end

  if ui.editor_state == 2 then
    love.mouse.setGrabbed(false)
    ui.editor_state = 1 
  end
end