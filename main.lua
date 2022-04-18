function love.load()
    require("tileset")
    require("player")
    love.window.setTitle("MineSeeker")

    player_constructor()
    keyboard = {["?"] = false}
    keyboardOld = {["?"] = false}
    love.graphics.setDefaultFilter("nearest","nearest")
    tileset_loadAll()
    sprite = generateQuads(tileset,8,8)
    newfont = love.graphics.newFont(60)

    level = {}
    gametype = 0
    local sublevel
    local value
    local x,y

    local ending
    wall = 8

    width  = 30
    height = 20
    bombs  = 60

    mouse = {["x"]=0,["y"]=0,["dx"]=0,["dy"]=0}

    love.window.setMode(1600,900,{["resizable"]=true,["centered"]=true})

    setup()
    gametype = 0
end

function setup()
    -- setgametype
    local sublevel
    local value
    local ending
    timer = 0
    steps = 0

    gametype = 100
    w_h = width  / height
    h_w = height / width
    level  = {}
    player_constructor()
    -- generate board
    math.randomseed( os.time() )
    math.random() math.random() math.random()
    for y=1,height,1 do
        sublevel = {}
        for x=1,width,1 do
            if math.random(0,wall) == 0 then
                table.insert(sublevel,0)
            else
                table.insert(sublevel,1)
            end
        end
        table.insert(level,sublevel)
    end

    -- put bombs
    level[1][1] = 2
    level[1][2] = 2
    level[2][1] = 2
    level[height][width] = 5

    for value=1,bombs do
        ending = true
        while ending do
            y = math.random(1,height)
            x = math.random(1,width)
            if level[y][x] == 1 then
                level[y][x] = 3
                ending = false
            end
        end
    end
end

function love.update(dt)
    player.counter = player.counter - dt
    
    if keyboard["r"] then -- regenerate
        setup()
    elseif keyboard["m"] then -- back to start
        gametype = 0
    elseif player.counter < 0 then
        player.animation = 0
    end
    if gametype == 0 then -- quit(optional)
        if keyboard["q"] then
            love.event.quit(0)
        end
    elseif gametype == 100 then
        timer = timer + dt
        if player_move(width,height,keyboard,level) then
            -- if moved
            steps = steps + 1

            player.counter = 0.25 -- set animation
            if level[player.y + 1][player.x + 1] == 1 or level[player.y + 1][player.x + 1] == 2 then
                -- if walkable
                level[player.y + 1][player.x + 1] = 2
                local ib = {[true] = 1,[false] = 0}
                local lowW = #(level[1])
                local lowH = #(level)
                -- near bombs count
                local a = 
                ib[((player.x     > 0    and player.y     > 0   ) and (level[player.y    ][player.x    ] == 3))] +
                ib[((                        player.y     > 0   ) and (level[player.y    ][player.x + 1] == 3))] +
                ib[((player.x + 1 < lowW and player.y     > 0   ) and (level[player.y    ][player.x + 2] == 3))] +
                ib[((player.x + 1 < lowW                        ) and (level[player.y + 1][player.x + 2] == 3))] +
                ib[((player.x + 1 < lowW and player.y + 1 < lowH) and (level[player.y + 2][player.x + 2] == 3))] +
                ib[((                        player.y + 1 < lowH) and (level[player.y + 2][player.x + 1] == 3))] +
                ib[((player.x     > 0    and player.y + 1 < lowH) and (level[player.y + 2][player.x    ] == 3))] +
                ib[((player.x     > 0                           ) and (level[player.y + 1][player.x    ] == 3))]
                if a == 0 then
                    -- reveal tiles
                    if  level[player.y] and level[player.y][player.x] == 1 then
                        level[player.y][player.x] = 2
                    end
                    if  level[player.y] and level[player.y][player.x + 1] == 1 then
                        level[player.y][player.x + 1] = 2
                    end
                    if  level[player.y] and level[player.y][player.x + 2] == 1 then
                        level[player.y][player.x + 2] = 2
                    end
                    if  level[player.y + 1][player.x] == 1 then
                        level[player.y + 1][player.x] = 2
                    end
                    if  level[player.y + 1][player.x + 2] == 1 then
                        level[player.y + 1][player.x + 2] = 2
                    end
                    if  level[player.y + 2] and level[player.y + 2][player.x] == 1 then
                        level[player.y + 2][player.x] = 2
                    end
                    if  level[player.y + 2] and level[player.y + 2][player.x + 1] == 1 then
                        level[player.y + 2][player.x + 1] = 2
                    end
                    if  level[player.y + 2] and level[player.y + 2][player.x + 2] == 1 then
                        level[player.y + 2][player.x + 2] = 2
                    end
                end
            elseif level[player.y + 1][player.x + 1] == 3 then
                -- bombs
                gametype = 110
            elseif level[player.y + 1][player.x + 1] == 5 then
                -- win
                gametype = 120
            end
        end
    elseif gametype == 110 then
        -- dead
    elseif gametype == 120 then
        -- won
    end
end

