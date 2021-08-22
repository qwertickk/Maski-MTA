--[[
    ^ Author: qwertick (Qwertick#1210)
]]

local sx, sy = guiGetScreenSize()
local zoom = (sx < 1920 and math.min(2, 1920/sx) or 1)

local unpack = unpack
local pairs = pairs

local textures = {
    images = {"hockeymask", "hockeymask2", "hockeymask3"},
    elements = {}
}

local mask = {
    shop = {
        owned = {},
        name = nil
    },
    enabled = false,
    selected = {name = nil, mask = nil},
    dxPos = {
        bg = {sx/2 - 650/2/zoom, sy/2 - 450/2/zoom, 650/zoom, 450/zoom, tocolor(0, 0, 0, 200)},
        textName = {sx/2 - 650/2/zoom, sy/2 - 190/zoom, 650/zoom + (sx/2 - 650/2/zoom), nil, white, 2/zoom, "default-bold", "center", "center"},
        buttonBuy = {sx/2 - 200/zoom, sy/2 + 125/zoom, 175/zoom, 50/zoom, tocolor(50, 200, 50)},
        buttonClose = {sx/2 + 30/zoom, sy/2 + 125/zoom, 175/zoom, 50/zoom, tocolor(50, 200, 50)},
        textBuy = {"Zakup", sx/2 - 200/zoom, sy/2 + 125/zoom, 175/zoom + (sx/2 - 200/zoom), 50/zoom + (sy/2 + 125/zoom), white, 2/zoom, "default-bold", "center", "center"},
        textClose = {"Zamknij", sx/2 + 30/zoom, sy/2 + 125/zoom, 175/zoom + (sx/2 + 30/zoom), 50/zoom + (sy/2 + 125/zoom), white, 2/zoom, "default-bold", "center", "center"},

        mask = {sx/2 + 130/zoom, sy/2 - 100/zoom, 73/zoom, 101/zoom},
        infoText = {sx/2 + 175/zoom, sy/2 + 50/zoom}
    },
    items = {
        ["Biała maska"] = {id = 1950, image = "hockeymask", price = 2000},
        ["Czerwona maska"] = {id = 1951, image = "hockeymask2", price = 3000},
        ["Zielona maska"] = {id = 1952, image = "hockeymask3", price = 4000},
    },
    colors = {
        textHover = tocolor(175, 175, 175),
        textActive = tocolor(175, 25, 25)
    }
}

local function drawInterface()
    dxDrawRectangle(unpack(mask.dxPos.bg))
    dxDrawText(mask.shop.name, unpack(mask.dxPos.textName))
    dxDrawRectangle(unpack(mask.dxPos.buttonBuy))
    dxDrawText(unpack(mask.dxPos.textBuy))
    dxDrawRectangle(unpack(mask.dxPos.buttonClose))
    dxDrawText(unpack(mask.dxPos.textClose))

    local offsetX = 0
    for k,v in pairs(mask.items) do
        dxDrawImage(mask.dxPos.mask[1] + (offsetX * -175/zoom), mask.dxPos.mask[2], mask.dxPos.mask[3], mask.dxPos.mask[4], textures.elements[v.image])
        dxDrawText(k.."\n"..v.price.."$", mask.dxPos.infoText[1] + (offsetX * -175/zoom), mask.dxPos.infoText[2], nil, nil, (mask.shop.owned.id == v.id and mask.dxPos.buttonBuy[5] or mask.selected.mask == v and mask.colors.textActive or white or v.color), 1.25/zoom, "default-bold", "center", "center")

        if (isMouseInPosition(mask.dxPos.mask[1] + (offsetX * -175/zoom), mask.dxPos.mask[2], mask.dxPos.mask[3], mask.dxPos.mask[4])) then
            v.color = mask.colors.textHover
        else
            v.color = white
        end
        offsetX = offsetX + 1
    end
end

local function clickButton(button, state)
    if (button == "left" and state == "down" and mask.enabled) then
        local offsetX = 0
        for k,v in pairs(mask.items) do
            if (isMouseInPosition(mask.dxPos.mask[1] + (offsetX * -175/zoom), mask.dxPos.mask[2], mask.dxPos.mask[3], mask.dxPos.mask[4])) then
                mask.selected = {name = k, mask = v}
            end
            offsetX = offsetX + 1
        end
        if (isMouseInPosition(unpack(mask.dxPos.buttonBuy)) and mask.selected.mask) then
            if (mask.shop.owned.id == mask.selected.mask.id) then
                return
            elseif (getPlayerMoney(localPlayer) < mask.selected.mask.price) then
                outputChatBox("Nie stać cię na tą maskę!", 200, 25, 25)
                return
            elseif (mask.shop.owned.id) then
                outputChatBox("Posiadasz już maskę!", 200, 25, 25)
                return
            end

            outputChatBox("Zakupiłeś #afafaf"..mask.selected.name.."#ffffff za "..mask.selected.mask.price.."#32c832$", 255, 255, 255, true)
            triggerServerEvent("server:mask_buy", resourceRoot, mask.selected)
        elseif (isMouseInPosition(unpack(mask.dxPos.buttonClose))) then
            mask.shop = {owned = {}, name = nil}
            mask.enabled = false
            mask.selected = {name = nil, mask = nil}
            showCursor(false)
            removeEventHandler("onClientRender", root, drawInterface)
            removeEventHandler("onClientClick", root, clickButton)
            tex("destroy")
        end
    end
end

-- triggers
addEvent("client:mask_openShop", true)
addEventHandler("client:mask_openShop", resourceRoot, function(table, name)
    mask.shop.owned = table
    mask.shop.name = name
    mask.enabled = true
    tex("create")
    showCursor(true)
    addEventHandler("onClientRender", root, drawInterface)
    addEventHandler("onClientClick", root, clickButton)
end)

addEvent("client:mask_update", true)
addEventHandler("client:mask_update", resourceRoot, function(table)
    mask.shop.owned = table
end)

-- useful
function tex(state)
    if (state == "create") then
        for _,v in pairs(textures.images) do
            if (not textures.elements[v]) then
                textures.elements[v] = dxCreateTexture("files/images/"..v..".png", "argb", false, "clamp")
            end
        end
    elseif (state == "destroy") then
        for _,v in pairs(textures.elements) do
            destroyElement(v)
            v = nil
            textures.elements = {}
        end
    end
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end