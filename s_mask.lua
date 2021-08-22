--[[
    ^ Author: qwertick (Qwertick#1210)
]]

local boneAT = exports["bone_attach"]
local coolDown = {}
local mask = {}

addEvent("server:mask", true)
addEventHandler("server:mask", resourceRoot, function()
    if (client) then
        local query = dbQuery(database, "SELECT mask FROM users WHERE uid=? LIMIT 1", tonumber(getElementData(client, "uid")))
        local result = dbPoll(query, -1)
        result[1].mask = (result[1].mask and fromJSON(result[1].mask) or {})
        
        if (result[1].mask.id) then
            if (coolDown[client] and getTickCount() - coolDown[client] < 5 * 1000) then
                outputChatBox("Odczekaj chwilę zanim znów wykonasz tą akcje!", client, 200, 50, 50)
                return
            end
            coolDown[client] = getTickCount()

            if (not getElementData(client, "mask")) then
                setPedAnimation(client, "GRAVEYARD", "mrnF_loop", 1750, false, false, false, false)
                setTimer(function(client)
                    mask[client] = createObject(result[1].mask.id, 0, 0, 0)
                    setObjectScale(mask[client], 1.3)
                    boneAT:attachElementToBone(mask[client], client, 6,     -0.03, 0.18, -0.02, -90, 75, 90)

                    setElementData(client, "mask", {mask = mask[client], name = result[1].mask.name, id = result[1].mask.id})
                end, 1750, 1, client)
            else
                if (isElement(mask[client])) then
                    setElementData(client, "mask", false)
                    setPedAnimation(client, "GRAVEYARD", "mrnF_loop", 1750, false, false, false, false)
                    setTimer(function(client)
                        destroyElement(mask[client])
                        mask[client] = nil
                    end, 1750, 1, client)
                end
            end
        end
    end
end)