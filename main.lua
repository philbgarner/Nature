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
      ,density = 100
      ,x = x
      ,y = y
      ,w = width
      ,h = height
    }

  static.body = love.physics.newBody(world, x, y, "static")
  static.shape = love.physics.newRectangleShape(0, 0, width, height)
  static.fixture = love.physics.newFixture(static.body, static.shape, static.density)
  static.fixture:setRestitution(0.1)
  static.fixture:setUserData("static object")
  static.fixture:setFilterData(0x001, 0x002, 0)

  return static

end


function createEntity(x, y, width, height)

  local entity = {
      body = nil
      ,shape = nil
      ,fixture = nil
      ,density = 1
      ,x = x
      ,y = y
      ,w = width
      ,h = height
    }

  entity.body = love.physics.newBody(world, x, y, "dynamic")
  entity.shape = love.physics.newRectangleShape(0, 0, width, height)
  entity.fixture = love.physics.newFixture(entity.body, entity.shape, entity.density)
  entity.fixture:setRestitution(0.1)
  entity.fixture:setUserData("entity object")
  entity.fixture:setFilterData(0x002, 0x0001 or 0x002, 0)

  return entity

end

-- ******************************
--  LOAD
-- ******************************
function love.load()
  
  love.window.setMode(settings.resolution.w, settings.resolution.h, {resizable=false})
  
  love.physics.setMeter(10)
  world = love.physics.newWorld(0, 9.81 * 10, true)
  
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
        
          if gamedata.level.layers[i].type == "objectgroup" and gamedata.level.layers[i].name == "Entities" then
            for j=1, #gamedata.level.layers[i].objects do      
              local o = gamedata.level.layers[i].objects[j]
              if o.type == "entity" then
                local ent = createEntity(o.x, o.y, o.width, o.height)
                table.insert(data.entities, ent)
              elseif o.type == "player" then
                local pl = createEntity(o.x, o.y, o.width, o.height)
                data.player = pl
              end
            end
          end

        end
  
      end
      ,fnUpdate = function (dt, data)

      end
      ,fnDraw = function (data)
        love.graphics.setColor(100, 100, 100, 255)
        love.graphics.rectangle("fill", 0, 0, settings.resolution.w, settings.resolution.h)
        love.graphics.push()
        love.graphics.translate(data.offsetx, data.offsety)
        
        for i=1, #data.statics do
          local ds = data.statics[i]
          love.graphics.setColor(0, 255, 0, 255)
          love.graphics.push()
            love.graphics.translate(ds.body:getX(), ds.body:getY())
            love.graphics.polygon("fill", ds.shape:getPoints())
          love.graphics.pop()
        end
        
        for i=1, #data.entities do
          local ds = data.entities[i]
          love.graphics.setColor(255, 255, 0, 255)
          love.graphics.push()
            love.graphics.translate(ds.body:getX(), ds.body:getY())
            love.graphics.polygon("line", ds.shape:getPoints())
          love.graphics.pop()
        end
        
        local pl = data.player
        
        love.graphics.push()
          love.graphics.translate(pl.body:getX(), pl.body:getY())
          love.graphics.setColor(0, 0, 255, 255)
          love.graphics.polygon("line", pl.shape:getPoints())
        love.graphics.pop()
        
        love.graphics.pop()

      end
      ,fnKeyPress = function (key, scancode) end
    }, {
      offsetx = 0
      ,offsety = 0
      ,scale = 1
      ,statics = {}
      ,entities = {}
      ,player = {}
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
  world:update(dt)   
  scenes:update(dt)
   
end