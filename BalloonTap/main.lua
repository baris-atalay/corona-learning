-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local physics = require('physics')
local tapCount = 0

local background = display.newImageRect('background.png', 360, 570)
local platform = display.newImageRect('platform.png', 300, 50)
local balloon = display.newImageRect('balloon.png', 112, 112)
local tapText = display.newText(tapCount, display.contentCenterX, 20, native.systemFont, 40)

background.x = display.contentCenterX
background.y = display.contentCenterY

platform.x = display.contentCenterX
platform.y = display.contentHeight - 25

balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8

tapText:setFillColor(255,0,0,0.5)

physics.start()

physics.addBody(platform, 'static')
physics.addBody(balloon, 'dynamic', {radius=50, bounce=0.3})

local function pushBalloon()
  balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
  tapCount = tapCount + 1
  tapText.text = tapCount
end

balloon:addEventListener('tap', pushBalloon)