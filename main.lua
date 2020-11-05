--[[
    still need to implement class.lua, Ball.lua, Paddle.lua
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
push = require 'push'

--class is a library that allows us to implement classes similar to
--other languages
Class = require 'class'

--the actual size of the window/program
WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 600

--can be adjusted for the amount of pixels shown virtually
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    --reduces blur from the edges of the font due to the virtual retro-ing
    love.graphics.setDefaultFilter("nearest", "nearest")

    --stores the font settings to the object font32
    font32 = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(font32)
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

--function that updates every frame, so place within this function stuff that is
--essential to the gameplay that it requires to be updated every frame.
--e.g. player movement
function love.update(dt)
    
end

function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        love.event.quit()
    end
    -- TO IMPLEMENT -key for enter to start the game 
    -- controls for the paddles (player1.down() inside if statement)

end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- condensed onto one line from last example
    -- note we are now using virtual width and height now for text placement
    love.graphics.printf('Hello Pong!', 0, VIRTUAL_HEIGHT / 6 - 16, VIRTUAL_WIDTH, 'center')

    --(drawmode, x, y, width, height)
    love.graphics.rectangle('fill', 10, VIRTUAL_HEIGHT / 2, 5, 30)

    -- end rendering at virtual resolution
    push:apply('end')
end
