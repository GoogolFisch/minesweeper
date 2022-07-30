function player_constructor()
    -- setup player
    player = {["x"] = 0,["y"] = 0,["animation"] = 0,["counter"] = 0}
end

function player_move(maxwidth,maxheight,keyboard,level)
    local move     = false -- hased moved
    local uping    = -- move up?
    ((keyboard["w"] == true and not keyboardOld["w"]) or (keyboard["up"   ] == true and not keyboardOld["up"   ])) or
    ((keyboard["w"] == true or keyboard["up"   ]) and player.counter < 0)
    local downing  = -- move down?
    ((keyboard["s"] == true and not keyboardOld["s"]) or (keyboard["down" ] == true and not keyboardOld["down" ])) or
    ((keyboard["s"] == true or keyboard["down" ]) and player.counter < 0)
    local lefting  = -- move left?
    ((keyboard["a"] == true and not keyboardOld["a"]) or (keyboard["left" ] == true and not keyboardOld["left" ])) or
    ((keyboard["a"] == true or keyboard["left" ]) and player.counter < 0)
    local righting = -- move right?
    ((keyboard["d"] == true and not keyboardOld["d"]) or (keyboard["right"] == true and not keyboardOld["right"])) or
    ((keyboard["d"] == true or keyboard["right"]) and player.counter < 0)
    if uping and level[player.y    ] ~= nil and level[player.y    ][player.x + 1] ~= 0 and level[player.y    ][player.x + 1] < 20 then -- can move up
        player.y = math.max(0,player.y - 1)
        player.animation = 1
        move = true
    end
    if downing and level[player.y + 2] ~= nil and level[player.y + 2][player.x + 1] ~= 0 and level[player.y + 2][player.x + 1] < 20 then -- can move down
        player.y = math.min(maxheight,player.y + 1)
        player.animation = 3
        move = true
    end
    if lefting and level[player.y + 1][player.x    ] ~= nil and level[player.y + 1][player.x    ] ~= 0 and level[player.y + 1][player.x    ] < 20 then -- can move left
        player.x = math.max(0,player.x - 1)
        player.animation = 2
        move = true
    end
    if righting and level[player.y + 1][player.x + 2] ~= nil and level[player.y + 1][player.x + 2] ~= 0 and level[player.y + 1][player.x + 2] < 20 then -- can move right
        player.x = math.min(maxwidth,player.x + 1)
        player.animation = 4
        move = true
    end
    return move -- hased moved
end

function player_draw(offx,offy,endet,win)
    if endet and not win then -- lost
        love.graphics.draw(tileset,sprite[7],player.x * tileW + offx,player.y * tileH + offy,0,tileW * .125,tileH * .125)
    else -- draw player
        if player.animation == 0 then
            love.graphics.draw(tileset,sprite[2],player.x * tileW + offx,player.y * tileH + offy,0,tileW * .125,tileH * .125)
        elseif player.animation == 1 then
            love.graphics.draw(tileset,sprite[3],player.x * tileW + offx,(player.y + player.counter * 4) * tileH + offy,0,tileW * .125,tileH * .125)
        elseif player.animation == 2 then
            love.graphics.draw(tileset,sprite[4],(player.x + player.counter * 4) * tileW + offx,player.y * tileH + offy,0,tileW * .125,tileH * .125)
        elseif player.animation == 3 then
            love.graphics.draw(tileset,sprite[5],player.x * tileW + offx,(player.y - player.counter * 4) * tileH + offy,0,tileW * .125,tileH * .125)
        elseif player.animation == 4 then
            love.graphics.draw(tileset,sprite[6],(player.x - player.counter * 4) * tileW + offx,player.y * tileH + offy,0,tileW * .125,tileH * .125)
        end
    end
end