CLASS = require 'class'
PUSH = require 'push'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
WINDOW_TABLE = { 
    fullscreen = false, 
    vsync = true, 
    resizable = true
}

SUCCESS_EXIT = 0
FAIL_EXIT = 1

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

FONT_LOCATION = 'main.ttf'
FONT_SIZE_SMALL = 8
FONT_SIZE_SCORE = 32
FONT_SIZE_VICTORY = 24

SMALL_FONT = love.graphics.newFont(
    FONT_LOCATION, 
    FONT_SIZE_SMALL
)
SCORE_FONT = love.graphics.newFont(
    FONT_LOCATION, 
    FONT_SIZE_SCORE
)
VICTORY_FONT = love.graphics.newFont(
    FONT_LOCATION,
    FONT_SIZE_VICTORY
)

BALL_WIDTH = 5
BALL_HEIGHT = 5

BALL_START_WIDTH = (VIRTUAL_WIDTH / 2 - 2)
BALL_START_HEIGHT = (VIRTUAL_HEIGHT / 2 - 2)

BALL = love.graphics.rectangle(
    'fill',
    BALL_START_WIDTH,
    BALL_START_HEIGHT,
    BALL_WIDTH,
    BALL_HEIGHT
)

PLAYER_WIDTH = 5
PLAYER_HEIGHT = 20
PLAYER1_START_WIDTH = 5
PLAYER1_START_HEIGHT = 20
PLAYER2_START_WIDTH = (VIRTUAL_WIDTH - 10)
PLAYER2_START_HEIGHT = (VIRTUAL_HEIGHT - 40)
PLAYER1 = love.graphics.rectangle(
    'fill',
    PLAYER1_START_WIDTH,
    PLAYER1_START_HEIGHT,
    PLAYER_WIDTH,
    PLAYER_HEIGHT
)
PLAYER2 = love.graphics.rectangle(
    'fill',
    PLAYER2_START_WIDTH,
    PLAYER2_START_HEIGHT,
    PLAYER_WIDTH,
    PLAYER_HEIGHT
)
PLAYER_START_SCORE = 0
VICTORY_SCORE = 10

PADDLE_SPEED = 200
BALL_SPEED = 0
GAMESTATES = { 
    start = 'Start', 
    playing = 'Playing', 
    serve = 'Serve', 
    paused = 'Paused', 
    finished = 'Finished' 
}
SOUNDS = {
    paddle_hit = love.audio.newSource('paddle_hit.wav', 'static'),
    wall_hit = love.audio.newSource('wall_hit.wav', 'static'),
    point_scored = love.audio.newSource('point_scored.wav', 'static')
}

function love.load()

    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Pong")
    PUSH:setupScreen(
        VIRTUAL_WIDTH, 
        VIRTUAL_HEIGHT, 
        WINDOW_WIDTH, 
        WINDOW_HEIGHT, 
        WINDOW_TABLE
    )
    gameState = GAMESTATES.start
    player1AI = false 
    player2AI = false
    instanciateGameObjects()
    setPlayersAndBallToStart()
end

function love.resize(w, h)
    PUSH:resize(w, h)
end

function love.update(dt)
    if gameState == GAMESTATES.playing then 
        player1:AI(ball, 1)
        player2:AI(ball, 2)
        verifyBallPoint()
        verifyBallCollision()
        verifyKeyboardDown()

        player1:update(dt)
        player2:update(dt)

        ball:update(dt)
    end
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit(SUCCESS_EXIT)
    end

    if key == 'enter' or key == 'return' then 
        if gameState == GAMESTATES.start then 
            gameState = GAMESTATES.serve
        elseif gameState == GAMESTATES.finished then 
            gameState = GAMESTATES.start
            setPlayersAndBallToStart()
        elseif gameState == GAMESTATES.serve then 
            gameState = GAMESTATES.playing
        end
    end

    if gameState == GAMESTATES.start then 
        if key == '1' then
            if player1AI == false then
                player1AI = true
            else
                player1AI = false
            end
        end

        if key == '2' then
            if player2AI == false then
                player2AI = true
            else
                player2AI = false
            end 
        end 
    end
end

function love.draw()
    PUSH:apply('start')

    love.graphics.clear(
        (40/255), 
        (45/255), 
        (52/255), 
        (255/255)
    )
 
    drawTitle()

    drawPlayerScore()

    loadObjects()
    
    displayFPS()

    PUSH:apply('end')
end

function verifyKeyboardDown()
    if player1AI == false then
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s')then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end
    end

    if player2AI == false then
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else    
            player2.dy = 0
        end
    end
end

