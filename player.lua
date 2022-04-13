function player_constructor()
    player = {["x"] = 0,["y"] = 0,["animation"] = 0,["counter"] = 0}
end

function player_move(maxwidth,maxheight,keyboard,level)
    local move = false
    local uping    = 
    ((keyboard["w"] == true and not keyboardOld["w"]) or (keyboard["up"   ] == true and not keyboardOld["up"   ])) or
    ((keyboard["w"] == true or keyboard["up"   ]) and player.counter < 0)
    local downing  = 
    ((keyboard["s"] == true and not keyboardOld["s"]) or (keyboard["down" ] == true and not keyboardOld["down" ])) or
    ((keyboard["s"] == true or keyboard["down" ]) and player.counter < 0)
    local lefting  = 
    ((keyboard["a"] == true and not keyboardOld["a"]) or (keyboard["left" ] == true and not keyboardOld["left" ])) or
    ((keyboard["a"] == true or keyboard["left" ]) and player.counter < 0)
    local righting = 
    ((keyboard["d"] == true and not keyboardOld["d"]) or (keyboard["right"] == true and not keyboardOld["right"])) or
    ((keyboard["d"] == true or keyboard["right"]) and player.counter < 0)
    if uping and level[player.y    ] ~= nil and level[player.y    ][player.x + 1] ~= 0 then
        player.y = math.max(0,player.y - 1)
        player.animation = 1
        move = true
    end
    if downing and level[player.y + 2] ~= nil and level[player.y + 2][player.x + 1] ~= 0 then
        player.y = math.min(maxheight,player.y + 1)
        player.animation = 3
        move = true
    end
    if lefting and level[player.y + 1][player.x    ] ~= nil and level[player.y + 1][player.x    ] ~= 0 then
        player.x = math.max(0,player.x - 1)
        player.animation = 2
        move = true
    end
    if righting and level[player.y + 1][player.x + 2] ~= nil and level[player.y + 1][player.x + 2] ~= 0 then
        player.x = math.min(maxwidth,player.x + 1)
        player.animation = 4
        move = true
    end
    return move
end