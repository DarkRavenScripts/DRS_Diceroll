local activeRolls = {}

local function DrawText3D(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    local factor = #text / 370.0
    DrawRect(sx, sy + 0.0135, 0.02 + factor, 0.034, 0, 0, 0, 160)

    SetTextScale(0.38, 0.38)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 225)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(sx, sy)
end

RegisterNetEvent('drs_diceroll:notify', function(opts)
    lib.notify(opts)
end)

-- Server already proximity-filtered who receives this event
RegisterNetEvent('drs_diceroll:display', function(playerServerId, text)
    if type(text) ~= 'string' or text == '' then return end
    activeRolls[playerServerId] = {
        text = text,
        expiry = GetGameTimer() + Config.DisplayDuration
    }
end)

CreateThread(function()
    while true do
        if next(activeRolls) then
            for sid, roll in pairs(activeRolls) do
                if GetGameTimer() >= roll.expiry then
                    activeRolls[sid] = nil
                else
                    local ped = GetPlayerPed(GetPlayerFromServerId(sid))
                    if ped ~= 0 and DoesEntityExist(ped) then
                        local coords = GetEntityCoords(ped)
                        DrawText3D(coords.x, coords.y, coords.z + 1.0, roll.text)
                    else
                        activeRolls[sid] = nil
                    end
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
