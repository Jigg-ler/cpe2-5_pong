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

require 'Ball'

require 'Paddle'

--the actual size of the window/program
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--can be adjusted for the amount of pixels shown virtually
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--speed of the movement of the paddles
PADDLE_SPEED = 200

--set background asset
local background = love.graphics.newImage('assets/background.png')

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    --reduces blur from the edges of the font due to the virtual retro-ing
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setTitle('BSCpE 2-5 Pong')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())
    
    --stores the font settings to the object font32
    font32 = love.graphics.newFont('font.ttf', 8)
    love.graphics.setFont(font32)

    --initializes score variables
    player1Score = 0
    player2Score = 0

    --initializes the two paddles and their properties (x, y, width, height)
    player1 = Paddle(10, VIRTUAL_HEIGHT / 2 - 15, 5, 30)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT / 2 - 15, 5, 30)
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --velocity and position variables for our ball when play starts
    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 2 , 4, 4)
    
    gameState = 'start'
end

--function that updates every frame, so place within this function stuff that is
--essential to the gameplay that it requires to be updated every frame.
--e.g. player movement
function love.update(dt)
    if gameState == 'play' then
        --player1
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        --player2
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    
        ball:update(dt)       
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        
        --detect upper and lower screen boundary collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            ball:reset()
            gameState = 'serve'
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            ball:reset()
            gameState = 'serve'
        end
        player1:update(dt)
        player2:update(dt)
    end

end

--checks per frame if a key is certain key is pressed
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        love.event.quit()
    
    --if enter key is pressed during the start state of the game, it will go into play state
    --during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            ball:reset()
        end
    end
    -- TO IMPLEMENT -key for enter to start the game 

end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen,
    updated or otherwise.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- loads background asset
    love.graphics.draw(background, 0, 0)

    -- condensed onto one line from last example
    -- note we are now using virtual width and height now for text placement
    love.graphics.printf('HELLO PONG!', 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH, 'center')

    --renders the paddles virtually
    player1:render()
    player2:render()

    --render ball (center)
    ball:render()

    -- end rendering at virtual resolution
    push:apply('end')
end
