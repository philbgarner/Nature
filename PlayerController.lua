local PlayerController = {

  body = nil
  ,uid = nil
  ,prefab = "redbird.png"
  ,shape = nil
  ,fixture = nil
  ,density = 1
  ,w = nil
  ,h = nil
  ,r = 1
  ,angle = 95
  ,world = nil

  ,vel = 5
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

  return PlayerController
end

function PlayerController:update(dt)
	local gx, gy = PlayerController.world:getGravity()
	PlayerController.body:applyForce(0, PlayerController.body:getMass() * -gy)

	PlayerController.body:applyForce(math.sin(math.rad(PlayerController.angle)) * PlayerController.vel
			,math.cos(math.rad(PlayerController.angle)) * (PlayerController.vel * 0.3))

end

function PlayerController:draw()

	love.graphics.setColor(0, 255, 255)
	love.graphics.circle("fill", PlayerController.body:getX(), PlayerController.body:getY(), PlayerController.r)

	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("line", PlayerController.body:getX() + math.sin(math.rad(PlayerController.angle)) * PlayerController.vel * 6
			,PlayerController.body:getY() + math.cos(math.rad(PlayerController.angle)) * PlayerController.vel * 6, 5)
	love.graphics.setColor(255, 255, 255)

end

function PlayerController:keypress(key, scancode)

end

return PlayerController