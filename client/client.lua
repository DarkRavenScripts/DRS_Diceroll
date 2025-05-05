local activeRolls = {}

-- Function to draw 3D text at given coordinates
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

-- Command to roll dice
RegisterCommand("rolldice", function(source, args, rawCommand)
    local sides = Config.DefaultSides
    local dice = Config.DefaultDice
    
    -- Parse arguments
    if #args >= 1 then
        sides = tonumber(args[1]) or Config.DefaultSides
    end
    if #args >= 2 then
        dice = tonumber(args[2]) or Config.DefaultDice
    end
    
    -- Validate inputs
    if sides < Config.MinSides or sides > Config.MaxSides or dice < Config.MinDice or dice > Config.MaxDice then
        return
    end
    
    -- Perform roll
    local results = {}
    for i = 1, dice do
        results[i] = math.random(1, sides)
    end
    
    -- Format results
    local displayText = string.format("Rolled %d %d-sided dice: %s", dice, sides, table.concat(results, ", "))
    
    -- Broadcast roll
    TriggerServerEvent('rolldice:broadcast', displayText)
end, false)

-- Client event to receive roll
RegisterNetEvent('rolldice:receive')
AddEventHandler('rolldice:receive', function(playerServerId, text)
    if not text or type(text) ~= "string" or text == "" then
        return
    end
    activeRolls[playerServerId] = { text = text, time = GetGameTimer() + Config.DisplayDuration }
end)

-- Thread to render all active rolls
Citizen.CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())
        for playerServerId, roll in pairs(activeRolls) do
            local playerPed = GetPlayerPed(GetPlayerFromServerId(playerServerId))
            if playerPed ~= 0 and DoesEntityExist(playerPed) then
                local pedPos = GetEntityCoords(playerPed)
                local distance = #(playerPos - pedPos)
                if distance <= Config.ProximityRange and GetGameTimer() < roll.time then
                    DrawText3D(pedPos.x, pedPos.y, pedPos.z + 1.0, roll.text)
                else
                    activeRolls[playerServerId] = nil
                end
            else
                activeRolls[playerServerId] = nil
            end
        end
        Citizen.Wait(0)
    end
end)