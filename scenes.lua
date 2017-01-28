local scenes = {
    list = {}
  }
  
function scenes:create(name, sceneMethods, data)
  -- sceneMethods should have some methods
  -- defined. If they aren't we supply defaults.
  -- This can be extended as needed.
  
  if sceneMethods.fnInit == nil then
    sceneMethods.fnInit = function (data) end
  end
  if sceneMethods.fnUpdate == nil then
    sceneMethods.fnUpdate = function (dt) end
  end
  if sceneMethods.fnDraw == nil then
    sceneMethods.fnDraw = function () end
  end
  if sceneMethods.fnKeyPress == nil then
    sceneMethods.fnKeyPress = function (key, scancode) end
  end
  if sceneMethods.fnDestroy == nil then
    sceneMethods.fnDestroy = function () end
  end
  
  local scene = {
      name = name
      ,data = data       -- data will store variables that should be available to your scene.
      ,paused = false
      ,fnInit = sceneMethods.fnInit
      ,fnUpdate = sceneMethods.fnUpdate
      ,fnDraw = sceneMethods.fnDraw
      ,fnKeyPress = sceneMethods.fnKeyPress
      ,fnDestroy = sceneMethods.fnDestroy
    }
    
    table.insert(scenes.list, scene)
    
    scene.fnInit(data)
end

function scenes:keyPressed(key, scancode)
  scenes.list[#scenes.list].fnKeyPress(key, scancode, scenes.list[#scenes.list].data)
end

function scenes:pop()
  scenes.list[#scenes.list] = nil
end

function scenes:update(dt)
  scenes.list[#scenes.list].fnUpdate(dt, scenes.list[#scenes.list].data)
end

function scenes:draw()
  scenes.list[#scenes.list].fnDraw(scenes.list[#scenes.list].data)
end

return scenes