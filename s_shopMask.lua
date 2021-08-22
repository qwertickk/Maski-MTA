--[[
    ^ Author: qwertick (Qwertick#1210)
]]

database = dbConnect("mysql", "dbname=nazwa;host=host;charset=utf8", "użytkownik", "hasło")
if (database) then
    outputDebugString("[masks]: Połączono z bazą danych")
else
    outputDebugString("[masks]: Brak połączenia z bazą danych")
end

local mask ={
    shop = {},
    shops = {
        ["Los Santos"] = {
            position = {1716.24, -1715.37, 13.50},
            dimension = 0,
            interior = 0,
            nameShop = "Maski Los Santos"
        },
    }
}

for k,v in pairs(mask.shops) do
    local marker = createMarker(v.position[1], v.position[2], v.position[3] - 1, "cylinder", 1.1, 255, 255, 255, 100)
    local blip = createBlipAttachedTo(marker, 23)
    setBlipVisibleDistance(blip, 500)
    
    setElementDimension(marker, v.dimension)
    setElementInterior(marker, v.interior)
    mask.shop[marker] = {idName = k, name = v.nameShop}
end

addEventHandler("onMarkerHit", resourceRoot, function(el, dim)
    if (getElementType(el) == "player" and dim and not getPedOccupiedVehicle(el)) then
        local query = dbQuery(database, "SELECT mask FROM users WHERE uid=? LIMIT 1", tonumber(getElementData(el, "uid")))
        local result = dbPoll(query, -1)
        result[1].mask = (result[1].mask and fromJSON(result[1].mask) or {})
        triggerClientEvent(el, "client:mask_openShop", resourceRoot, result[1].mask, mask.shop[source].name)
    end
end)

addEvent("server:mask_buy", true)
addEventHandler("server:mask_buy", resourceRoot, function(table)
    if (client and table and type(table) == "table") then
        takePlayerMoney(client, table.mask.price)
        local mask = {name = table.name, id = table.mask.id}
        dbExec(database, "UPDATE users SET mask=? WHERE uid=? LIMIT 1", toJSON(mask), tonumber(getElementData(client, "uid")))

        -- update
        local query = dbQuery(database, "SELECT mask FROM users WHERE uid=? LIMIT 1", tonumber(getElementData(client, "uid")))
        local result = dbPoll(query, -1)
        result[1].mask = (result[1].mask and fromJSON(result[1].mask) or {})
        triggerClientEvent(client, "client:mask_update", resourceRoot, result[1].mask)
    end
end)