function writeAssetList(apath)
  local path = ""

  if not settings.relative_paths then
    path = settings.absolute_path
    if string.sub(path, -1) ~= "/" then
      path = path .. "/"
    end
    print("Using absolute_path setting: ", path)
  end

  
  local buffer = "return {"
  
  local kc = 0
  local kcomma = ""
  local pcomma = ""
  for key, value in pairs(assetlist) do
  
    if kc == 0 then
      kcomma = ""
    else
      kcomma = ","
    end
  
    local poly_buffer = ""
    for i=1, #value.bound_poly do
      if i > 1 then
        pcomma = ","
      else
        pcomma = ""
      end
      poly_buffer = poly_buffer .. pcomma .. "{x=" .. value.bound_poly[i].x .. ", y=" .. value.bound_poly[i].y .. "}"
    end
    
    buffer = buffer .. kcomma .. "[\"" .. key .. "\"] = {" .. [[
          bound_poly = {]] .. poly_buffer .. [[}
          ,collision_settings = {cCat = ]] .. value.collision_settings.cCat .. [[, cMask = ]] .. value.collision_settings.cMask .. [[, cGroup = ]] .. value.collision_settings.cGroup .. [[, radius = ]] .. value.collision_settings.radius .. [[}
          ,physical_properties = {mass = ]] ..  value.physical_properties.mass .. [[, linear_d = ]] .. value.physical_properties.linear_d .. [[, angular_d = ]] .. value.physical_properties.angular_d .. [[, bodytype = ]] .. value.physical_properties.bodytype .. [[, bullet = ]] .. tostring(value.physical_properties.bullet) .. [[}
          ,asset_properties = {animated = ]] .. tostring(value.asset_properties.animated) .. [[, animation_gridx = "]] .. value.asset_properties.animation_gridx .. [[", animation_gridy = "]] .. value.asset_properties.animation_gridy .. [[", animation_delay = ]] .. value.asset_properties.animation_delay .. [[, animation_w = ]] .. value.asset_properties.animation_w .. [[, animation_h = ]] .. value.asset_properties.animation_h .. [[}}]]
      
    kc = kc + 1
          
  end
  
  buffer = buffer .. "}"
  
  local f = io.open(path .. apath .. "/assets.list.lua", "w")
  
    f:write(buffer)
  
  io.close(f)

end

function loadAssetList(file)
  print("Loading assets file: ", file)
  
  local path = ""
  
  if not settings.relative_paths then
    path = settings.absolute_path
    if string.sub(path, -1) ~= "/" then
      path = path .. "/"
    end
    print("Using absolute_path setting: ", path)
  end
  
  local f = io.open(path .. file)
  
  local buffer = f:read("*all")
  
  local rval = loadstring(buffer)()
  
  io.close(f)
  
  return rval
  
end