function love.draw()
    minsize = math.min(love.graphics.getWidth(),love.graphics.getHeight())
    if gametype == 0 then
        love.graphics.setFont(newfont)
        love.graphics.print("Play Game?\"r\"")

        love.graphics.setColor(0.25,0.25,0.25)
        love.graphics.rectangle("fill", 25,100,75,75) -- width
        love.graphics.rectangle("fill",125,100,75,75) -- height
        love.graphics.rectangle("fill",225,100,75,75) -- wall
        love.graphics.rectangle("fill",325,100,75,75) -- bombs
        
        love.graphics.rectangle("fill", 25,250,75,75) -- width
        love.graphics.rectangle("fill",125,250,75,75) -- height
        love.graphics.rectangle("fill",225,250,75,75) -- wall
        love.graphics.rectangle("fill",325,250,75,75) -- bombs

        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.print("+", 40,100) -- width
        love.graphics.print("+",140,100) -- height
        love.graphics.print("+",240,100) -- wall
        love.graphics.print("+",340,100) -- bombs
        
        love.graphics.print("-", 50,250) -- width
        love.graphics.print("-",150,250) -- height
        love.graphics.print("-",250,250) -- wall
        love.graphics.print("-",350,250) -- bombs

        love.graphics.print("w", 40,325) -- width
        love.graphics.print("h",140,325) -- height
        love.graphics.print("w",240,325) -- wall
        love.graphics.print("b",340,325) -- bombs

        love.graphics.print("" .. width , 20,180) -- width
        love.graphics.print("" .. height,120,180) -- height
        love.graphics.print("" .. wall  ,220,180) -- wall
        love.graphics.print("" .. bombs ,320,180) -- bombs

        love.graphics.setColor(1,1,1)
        love.graphics.setBackgroundColor(0,0,0)
    elseif gametype == 100 then
        love.graphics.setBackgroundColor(0,0,0)
        displayLevel(
            level,
            minsize * w_h,minsize, -- size
            0,0, -- offsets
            false -- show bombs
        )
        love.graphics.setColor(1,0,0.5)
        player_draw(
            0,0, -- offset
            false, -- endet game
            false  -- won
        )
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(newfont)
        love.graphics.print(math.floor(timer) .. "s",minsize * w_h,0)
        love.graphics.print(steps .. "sept",minsize * w_h,48)
    elseif gametype == 110 then
        love.graphics.setBackgroundColor(1,0,0)
        displayLevel(
            level,
            minsize * w_h,minsize,
            0,0,
            true
        )
        love.graphics.setColor(1,0,0.5)
        player_draw(0,0,true,false)
        love.graphics.setColor(1,1,1)
    elseif gametype == 120 then
        love.graphics.setBackgroundColor(0,1,0)
        displayLevel(
            level,
            minsize * w_h,minsize,
            0,0,
            true
        )
        love.graphics.setColor(1,0,0.5)
        player_draw(0,0,true,true)
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(newfont)
        love.graphics.print(math.floor(timer) .. "s",minsize * w_h,0)
        love.graphics.print(steps .. "sept",minsize * w_h,48)
    end
    for x,y in pairs(keyboard) do -- save to old keyboard
        keyboardOld[x] = y
    end
end

function love.keypressed( key, scancode, isrepeat )
    keyboard[key] = true
end

function love.keyreleased(key)
    keyboard[key] = false
end


function love.mousepressed(x, y, button, istouch)
    if gametype == 0 and button == 1 then
        -- if menu
        if     x >  25 and x < 100 and y > 100 and y < 175 then -- + width
            width  = width  + 1
        elseif x > 125 and x < 200 and y > 100 and y < 175 then -- + height
            height = height + 1
        elseif x > 225 and x < 300 and y > 100 and y < 175 then -- + wall
            wall   = math.min(wall + 1,30)
        elseif x > 325 and x < 400 and y > 100 and y < 175 then -- + bombs
            bombs  = math.min(bombs + 1,math.floor(width * height * .25))
        elseif x >  25 and x < 100 and y > 250 and y < 325 then -- - width
            width  = math.max(width  - 1,4)
        elseif x > 125 and x < 200 and y > 250 and y < 325 then -- - height
            height = math.max(height - 1,4)
        elseif x > 225 and x < 300 and y > 250 and y < 325 then -- - wall
            wall   = math.max(wall - 1,1)
        elseif x > 325 and x < 400 and y > 250 and y < 325 then -- - bombs
            bombs  = math.max(bombs  - 1,math.floor(width * height * 0.01))
        elseif y < 75 and x < 300 then -- start game
            setup()
        end
    end -- gametype == 0 and button == 1
end

function love.wheelmoved(x, y)
    if     mouse.x >  25 and mouse.x < 100 and mouse.y > 175 and mouse.y < 225 then -- width
        width  = math.min(math.max(width  + y,4),60)
    elseif mouse.x > 125 and mouse.x < 200 and mouse.y > 175 and mouse.y < 225 then -- hieght
        height = math.min(math.max(height + y,4),40)
    elseif mouse.x > 225 and mouse.x < 300 and mouse.y > 175 and mouse.y < 255 then -- wall
        wall = math.max(math.min(wall + y,30),3)
    elseif mouse.x > 325 and mouse.x < 400 and mouse.y > 175 and mouse.y < 255 then -- bombs
        bombs = math.max(math.min(bombs + y,math.floor(width * height * .25)),math.floor(width * height * 0.01))
    end
end

function love.mousemoved( x, y, dx, dy, istouch ) -- isin`t used
    mouse. x =  x
    mouse. y =  y
    mouse.dx = dx
    mouse.dy = dy
end