function instanciateGameObjects()
    ball = Ball(BALL_START_WIDTH, BALL_START_HEIGHT, BALL_WIDTH, BALL_HEIGHT)
    player1 = Paddle(PLAYER1_START_WIDTH, PLAYER1_START_HEIGHT, PLAYER_WIDTH, PLAYER_HEIGHT)
    player2 = Paddle(PLAYER2_START_WIDTH, PLAYER2_START_HEIGHT, PLAYER_WIDTH, PLAYER_HEIGHT)
end

function verifyBallPoint()
    if ball.x < 0 then 
        SOUNDS.point_scored:play()
        player2Score = player2Score + 1
        ball:reset()
        servingPlayer = 1
        ball.dx = 100

        if player2Score >= VICTORY_SCORE then 
            gameState = GAMESTATES.finished
            winningPlayer = 2
        else
            gameState = GAMESTATES.serve
        end
    end

    if ball.x > VIRTUAL_WIDTH - 4 then 
        SOUNDS.point_scored:play()
        player1Score = player1Score + 1
        ball:reset()
        servingPlayer = 2
        ball.dx = -100

        if player1Score >= VICTORY_SCORE then 
            gameState = GAMESTATES.finished
            winningPlayer = 1
        else
            gameState = GAMESTATES.serve
        end
    end
end

function verifyBallCollision()
    if ball:collides(player1) then 
        SOUNDS.paddle_hit:play()
        ball.dx = -ball.dx * 1.1
        ball.x = player1.x + PLAYER_WIDTH
    end

    if ball:collides(player2) then 
        SOUNDS.paddle_hit:play()
        ball.dx = -ball.dx * 1.1
        ball.x = player2.x - PLAYER_WIDTH
    end

    if ball.y <= 0 then 
        SOUNDS.wall_hit:play()
        ball.dy = -ball.dy
    end

    if ball.y + 4 >= VIRTUAL_HEIGHT then 
        SOUNDS.wall_hit:play()
        ball.dy = -ball.dy
    end
end

function loadObjects()
    ball:render()
    player1:render()
    player2:render()
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(SMALL_FONT)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

function drawPlayerScore()
    love.graphics.setFont(SCORE_FONT)

    love.graphics.print(
        player1Score, 
        VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3
    )
    love.graphics.print(
        player2Score, 
        VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3
    )
end

function drawTitle()
    
    if gameState == GAMESTATES.start then 
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf(
                "Welcome to Pong!", 
            0, 
            10, 
            VIRTUAL_WIDTH, 
            "center"
        )
        love.graphics.printf(
            "Press 1 or 2 to toggle players AI then Press Enter to play!", 
            0, 
            32, 
            VIRTUAL_WIDTH, 
            "center"
        )
        if player1AI == false and player2AI == false then
            love.graphics.printf(
                "Player 1 AI OFF - Player 2 AI OFF", 
                0, 
                42, 
                VIRTUAL_WIDTH, 
                "center"
            )
        elseif player1AI == true and player2AI == false then 
            love.graphics.printf(
                "Player 1 AI ON - Player 2 AI OFF", 
                0, 
                42, 
                VIRTUAL_WIDTH, 
                "center"
            )
        elseif player2AI == true and player1AI == false then
            love.graphics.printf(
                "Player 1 AI OFF - Player 2 AI ON", 
                0, 
                42, 
                VIRTUAL_WIDTH, 
                "center"
            ) 
        elseif player1AI == true and player2AI == true then  
            love.graphics.printf(
                "Player 1 AI ON- Player 2 AI ON", 
                0, 
                42, 
                VIRTUAL_WIDTH, 
                "center"
            )  
        end
    elseif gameState == GAMESTATES.serve then 
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf(
            "Player " .. tostring(servingPlayer) .. "'s turn!", 
            0, 
            10, 
            VIRTUAL_WIDTH, 
            "center"
        )
        love.graphics.printf(
            "Press Enter to serve!", 
            0, 
            32, 
            VIRTUAL_WIDTH, 
            "center"
        )
    elseif gameState == GAMESTATES.finished then 
        love.graphics.setFont(VICTORY_FONT)
        love.graphics.printf(
            "Player " .. tostring(winningPlayer) .. " Wins!", 
            0, 
            10, 
            VIRTUAL_WIDTH, 
            "center"
        )
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf(
            "Press Enter to restart!", 
            0, 
            42, 
            VIRTUAL_WIDTH, 
            "center"
        )
    end 
end

function setPlayersAndBallToStart()
    player1Score = PLAYER_START_SCORE
    player2Score = PLAYER_START_SCORE
    servingPlayer = math.random(2) == 1 and 1 or 2

    if servingPlayer == 1 then 
        ball.dx = 100
    else
        ball.dx = -100
    end
end