debug = true

isAlive = true
isWinner = false
score = 0
g = 0

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- Image Storage
bulletImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated

--More timers
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- More images
enemyImg = nil -- Like other images we'll pull this in during out love.load function

-- More storage
enemies = {} -- array of current enemies on screen

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
   return x1 < x2+w2 and
      x2 < x1+w1 and
      y1 < y2+h2 and
      y2 < y1+h1
end

function love.load(arg)
   player = { x = 200, y = 425, speed = 150, img = nil }
   player.img = love.graphics.newImage('assets/Aircraft_06.png')
   bulletImg = love.graphics.newImage('assets/bullet_2_blue.png')
   enemyImg = love.graphics.newImage('assets/enemy.png')
end

function love.update(dt)
   -- I always start with an easy way to exit the game
   if love.keyboard.isDown('escape') then
      love.event.push('quit')
   end

   if isWinner then return end
   if love.keyboard.isDown('left','a') then
      if player.x > 0 then -- binds us to the map
         player.x = player.x - (player.speed*dt)
      end
   elseif love.keyboard.isDown('right','d') then
      if (player.x + player.img:getWidth()) < love.graphics.getWidth() then
         player.x = player.x + (player.speed*dt)
      end
   end

   -- Time out how far apart our shots can be.
   canShootTimer = canShootTimer - (1 * dt)
   if canShootTimer < 0 then
      canShoot = true
   end

   if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot and isAlive then
      -- Create some bullets
      newBullet = { x = player.x + (player.img:getWidth()/2),
                    y = player.y, img = bulletImg }
      table.insert(bullets, newBullet)
      canShoot = false
      canShootTimer = canShootTimerMax
   end

   -- update the positions of bullets
   for i, bullet in ipairs(bullets) do
      bullet.y = bullet.y - (250 * dt)

      if bullet.y < 0 then -- remove bullets when they pass off the screen
         table.remove(bullets, i)
      end
   end

   -- Time out enemy creation
   createEnemyTimer = createEnemyTimer - (1 * dt)
   if createEnemyTimer < 0 then
      createEnemyTimer = createEnemyTimerMax

      -- Create an enemy
      randomNumber = math.random(10, love.graphics.getWidth() - 10)
      newEnemy = { x = randomNumber, y = -10, img = enemyImg }
      table.insert(enemies, newEnemy)
   end

   -- update the positions of enemies
   for i, enemy in ipairs(enemies) do
      enemy.y = enemy.y + (50 * dt)

      if enemy.y > love.graphics.getHeight() then
         -- remove enemies when they pass off the screen
         table.remove(enemies, i)
      end
   end

   -- run our collision detection Since there will be fewer enemies on
   -- screen than bullets we'll loop them first Also, we need to see
   -- if the enemies hit our player
   for i, enemy in ipairs(enemies) do
      for j, bullet in ipairs(bullets) do
         if CheckCollision(enemy.x, enemy.y,
                           enemy.img:getWidth(), enemy.img:getHeight(),
                           bullet.x, bullet.y,
                           bullet.img:getWidth(), bullet.img:getHeight()) then
            table.remove(bullets, j)
            table.remove(enemies, i)
            score = score + 1
            if score == 100 then
              g = 1+g
            end
         end
      end

      if CheckCollision(enemy.x, enemy.y,
                        enemy.img:getWidth(), enemy.img:getHeight(),
                        player.x, player.y,
                        player.img:getWidth(), player.img:getHeight())
      and isAlive then
         table.remove(enemies, i)
         isAlive = false
      end
   end

   if not isAlive and love.keyboard.isDown('r') then
      -- remove all our bullets and enemies from screen
      bullets = {}
      enemies = {}

      -- reset timers
      canShootTimer = canShootTimerMax
      createEnemyTimer = createEnemyTimerMax

      -- reset our game state
      score = 0
      isAlive = true
   end
end

function love.draw(dt)
   love.graphics.print("score: "..score,10,10)
   love.graphics.print("g: "..g,400,10)
   if isWinner then
     love.graphics.print("You won!You beat "..score.." enemies!",
                                love.graphics:getWidth()/2-50,
                                love.graphics:getHeight()/2-10)
   end
   if isAlive then
      love.graphics.draw(player.img, player.x, player.y)
   else
      love.graphics.print("Press 'R' to restart. You got " .. score ..
                             " points.",
                          love.graphics:getWidth()/2-50,
                          love.graphics:getHeight()/2-10)
   end

   for i, bullet in ipairs(bullets) do
      love.graphics.draw(bullet.img, bullet.x, bullet.y)
   end

   for i, enemy in ipairs(enemies) do
      love.graphics.draw(enemy.img, enemy.x, enemy.y)
   end
end
