local NatureEngine = {
  
  layers = {
    -- Layer 1 - Background layer
    {solids = {}
      ,entities = {}}
    -- Layer 2 - Middle Layer
    ,{solids = {}
      ,entities = {}}
    -- Layer 3 - Front Layer
    ,{solids = {}
      ,entities = {}}
  }
  ,player = nil
  ,world = nil
  ,assetlist = {}
  ,assetCount = 0
  ,assetpack = ""
  ,camera = nil
  ,camera_target = nil
  
  ,uid_max = 1
  
  ,initialized = false
}
local gamera = require "gamera"

function uid()
  local v = NatureEngine.uid_max
  NatureEngine.uid_max = NatureEngine.uid_max + 1
  return v
end

function NatureEngine:create(assetpack, camera_dimensions)
  NatureEngine.assetpack = assetpack
  NatureEngine:loadAssets()
  
  love.physics.setMeter(10)
  NatureEngine.world = love.physics.newWorld(0, 9.81 * 10, true)
  
  NatureEngine.camera = gamera.new(camera_dimensions[1], camera_dimensions[2], camera_dimensions[3], camera_dimensions[4])
  NatureEngine.camera_mini = gamera.new(camera_dimensions[1], camera_dimensions[2], camera_dimensions[3], camera_dimensions[4])
  NatureEngine.camera_mini:setPosition(0, 0)
  --NatureEngine.camera_mini:setScale(0.001) 
  
  initialized = true
end

function NatureEngine:loadAssets()
  if NatureEngine.assetpack == "" then return end
  if not love.filesystem.exists("prefabs/" .. NatureEngine.assetpack) then
    print("Could not locate " .. NatureEngine.assetpack .. ".")
    return
  end
  
  if not love.filesystem.exists("prefabs/" .. NatureEngine.assetpack .. "/assets.list.lua") then
    print("Prefab Assets File not found: Expected '", "prefabs/" .. NatureEngine.assetpack .. "/assets.list" .. "'")
    return
  end
  
  --NatureEngine.assetlist = table.load("prefabs/" .. NatureEngine.assetpack .. "/assets.list")
  NatureEngine.assetlist = loadAssetList("prefabs/" .. NatureEngine.assetpack .. "/assets.list.lua")
  local ac = 0
  for key, value in pairs(NatureEngine.assetlist) do
    NatureEngine.assetlist[key].image = love.graphics.newImage("prefabs/" .. NatureEngine.assetpack .. "/" .. key)
    ac = ac + 1
  end
  NatureEngine.assetCount = ac
  
  print("Assets.list found: " .. ac .. " assets loaded.")
  
end

function NatureEngine:update(dt)
  
  NatureEngine.world:update(dt)
  
  NatureEngine:refreshCameraTarget()
  
end

function NatureEngine:refreshCameraTarget()
  
  if NatureEngine.camera_target ~= nil then 
    NatureEngine.camera:setPosition(NatureEngine.camera_target.body:getX(), NatureEngine.camera_target.body:getY())
  end
  
end

function NatureEngine:draw()
  
  NatureEngine.camera:draw(function (left,t,w,h)
  
    NatureEngine:renderLayers()
    
  end)
  
end

function NatureEngine:renderLayers()
  
    for l=1, #NatureEngine.layers do
      
      -- Render Solids
      for a=1, #NatureEngine.layers[l].solids do
        local sl = NatureEngine.layers[l].solids[a]
        local as = NatureEngine.assetlist[sl.prefab]
        local aw = as.asset_properties.animation_w / 2
        local ah = as.asset_properties.animation_h / 2
        love.graphics.draw(as.image, sl.body:getX(), sl.body:getY(), sl.body:getAngle())
        love.graphics.line(sl.body:getWorldPoints(sl.shape:getPoints()))
      end
      
      -- Render Entities
      for a=1, #NatureEngine.layers[l].entities do
        local sl = NatureEngine.layers[l].entities[a]
        local as = NatureEngine.assetlist[sl.prefab]
        --love.graphics.draw(as.image, sl.body:getX(), sl.body:getY())
        love.graphics.circle("fill", sl.body:getX(), sl.body:getY(), as.collision_settings.radius)
        --love.graphics.line(sl.shape:getPoints( ))
      end
      
    end
  
end
  

function NatureEngine:quit()
end

--assetlist[filename] = {
--    bound_poly = {}
--    ,collision_settings = {
--          cCat = 0
--        ,cMask = 0
--        ,cGroup = 0}
--    ,physical_properties = {
--        mass = 0
--        ,linear_d = 0
--        ,angular_d = 0
--        ,bodytype = 0
--        ,bullet = false
--        ,bodytype = 1
--      }
--    ,asset_properties = {
--    }
--  }

