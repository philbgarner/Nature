local ui = {
    clr_normal = {
      normal   = {bg = {5,15,30}, fg = {200, 200, 200}},
      hovered  = {bg = {30,88,188}, fg = {255, 255, 0}},
      active   = {bg = {30,88,188}, fg = {225, 255, 0}}
    }
    ,clr_selected = {
      normal   = {bg = {5,15,30}, fg = {200, 200, 200}},
      hovered  = {bg = {30,88,188}, fg = {255, 255, 0}},
      active   = {bg = {30,88,188}, fg = {225, 255, 0}}
    }
    ,clr_warning = {
      normal   = {bg = {30,15,5}, fg = {200, 200, 200}},
      hovered  = {bg = {188,88,30}, fg = {255, 255, 0}},
      active   = {bg = {188,88,30}, fg = {225, 255, 0}}
    }
    ,sel_layer = 1
    ,editor_state = 1
    ,camera_target = {
        x = {text = "0"}
        ,y = {text = "0"}
        ,angle = {text = "0"}
        ,name = {text = ""}
      }
  }
  
function ui:drawPrefabs(assetlist)
  
  suit.layout:reset(0,0,5,5)
  state = suit.Label("-= Prefab Asset List =-", suit.layout:row(200,20))

  local c = 1
  for key, value in pairs(assetlist) do
    if suit.Button("#" .. c .. " " .. key, {color = ui.clr_normal, align="left"}, suit.layout:row(200, 20)).hit then
      if value.physical_properties.bodytype == 1 then
        local x1,y1,x2,y2,x3,y3,x4,y4 = engine.camera:getVisibleCorners()
        local cx = (x2 - x1) / 2
        local cy = (y2 - y1) / 2
        engine:createSolid(ui.sel_layer, key, cx, cy)
      elseif value.physical_properties.bodytype == 2 then
        local x1,y1,x2,y2,x3,y3,x4,y4 = engine.camera:getVisibleCorners()
        local cx = (x2 - x1) / 2
        local cy = (y2 - y1) / 2
        engine:createEntity(ui.sel_layer, key, cx, cy, value.collision_settings.radius)
      end
    end
    c = c + 1
  end

end

  
function ui:drawObjects(layers)
  
  suit.layout:reset(210,0,5,5)
  
  state = suit.Label("Layer " .. ui.sel_layer .. "/3", suit.layout:row(200,20))
  
  btnLeft = suit.Button("<<", {color = ui.clr_normal},suit.layout:row(100, 20))
  btnRight = suit.Button(">>", {color = ui.clr_normal},suit.layout:col(100))
  
  if btnLeft.hit then
    ui.sel_layer = ui.sel_layer - 1
  end
  if btnRight.hit then
    ui.sel_layer = ui.sel_layer + 1
  end
  if ui.sel_layer > 3 then ui.sel_layer = 3 elseif ui.sel_layer < 1 then ui.sel_layer = 1 end
  
  suit.layout:reset(210,50,2,2)
  
  state = suit.Label("-= Placed Prefabs =-", suit.layout:row(200,30))

  if ui.sel_layer ~= 2 then -- If it's not the middle layer, show the static objects, otherwise show dynamic.
    for i=1, #layers[ui.sel_layer].solids do
      local so = layers[ui.sel_layer].solids[i]
      if suit.Button("#" .. i .. " (" .. math.floor(so.body:getX()) .. "," .. math.floor(so.body:getY()) .. ") Solid - " .. so.prefab, {color = ui.clr_normal, align="left"},suit.layout:row(200, 40)).hit
      then
        engine.camera_target = so
        ui.camera_target.angle.text = tostring(so.body:getAngle())
        engine:refreshCameraTarget()
      end
    end
  else
    for i=1, #layers[ui.sel_layer].entities do
      local so = layers[ui.sel_layer].entities[i]
      if suit.Button("#" .. i .. " (" .. math.floor(so.body:getX()) .. "," .. math.floor(so.body:getY()) .. ") Dynamic - " .. so.prefab, {color = ui.clr_normal, align="left"},suit.layout:row(200, 40)).hit
      then
        engine.camera_target = so
        engine:refreshCameraTarget()
      end
    end
  end

end

function ui:drawSelected(so)
  
  if so == nil or engine.camera_target == nil then return end
  
  local ct_old = ui.camera_target
  
  suit.layout:reset(610,0,5,5)
  
  suit.Label("Selected Object (" .. so.prefab .. ", uid: " .. so.uid .. ")", {align="left"}, suit.layout:row(400,20))
  suit.Label("Current Position (" .. so.body:getX() .. "," .. so.body:getY() .. ")", {align="left"}, suit.layout:row(400,20))
  
  suit.Label("Translate Position (+/- x, +/- y):", {align="left"}, suit.layout:row(350,30))
  if suit.Button("Grab", {align="left"}, suit.layout:col(40)).hit then
    ui.editor_state = 2
    local cx, cy = engine.camera:toWorld(love.mouse.getX(), love.mouse.getY())
    local ox = tonumber(engine.assetlist[engine.camera_target.prefab].asset_properties.animation_w) / 2
    local oy = tonumber(engine.assetlist[engine.camera_target.prefab].asset_properties.animation_h) / 2
    engine.camera_target.body:setPosition(cx - ox, cy - oy)
    love.mouse.setGrabbed(true)
  end
  
  if suit.Input(ui.camera_target.x, 615, 80, 195, 30).submitted then
    so.body:setPosition(so.body:getX() + tonumber(ui.camera_target.x.text), so.body:getY() + tonumber(ui.camera_target.y.text))
    engine:refreshCameraTarget()
  end
  if suit.Input(ui.camera_target.y, 815, 80, 195, 30).submitted then
    so.body:setPosition(so.body:getX() + tonumber(ui.camera_target.x.text), so.body:getY() + tonumber(ui.camera_target.y.text))
    engine:refreshCameraTarget()
  end

  suit.layout:reset(610,115,5,5)
  
  suit.Label("Angle:", {align="left"}, suit.layout:row(50,30))
  
  suit.layout:reset(810,115,5,5)
  suit.Label("Name:", {align="left"}, suit.layout:row(50, 30))
  
  suit.layout:reset(610,145,5,5)
  
  if suit.Input(ui.camera_target.angle, 660, 115, 150, 30).submitted then
    so.body:setAngle(tonumber(math.rad(ui.camera_target.angle.text)))
  end
  if suit.Input(ui.camera_target.name, 860, 115, 150, 30).submitted then
  end
  
  suit.layout:reset(610,150,5,5)
  
  if suit.Button("Delete Object", {color = ui.clr_warning, align="left"},suit.layout:row(200, 30)).hit
  then
    engine:removeObject(so.uid)
    engine.camera_target = nil
  end

  if suit.Button("To Front /\\", {color = ui.clr_normal, align="left"},suit.layout:col(90)).hit
  then
    engine:toFrontObject(so.uid)
  end
  if suit.Button("To Back \\/", {color = ui.clr_normal, align="left"},suit.layout:col(90)).hit
  then
    engine:toBackObject(so.uid)
  end
  
  
end

return ui