-- Global Variables
settings = {
    resolution = { w = 1024, h = 768 }
  }

-- Physics Globals
world = nil


-- Data Model Only!
gamedata = {
    level = {}
  }

-- Modules
anim8 = require "anim8"
scenes = require "scenes"

function createStatic(x, y, width, height)

  local static = {
      body = nil
      ,shape = nil
      ,fixture = nil
      ,x = x
      ,y = y
      ,w = width
      ,h = height
    }

  static.body = love.physics.newBody(world, x, y, "dynamic")
  static.shape = love.physics.newCircleShape(-20, -20, 40)
  static.fixture = love.physics.newFixture(static.body, static.shape, static.density)
  static.fixture:setRestitution(0.1)
  static.fixture:setUserData("static object")
  static.fixture:setFilterData(0x001, 0x002, 0)

  return static

end

-- ******************************
--  LOAD
-- ******************************
function love.load()
  
  love.window.setMode(settings.resolution.w, settings.resolution.h, {resizable=true})
  
  love.physics.setMeter(20)
  world = love.physics.newWorld(world, 0, 0, true)
  
  gamedata.level = require "assets/testmap1"
  
  font = love.graphics.newFont(12)
  fontheader1 = love.graphics.newFont(24)
  love.graphics.setFont(font)
  
  scenes:create("sidescroll", {
      fnInit = function (data)

        -- load level data.
        for i=1, #gamedata.level.layers do
          if gamedata.level.layers[i].type == "objectgroup" and gamedata.level.layers[i].name == "Solids" then
            for j=1, #gamedata.level.layers[i].objects do      
              local o = gamedata.level.layers[i].objects[j]
              if o.type == "ground" then
                local st = createStatic(o.x, o.y, o.width, o.height)
                table.insert(data.statics, st)
              end
            end
          end
        end
  
      end
      ,fnUpdate = function (dt, data) end
      ,fnDraw = function (data)
        love.graphics.setColor(100, 100, 100, 255)
        love.graphics.rectangle("fill", 0, 0, settings.resolution.w, settings.resolution.h)
        love.graphics.push()
        love.graphics.translate(data.offsetx, data.offsety)
        
        for i=1, #data.statics do
          local ds = data.statics[i]
          love.graphics.setColor(0, 255, 0, 255)
          love.graphics.rectangle("fill", ds.x, ds.y, ds.w, ds.h)
        end
        
        love.graphics.pop()

      end
      ,fnKeyPress = function (key, scancode) end
    }, {
      offsetx = 0
      ,offsety = 0
      ,scale = 1
      ,statics = {}
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