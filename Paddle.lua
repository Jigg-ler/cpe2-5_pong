--Class file for Paddles
Paddle = Class{}

--initializing
function Paddle:init(x, y, width, height)
    self.image = love.graphics.newImage('assets/paddle.png')
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    --the change in y of the paddle with respect to the number of frames per second , d
    self.dy = dy
end

--checks per frame (dt); placed under love.update(dt)
function Paddle:update(dt)
    if self.y <= 0 then
        self. y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:reset()
    self.y = VIRTUAL_HEIGHT / 2 - 15
end

--renders the paddle into the game; should be placed under love.draw()
function Paddle:render()
    love.graphics.draw(self.image, self.x, self.y)
end