function tileset_loadAll()
    -- load picture
    tileset = love.graphics.newImage("images.png")
end

function generateQuads(atlas, tilewidth, tileheight)
    -- generate Quads
    local sheetWidth  = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getWidth() / tileheight
    local sheetCounter = 1;local quads = {}
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            quads[sheetCounter] = 
            love.graphics.newQuad(x * tilewidth, y * tileheight,tilewidth,tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end
    return quads
end

function displayLevel(level,width,height,offx,offy,bombs,win)
    lowW = #(level[1])
    lowH = #(level)
    local ndeg = math.pi * .5
    tileW = width  / lowW
    tileH = height / lowH
    local ib = {[true] = 1,[false] = 0};local iB = {[false] = 1,[true] = 0}
    for y = 0, lowH - 1,1 do
        for x = 0, lowW - 1,1 do
            if level[y + 1][x + 1] == 0 then -- wall  Hell
                local left = ((x     < 1   ) or (level[y + 1][x    ] == 0))
                local up__ = ((y     < 1   ) or (level[y    ][x + 1] == 0))
                local rigt = ((x + 2 > lowW) or (level[y + 1][x + 2] == 0)) -- right
                local down = ((y + 2 > lowH) or (level[y + 2][x + 1] == 0))
                if left and up__ and rigt and down then -- full square
                    love.graphics.draw(tileset,sprite[9],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                elseif ib[left] + ib[up__] + ib[rigt] + ib[down] == 3 then -- one side missing
                    local rot = ndeg * iB[up__] + ndeg * iB[rigt] * 2 + ndeg * iB[down] * 3
                    love.graphics.draw(
                        tileset,sprite[10],(x + iB[rigt] + iB[up__]) * tileW + offx,(y + iB[down] + iB[rigt]) * tileH + offy,
                        rot,tileW * .125,tileH * .125
                    )
                elseif ib[left] + ib[rigt] == 2 or ib[up__] + ib[down] == 2 then -- oppisit sides missing
                    love.graphics.draw(
                        tileset,sprite[12],(x + ib[left]) * tileW + offx,y * tileH + offy,ndeg * ib[left],tileW * .125,tileH * .125
                    )
                elseif ib[left] + ib[up__] + ib[rigt] + ib[down] == 2 then -- two ear sides missing
                    local rot = 0;local ox = 0;local oy = 0 -- define everything
                    if rigt and up__ then rot = 3 * ndeg;oy = 1 -- offsets
                    elseif left and up__ then rot = 2 * ndeg;ox = 1;oy = 1 -- offsets
                    elseif down and left then rot = ndeg;ox = 1 -- offsets
                    end
                    love.graphics.draw(
                        tileset,sprite[11],(x + ox) * tileW + offx,(y + oy) * tileH + offy,rot,tileW * .125,tileH * .125
                    )
                elseif ib[left] + ib[up__] + ib[rigt] + ib[down] == 1 then -- one side
                    local rot = ndeg * ib[up__] + ndeg * ib[rigt] * 2 + ndeg * ib[down] * 3
                    love.graphics.draw(
                        tileset,sprite[13],(x + ib[rigt] + ib[up__]) * tileW + offx,(y + ib[down] + ib[rigt]) * tileH + offy,
                        rot,tileW * .125,tileH * .125
                    )
                elseif ib[left] + ib[up__] + ib[rigt] + ib[down] == 0 then -- one side
                    love.graphics.draw(
                        tileset,sprite[14],(x + ib[rigt] + ib[up__]) * tileW + offx,(y + ib[down] + ib[rigt]) * tileH + offy,
                        0,tileW * .125,tileH * .125
                    )
                end
                -- level[y + 1][x + 1] == 0
            elseif level[y + 1][x + 1] == 1 then
                love.graphics.draw(tileset,sprite[1],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
            elseif level[y + 1][x + 1] == 2 then
                -- mines around the tile
                local a = 
                ib[((x     > 0    and y     > 0   ) and (level[y    ][x    ] == 3))] +
                ib[((                 y     > 0   ) and (level[y    ][x + 1] == 3))] +
                ib[((x + 1 < lowW and y     > 0   ) and (level[y    ][x + 2] == 3))] +
                ib[((x + 1 < lowW                 ) and (level[y + 1][x + 2] == 3))] +
                ib[((x + 1 < lowW and y + 1 < lowH) and (level[y + 2][x + 2] == 3))] +
                ib[((                 y + 1 < lowH) and (level[y + 2][x + 1] == 3))] +
                ib[((x     > 0    and y + 1 < lowH) and (level[y + 2][x    ] == 3))] +
                ib[((x     > 0                    ) and (level[y + 1][x    ] == 3))]

                if a == 0 then
                    love.graphics.draw(tileset,sprite[17],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                elseif a == 1 then
                    love.graphics.draw(tileset,sprite[18],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                elseif a == 2 then
                    love.graphics.draw(tileset,sprite[19],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                elseif a == 3 then
                    love.graphics.draw(tileset,sprite[20],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                elseif a == 4 then
                    love.graphics.draw(tileset,sprite[21],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                elseif a > 4 then love.graphics.draw(tileset,sprite[22],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
                end
                -- level[y + 1][x + 1] == 2
            elseif level[y + 1][x + 1] == 3 and bombs then
                love.graphics.draw(tileset,sprite[23],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
            elseif level[y + 1][x + 1] == 3 then
                love.graphics.draw(tileset,sprite[1],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
            elseif level[y + 1][x + 1] == 5 then
                love.graphics.draw(tileset,sprite[24],x * tileW + offx,y * tileH + offy,0,tileW * .125,tileH * .125)
            end
        end -- [x = 0, lowW - 1,1]
    end -- [y = 0, lowH - 1,1]
end