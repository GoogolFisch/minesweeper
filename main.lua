function love.load()

    require("tileset")
    require("player")
    moonjson = require("json")

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


    if seed == nil then
        seed = os.time()
    end
    setup()
    gametype = 0

    local jsonfile = io.open(".\\levels.json","r")
    all_levels = moonjson.decode(jsonfile:read("*a"))
    io.close(jsonfile)
    if all_levels == nil then
        print("needs an json file!!")
        love.window.close()
        love.event.quit(1)
    end
    levels_select = 1
end

function setup()
    -- setgametype
    local sublevel
    local value
    local ending
    timer = 0
    steps = 0
    alltosee = 0

    gametype = 100
    w_h = width  / height
    h_w = height / width
    level  = {}
    player_constructor()
    -- generate board
    math.randomseed(seed)
    math.random() math.random() math.random()
    for y=1,height,1 do -- generate map & put walls
        sublevel = {}
        for x=1,width,1 do
            if math.random(0,wall) == 0 then
                table.insert(sublevel,0)
            else
                table.insert(sublevel,1)
                alltosee = alltosee + 1
            end
        end
        table.insert(level,sublevel)
    end

    -- put bombs
    if level[1][1] == 0 then -- count correction
        alltosee = alltosee + 1
    end
    level[1][1] = 2
    if level[1][2] == 0 then -- count correction
        alltosee = alltosee + 1
    end
    level[1][2] = 2
    if level[2][1] == 0 then -- count correction
        alltosee = alltosee + 1
    end
    level[2][1] = 2
    if level[height][width] == 1 then -- count correction
        alltosee = alltosee - 1
    end
    level[height][width] = 5
    alltosee = alltosee - bombs
    opened = 3

    for value=1,bombs do -- bomber
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
        seed   = all_levels[levels_select]["seed"  ]
        if seed == nil then
            seed = os.time()
        end
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
                if level[player.y + 1][player.x + 1] == 1 then
                    opened = opened + 1
                end
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
                        opened = opened + 1
                    end
                    if  level[player.y] and level[player.y][player.x + 1] == 1 then
                        level[player.y][player.x + 1] = 2
                        opened = opened + 1
                    end
                    if  level[player.y] and level[player.y][player.x + 2] == 1 then
                        level[player.y][player.x + 2] = 2
                        opened = opened + 1
                    end
                    if  level[player.y + 1][player.x] == 1 then
                        level[player.y + 1][player.x] = 2
                        opened = opened + 1
                    end
                    if  level[player.y + 1][player.x + 2] == 1 then
                        level[player.y + 1][player.x + 2] = 2
                        opened = opened + 1
                    end
                    if  level[player.y + 2] and level[player.y + 2][player.x] == 1 then
                        level[player.y + 2][player.x] = 2
                        opened = opened + 1
                    end
                    if  level[player.y + 2] and level[player.y + 2][player.x + 1] == 1 then
                        level[player.y + 2][player.x + 1] = 2
                        opened = opened + 1
                    end
                    if  level[player.y + 2] and level[player.y + 2][player.x + 2] == 1 then
                        level[player.y + 2][player.x + 2] = 2
                        opened = opened + 1
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
    local maxsize = minsize * w_h
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

        -- love.graphics.print("wi", 25,325) -- width
        love.graphics.draw(tileset,sprite[15],25,330,0,75 / 8)
        -- love.graphics.print("hg",125,325) -- height
        love.graphics.draw(tileset,sprite[16],125,330,0,75 / 8)
        -- love.graphics.print("wl",225,325) -- wall
        love.graphics.draw(tileset,sprite[14],225,330,0,75 / 8)
        -- love.graphics.print("bo",325,325) -- bombs
        love.graphics.draw(tileset,sprite[23],325,330,0,75 / 8)

        love.graphics.print("" .. width , 20,180) -- width
        love.graphics.print("" .. height,120,180) -- height
        love.graphics.print("" .. wall  ,220,180) -- wall
        love.graphics.print("" .. bombs ,320,180) -- bombs

        love.graphics.setColor(.25,.25,.25)
        love.graphics.rectangle("fill",25,550,700,75) -- name

        love.graphics.setColor(1,1,1)
        love.graphics.print(all_levels[((levels_select) % #all_levels) + 1]["name"],25,450) -- name
        love.graphics.print(all_levels[levels_select]["name"],25,550) -- name
        love.graphics.print(all_levels[((levels_select - 2) % #all_levels) + 1]["name"],25,650) -- name
        love.graphics.print(seed,800,450) -- name

        love.graphics.setBackgroundColor(0,0,0)
    elseif gametype == 100 then
        love.graphics.setBackgroundColor(0,0,0)
        displayLevel(
            level,
            maxsize,minsize, -- size
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
    elseif gametype == 110 then
        love.graphics.setBackgroundColor(1,0,0)
        displayLevel(
            level,
            maxsize,minsize,
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
            maxsize,minsize,
            0,0,
            true
        )
        love.graphics.setColor(1,0,0.5)
        player_draw(0,0,true,true)
        love.graphics.setColor(1,1,1)
    end

    love.graphics.setFont(newfont)
    love.graphics.print(math.floor(timer) .. "s",maxsize,0)
    love.graphics.print(steps .. "seps",maxsize,48)
    love.graphics.print(math.floor(opened / alltosee * 100) .. "%",maxsize,96)
    love.graphics.print(seed,maxsize,144)
    for x,y in pairs(keyboard) do -- save to old keyboard
        keyboardOld[x] = y
    end
    -- print(alltosee .. ":" .. opened)
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
    elseif mouse.x > 25 and mouse.x < 725 and mouse.y > 550 and mouse.y < 625 then -- bombs
        levels_select = levels_select + y
        if levels_select < 1 then
            levels_select = #all_levels
        elseif levels_select > #all_levels then
            levels_select = 1
        end
        width  = all_levels[levels_select]["width" ]
        height = all_levels[levels_select]["height"]
        wall   = all_levels[levels_select]["wall"  ]
        bombs  = all_levels[levels_select]["bombs" ]
        seed   = all_levels[levels_select]["seed"  ]
        if seed == nil then
            seed = os.time()
        end
    end
end

function love.mousemoved( x, y, dx, dy, istouch ) -- isin`t used
    mouse. x =  x
    mouse. y =  y
    mouse.dx = dx
    mouse.dy = dy
end