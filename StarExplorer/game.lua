
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function addToSceneGroup(sc, groups)
  for i = 1, #group do 
    sc.insert(groups[i])
  end
end

local physics = require('physics')
physics.start()
physics.setGravity(0,0)

local sheetOptions = {
  frames = {
    {
      -- 1) Asteroid 1
      x = 0,
      y = 0,
      width = 102,
      height = 85
    },
    {
      -- 2) Asteroid 2
      x = 0,
      y = 168,
      width = 100,
      height = 97
    },
    {
      -- 3) Asteroid 3
      x = 0,
      y = 168,
      width = 100,
      height = 97
    },
    {
      -- 4) Ship
      x = 0,
      y = 265,
      width = 98,
      height = 79
    },
    {
      -- 5) Laser
      x = 98,
      y = 265,
      width = 14,
      height = 40
    }
  }
}

local objectSheet = graphics.newImageSheet('gameObjects.png', sheetOptions)

-- Initialize variables
local lives = 2
local score = 0
local died = false

local asteroidTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

local explosionSound
local fireSound
local musicTrack

local function updateText()
  livesText.text = 'Lives: ' .. lives
  scoreText.text = 'Score: ' .. score
end

local function createAsteroid()
  local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
  
  table.insert(asteroidTable, newAsteroid)
  physics.addBody(newAsteroid, { radius = 40, bounce = 0.8 })
  newAsteroid.myName = 'Asteroid'

  local whereFrom = math.random(3)

  if (whereFrom == 1) then
    newAsteroid.x = -60
    newAsteroid.y = math.random(display.contentHeight / 2.5)
    newAsteroid:setLinearVelocity(math.random(40, 120), math.random(20, 60))
  elseif (whereFrom == 2) then
    newAsteroid.x = math.random(display.contentWidth)
    newAsteroid.y = -60
    newAsteroid:setLinearVelocity(math.random(-40, 40), math.random(40, 120))
  elseif (whereFrom == 3) then
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random(display.contentHeight / 2.5)
    newAsteroid:setLinearVelocity(math.random(-120, -40), math.random(20, 60))
  end

  newAsteroid:applyTorque(math.random(-6, 6))
end

local function fireLaser()
  local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
  
  physics.addBody(newLaser, { isSensor=true })
  newLaser.isBullet = true
  newLaser.myName = 'Laser'

  newLaser.x = ship.x
  newLaser.y = ship.y
  newLaser:toBack()

  audio.play(explosionSound)

  transition.to(newLaser, {
    y = -40,
    time = 500,
    onComplete = function()
      display.remove(newLaser)
    end
  })
end

local function dragShip(event)
  local ship = event.target
  local phase = event.phase

  if (phase == 'began') then
    display.currentStage:setFocus(ship)
    ship.touchOffsetX = event.x - ship.x

  elseif (phase == 'moved') then
    ship.x = event.x - ship.touchOffsetX

  elseif (phase == 'ended' or phase == 'cancelled') then
    display.currentStage:setFocus(nil)
  end

  return true
end

local function gameLoop()
  createAsteroid()

  for i = #asteroidTable, 1, -1 do
    local asteroid = asteroidTable[i]

    if (
      asteroid.x < -100 or asteroid.x > display.contentWidth + 100 or
      asteroid.y < - 100 or asteroid.y > display.contentHeight + 100
    ) then
      display.remove(asteroid)
      table.remove(asteroidTable, i)
    end
  end
end

local function restoreShip()
  ship.isBodyActive = false
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100

  transition.to( ship, {
    alpha = 1,
    time = 4000,
    onComplete = function()
      ship.isBodyActive = true
      died = false
    end
  })
end

local function endGame()
  composer.setVariable('finalScore', score)
  composer.gotoScene('menu', { time=800, effect='crossFade' })
end

local function handleAsteroidLaserCollision(obj1, obj2)
  if(
    (obj1.myName == 'Asteroid' and obj2.myName == 'Laser')
    or
    (obj2.myName == 'Asteroid' and obj1.myName == 'Laser') 
  ) then
    display.remove(obj1)
    display.remove(obj2)

    audio.play(explosionSound)

    for i = #asteroidTable, 1, -1 do
      local asteroid = asteroidTable[i]

      if(asteroid == obj1 or asteroid == obj2) then
        table.remove(asteroidTable, i)
        break
      end
    end

    score = score + 100
    scoreText.text = "Score: " .. score
  end
end

local function handleAsteroidShipCollision(obj1, obj2)
  print(obj1.myName, obj2.myName)
  if(
    (obj1.myName == 'Asteroid' and obj2.myName == 'Ship')
    or
    (obj2.myName == 'Asteroid' and obj1.myName == 'Ship') 
  ) then

    if (died == false) then
      died = true

      audio.play(explosionSound)

      lives = lives -1
      livesText.text = 'Lives: ' .. lives
      
      if (lives == 0) then
        display.remove(ship)
        timer.performWithDelay(2000, endGame)
      else
        ship.alpha = 0
        timer.performWithDelay(1000, restoreShip)
      end
    end
  end
end

local function onCollision(event)
  if (event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2

    handleAsteroidLaserCollision(obj1, obj2)
    handleAsteroidShipCollision(obj1, obj2)

  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  physics.pause()

  backGroup = display.newGroup()
  sceneGroup:insert(backGroup)

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  -- Load background
  local background = display.newImageRect(backGroup, 'background.png', 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100
  physics.addBody(ship, { radius = 30, isSensor = true })
  ship.myName = 'Ship'

  -- Display lives and score
  livesText = display.newText(uiGroup, 'Lives: ' .. lives, 200, 80, native.systemFont, 36)
  scoreText = display.newText(uiGroup, 'Score: ' .. score, 400, 80, native.systemFont, 36)

  ship:addEventListener( "tap", fireLaser )
  ship:addEventListener( "touch", dragShip )

  explosionSound = audio.loadSound('audio/explosion.wav')
  fireSound = audio.loadSound('audio/fire.wav')
  musicTrack = audio.loadStream('audio/80s-Space-Game_Looping.wav')
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

    physics.start()
    Runtime:addEventListener('collision', onCollision)
    gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
    audio.play(musicTrack, { channel=1, loops=-1 })
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel(gameLoopTimer)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener('collision', onCollision)
    physics.pause()
    audio.stop(1)
    composer.removeScene('game')
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  -- Dispose audio!
  audio.dispose(explosionSound)
  audio.dispose(fireSound)
  audio.dispose(musicTrack)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
