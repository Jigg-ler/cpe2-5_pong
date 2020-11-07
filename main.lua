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

--Ball class
require 'Ball'

--Paddle class
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

--set sfx
local snd1 = love.audio.newSource("assets/sfx/exceeds.wav", "static")
local snd2 = love.audio.newSource("assets/sfx/hit.wav", "static")
local snd3 = love.audio.newSource("assets/sfx/hit1.wav", "static")
local snd4 = love.audio.newSource("assets/sfx/start.wav", "static")
local snd5 = love.audio.newSource("assets/sfx/menu.wav", "stream")
local snd6 = love.audio.newSource("assets/sfx/winner.wav", "static")

--Runs when the game first starts up, only once; used to initialize the game.
function love.load()
    --reduces blur from the edges of the font due to the virtual retro-ing
    love.graphics.setDefaultFilter("nearest", "nearest")

    --sets the title of the window
    love.window.setTitle('BSCpE 2-5 Pong')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())
    
    --stores the font settings to their respective variables
    mainFont = love.graphics.newFont('font.ttf', 8)

    --initializes score variables
    player1Score = 0
    player2Score = 0

    --initializes the two paddles and their properties (x, y, width, height)
    player1 = Paddle(7, VIRTUAL_HEIGHT / 2 - 15, 7, 31)
    player2 = Paddle(VIRTUAL_WIDTH - 14, VIRTUAL_HEIGHT / 2 - 15, 7, 31)

    --velocity and position variables for our ball when play starts
    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 2 , 6, 6)
    
    -- plays the start sfx
    love.audio.play(snd4)

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    
    gameState = 'start'
end

--function that updates every frame, so place within this function stuff that is
--essential to the gameplay that it requires to be updated every frame.
--e.g. player movement
function love.update(dt)
    if gameState == 'play' then

        --player1 movement
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        --player2 movement
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
            ball.x = player1.x + ball.width
            love.audio.play(snd2)

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - ball.width
            love.audio.play(snd2)

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
            love.audio.play(snd3)
        end

        if ball.y >= VIRTUAL_HEIGHT then
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy
            love.audio.play(snd3)
        end

        if ball.x < 0 then
            love.audio.play(snd1)
            servingPlayer = 1
            player2Score = player2Score + 1
            ball:reset()
            gameState = 'service'

            if player2Score == 2 then
                --stops bg music
                snd5:stop()
                
                --plays winning sound
                love.audio.play(snd6)
                
                gameState = 'end'
                winner = 2
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            love.audio.play(snd1)
            servingPlayer = 2
            player1Score = player1Score + 1
            ball:reset()
            gameState = 'service'
            
            if player1Score == 2 then
                --stops bg music
                snd5:stop()

                --plays winning sound
                love.audio.play(snd6)
                
                gameState = 'end'
                winner = 1
            end
        end

        player1:update(dt)
        player2:update(dt)

    elseif gameState == 'service' then
        if servingPlayer == 2 then
            ball.dx = math.random(100, 150)
        else
            ball.dx = -math.random(100,150)
        end
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
        love.audio.play(snd3)

        if gameState == 'start' then
            --bg music loop
            snd5:setLooping(true)
            snd5:stop()
            snd5:play()

            gameState = 'service'

        elseif gameState == 'service' then
            gameState = 'play'

        elseif gameState == 'end' then
            --resets score
            player1Score = 0
            player2Score = 0

            --plays the bg music again
            snd5:play()

            --starts the game over again
            gameState = 'service'            

        end
    end
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

    --sets the font
    love.graphics.setFont(mainFont)

    if gameState == 'start' then
        -- condensed onto one line from last example
        -- note we are now using virtual width and height now for text placement
        love.graphics.printf('START PONG!', 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH, 'center')
    
    elseif gameState == 'service' then
        love.graphics.printf("SERVICE", 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH, 'center')

        --love.graphics.setFont(subFont)
        if servingPlayer == 2 then
            love.graphics.printf("PLAYER 2'S SERVICE", 0, VIRTUAL_HEIGHT / 4 + 4, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf("PLAYER 1'S SERVICE", 0, VIRTUAL_HEIGHT / 4 + 4, VIRTUAL_WIDTH, 'center')
        end
    
    elseif gameState == 'play' then
        love.graphics.printf('PLAY', 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'end' then
        love.graphics.printf("PLAYER " .. tostring(winner) .. "'s WIN!", 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("PRESS ENTER TO START AGAIN", 0, VIRTUAL_HEIGHT / 4 + 4, VIRTUAL_WIDTH, 'center')
    end

    --player1 score
    love.graphics.printf(tostring(player1Score), 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH - 150, 'center')
    --player2 score
    love.graphics.printf(tostring(player2Score), 0, VIRTUAL_HEIGHT / 6 - 28, VIRTUAL_WIDTH + 150, 'center')
    
    --renders the paddles virtually
    player1:render()
    player2:render()

    --render ball (center)
    ball:render()

    -- end rendering at virtual resolution
    push:apply('end')
end
