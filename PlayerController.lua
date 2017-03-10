local PlayerController = {

  body = nil
  ,initialized = false
  ,uid = nil
  ,prefab = "redbird.png"
  ,shape = nil
  ,fixture = nil
  ,density = 1
  ,w = nil
  ,h = nil
  ,r = 1
  ,angle = 90
  ,world = nil

  ,lift_amt = 2.5

  ,pitch_speed = 1

  ,pitch_min = 65
  ,pitch_max = 155
  
  ,bouyancy = 0.98

  ,vel = 5
  ,vel_y = 0
  ,flight_c = 0.1

  ,keys = {

  		pitch_up = "left"
  		,pitch_down = "right"

	}
}

function PlayerController:create(world, x, y, r, uid)
  PlayerController.world = world
  PlayerController.body = love.physics.newBody(world, x, y, "dynamic")
  PlayerController.shape = love.physics.newCircleShape(r)
  PlayerController.fixture = love.physics.newFixture(PlayerController.body, PlayerController.shape, PlayerController.density)
  PlayerController.fixture:setRestitution(0.1)
  PlayerController.fixture:setUserData("player object")
  PlayerController.fixture:setFilterData(0x001, 0x002, 0)
  PlayerController.r = r
  PlayerController.uid = uid
  PlayerController.initialized = true

  return PlayerController
end

function PlayerController:update(dt)

	if not PlayerController.initialized then return end

	if love.keyboard.isScancodeDown(PlayerController.keys.pitch_up) then
		PlayerController.angle = PlayerController.angle + PlayerController.pitch_speed
	elseif love.keyboard.isScancodeDown(PlayerController.keys.pitch_down) then
		PlayerController.angle = PlayerController.angle - PlayerController.pitch_speed
	end

	local gx, gy = PlayerController.world:getGravity()
	
	--PlayerController.body:applyForce(0, PlayerController.body:getMass() * (-gy * PlayerController.bouyancy)) -- Nearly balances out the physics engine's gravity (makes player partially bouyant, essentially)

	if PlayerController.angle < PlayerController.pitch_min then PlayerController.angle = PlayerController.pitch_min end
	if PlayerController.angle > PlayerController.pitch_max then PlayerController.angle = PlayerController.pitch_max end

  -- Vy(2) = (Vy(1) - gdt - uf(dt)) + (Vy(1) + Ldt)
  -- Adjust C as desired
  -- C will let you determine how much Lift affects the flight path
  --  where L = C Vx cos(angle)

  local uf = 9.82   -- uf = up force.  Currently just balances out gravity.
  local vel_l = PlayerController.flight_c * PlayerController.vel_y * math.cos(math.rad(PlayerController.angle))
  local nvel_y = (PlayerController.vel_y - uf * dt) + (PlayerController.vel_y + vel_l * dt)

  PlayerController.vel_y = nvel_y

  local yamt = (math.cos(math.rad(PlayerController.angle)) * PlayerController.vel_y - vel_l * PlayerController.vel_y)
  local xamt = (math.sin(math.rad(PlayerController.angle)) * PlayerController.vel)
  PlayerController.body:applyLinearImpulse(xamt * dt, yamt)     -- Applies adjustment to player position based on
                                   -- factors such as the glider's angle and velocity,
                                   -- whether or not it's inside an updraft zone, etc.

  console:write(PlayerController.vel_y)

end

function PlayerController:draw()

	if not PlayerController.initialized then return end

	love.graphics.setColor(0, 255, 255)
	love.graphics.circle("fill", PlayerController.body:getX(), PlayerController.body:getY(), PlayerController.r)

	love.graphics.print(tostring(PlayerController.body:getX()) .. ", " .. tostring(PlayerController.body:getY()) .. ", Angle:" .. tostring(PlayerController.angle), math.floor(PlayerController.body:getX()), math.floor(PlayerController.body:getY() + 25))
	love.graphics.setColor(255, 255, 255)
end

function PlayerController:keypress(key, scancode)
	if not PlayerController.initialized then return end


end

return PlayerController