function NatureEngine:createSolid(layer, prefab, x, y)

  local static = {
      body = nil
      ,uid = uid()
      ,prefab = prefab
      ,shape = nil
      ,fixture = nil
      ,density = 100
      ,w = nil
      ,h = nil
      ,polygon = {}
    }
  static.image = NatureEngine.assetlist[prefab].image
  static.w = static.image:getWidth()
  static.h = static.image:getHeight()
  local polys = {}
  local bp = NatureEngine.assetlist[prefab].bound_poly

  static.body = love.physics.newBody(NatureEngine.world, x, y, "static")
  for i=1, #bp do
    table.insert(polys, bp[i].x * static.image:getWidth())
    table.insert(polys, bp[i].y * static.image:getHeight())
  end
  static.shape = love.physics.newChainShape(false, polys)
  static.fixture = love.physics.newFixture(static.body, static.shape, static.density)
  static.fixture:setRestitution(0.1)
  static.fixture:setUserData("static object")
  static.fixture:setFilterData(0x001, 0x002, 0)

  table.insert(NatureEngine.layers[layer].solids, static)
  
  return static

end

function NatureEngine:setPlayer(entity)
  NatureEngine.player = entity
  
  NatureEngine.camera:setPosition(entity.body:getX(), entity.body:getY())
  NatureEngine.camera_target = entity
end

function NatureEngine:createEntity(layer, prefab, x, y, r)

  local static = {
      body = nil
      ,uid = uid()
      ,shape = nil
      ,prefab = prefab
      ,fixture = nil
      ,density = 100
      ,x = x
      ,y = y
      ,r = r
    }
  static.body = love.physics.newBody(NatureEngine.world, x, y, "dynamic")
  --static.shape = love.physics.newPolygonShape(polys)
  static.shape = love.physics.newCircleShape(r)
  static.fixture = love.physics.newFixture(static.body, static.shape, static.density)
  static.fixture:setRestitution(0.1)
  static.fixture:setUserData("dynamic object")
  static.fixture:setFilterData(0x002, 0x001, 0)

  table.insert(NatureEngine.layers[layer].entities, static)
  
  return static

end

function NatureEngine:removeObject(uid)
  
  for l=1, 3 do
    for i=1, #NatureEngine.layers[l].solids do
      if NatureEngine.layers[l].solids[i].uid == uid then
        table.remove(NatureEngine.layers[l].solids, i)
        return
      end
    end
    for i=1, #NatureEngine.layers[l].entities do
      if NatureEngine.layers[l].entities[i].uid == uid then
        table.remove(NatureEngine.layers[l].entities, i)
        return
      end
    end
  end
end

function NatureEngine:toBackObject(uid)
  
  for l=1, 3 do
    for i=1, #NatureEngine.layers[l].solids do
      if NatureEngine.layers[l].solids[i].uid == uid and i > 1 then
        local n = NatureEngine.layers[l].solids[i - 1] 
        NatureEngine.layers[l].solids[i - 1] = NatureEngine.layers[l].solids[i] 
        NatureEngine.layers[l].solids[i] = n
        return
      end
    end
    for i=1, #NatureEngine.layers[l].entities do
      if NatureEngine.layers[l].entities[i].uid == uid and i > 1 then
        local n = NatureEngine.layers[l].entities[i - 1] 
        NatureEngine.layers[l].entities[i - 1] = NatureEngine.layers[l].entities[i] 
        NatureEngine.layers[l].entities[i] = n
        return
      end
    end
  end
  
end

function NatureEngine:toFrontObject(uid)
  
  for l=1, 3 do
    for i=1, #NatureEngine.layers[l].solids do
      if NatureEngine.layers[l].solids[i].uid == uid and i < #NatureEngine.layers[l].solids then
        local n = NatureEngine.layers[l].solids[i + 1] 
        NatureEngine.layers[l].solids[i + 1] = NatureEngine.layers[l].solids[i] 
        NatureEngine.layers[l].solids[i] = n
        return
      end
    end
    for i=1, #NatureEngine.layers[l].entities do
      if NatureEngine.layers[l].entities[i].uid == uid and i < #NatureEngine.layers[l].entities then
        local n = NatureEngine.layers[l].entities[i + 1] 
        NatureEngine.layers[l].entities[i + 1] = NatureEngine.layers[l].entities[i] 
        NatureEngine.layers[l].entities[i] = n
        return
      end
    end
  end
  
end

return NatureEngine