Paddle = CLASS{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, (self.y + (self.dy * dt)))
    elseif self.dy > 0 then
        self.y = math.min((VIRTUAL_HEIGHT - PLAYER_HEIGHT), (self.y + (self.dy * dt)))
    end
end

function Paddle:render()
    love.graphics.rectangle(
        'fill',
        self.x,
        self.y,
        self.width,
        self.height
    )
end

function Paddle:AI(ball, player)
    if (player == 1 and (ball.x < self.x + 200 and ball.dx < 0)) or 
        (player == 2 and (ball.x > self.x - 200 and ball.dx > 0)) then
        if ball.y - 6 > self.y then
            self.dy = PADDLE_SPEED * 0.6
        elseif ball.y - 6 < self.y then
            self.dy = -PADDLE_SPEED * 0.6
        end
    else    
        self.dy = 0
    end
end
