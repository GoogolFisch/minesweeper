-- do not touch
-- I don't know what here happens

function loadstring(data,i)
    -- load string from " end after "
    local a = data:sub(i,i)
    local f = ""
    while a ~= '"' and i <= #data do
        f = f .. a
        i = i + 1
        a = data:sub(i,i)
    end
    return {f,i + 1}
end

function loadint(data,i)
    -- load ints form num to after num
    local a = data:sub(i,i)
    local f = 0
    local ib = {["0"]=0,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9}
    while ib[a] ~= nil and i <= #data do
        f = f * 10 + ib[a]
        i = i + 1
        a = data:sub(i,i)
    end
    return {f,i}
end

function loads(data,i,ender)
    -- loads all other
    local a = ""
    local f
    local l
    local ib = {["0"]=0,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9}
    local ending = false
    -- i = i + 1
    while not ending do
        i = i + 1
        a = data:sub(i,i)
        if a == '"' then
            -- string
            ending = true
            l = loadstring(data,i + 1)
            f = l[1]
            i = l[2]
        elseif ib[a] ~= nil then
            -- number
            ending = true
            l = loadint(data,i)
            f = l[1]
            i = l[2]
        elseif a == "[" then
            -- lists
            ending = true
            f = {}
            i = i + 1
            while a ~= "]" and i <= #data do
                -- array
                l = loads(data,i,"]")
                table.insert(f,l[1])
                i = l[2]
                a = data:sub(i,i)
                if a == "," then
                    i = i + 1 
                    a = data:sub(i,i)
                end
            end
            i = i + 1
        elseif a == "{" then
            -- dicts
            ending = true
            f = {}
            i = i + 1
            local key
            while a ~= "}" and i <= #data do
                -- 1st load:2n load
                l = loads(data,i,":")
                key = l[1]
                l = loads(data,l[2] + 1,"}")
                f[key] = l[1]
                i = l[2]
                a = data:sub(i,i)
                if a == "," then
                    i = i + 1 
                    a = data:sub(i,i)
                end
            end
            i = i + 1
        elseif i > #data or ender == a then
            -- end of file
            ending = true
        end
    end
    return {f,i}
end

function load(data)
    return loads(data,0,"++")[1]
end
