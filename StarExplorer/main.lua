-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local physics = require('physics')
physics.start()
physics.setGravity(0,0)

math.randomseed(os.time())

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

local lives = 3
local score = 0
local died = false

local asteroidTable = {}

local ship
local gameLoopTime
local livesText
local scoreText

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()


local background = display.newImageRect(backGroup, 'background.png', 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, { radius= 30, isSensor=true })
ship.Myname = 'ship'

livesText = display.newText(uiGroup, 'Lives: ' .. lives, 200, 80, native.systemFont, 36)
scoreText = display.newText(uiGroup, 'Score: ' .. score, 400, 80, native.systemFont, 36)

display.setStatusBar(display.HiddenStatusBar)

local function updateText()
  livesText.text = 'Lives: ' .. lives
  scoreText.text = 'Score: ' .. score
end