--Class file for Paddles
Paddle = Class{}

--initializing
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    --the change in y of the paddle with respect to the number of frames per second , d
    self.dy = dy
end

--checks per frame (dt); placed under love.update(dt)
function Paddle:update(dt)
    
end

--renders the paddle into the game; should be placed under love.draw()
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end