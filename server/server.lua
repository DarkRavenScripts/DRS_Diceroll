math.randomseed(os.time())

local function parseNotation(str)
    if not str then
        return Config.DefaultDice, Config.DefaultSides
    end

    local lower = tostring(str):lower()

    -- NdN or dN format (e.g. 2d6, d20)
    local diceStr, sidesStr = lower:match('^(%d*)d(%d+)$')
    if sidesStr then
        local dice = (diceStr == nil or diceStr == '') and Config.DefaultDice or tonumber(diceStr)
        return math.max(1, dice), tonumber(sidesStr)
    end

    -- Plain number = number of sides, single die (e.g. /roll 20)
    local sides = tonumber(lower)
    if sides then
        return Config.DefaultDice, sides
    end

    return nil, nil
end

local function handleRoll(source, notation)
    local dice, sides = parseNotation(notation)

    if not dice or not sides then
        TriggerClientEvent('drs_diceroll:notify', source, {
            title = 'Dice Roll',
            description = 'Invalid input. Examples: /roll 2d6  /roll d20  /roll 6',
            type = 'error',
            duration = 5000
        })
        return
    end

    if sides < Config.MinSides or sides > Config.MaxSides then
        TriggerClientEvent('drs_diceroll:notify', source, {
            title = 'Dice Roll',
            description = ('Sides must be between %d and %d.'):format(Config.MinSides, Config.MaxSides),
            type = 'error',
            duration = 4000
        })
        return
    end

    if dice < Config.MinDice or dice > Config.MaxDice then
        TriggerClientEvent('drs_diceroll:notify', source, {
            title = 'Dice Roll',
            description = ('Dice count must be between %d and %d.'):format(Config.MinDice, Config.MaxDice),
            type = 'error',
            duration = 4000
        })
        return
    end

    -- Server-side roll — clients cannot manipulate this
    local results, total = {}, 0
    for i = 1, dice do
        local r = math.random(1, sides)
        results[i] = r
        total = total + r
    end

    local notation_str = ('%dd%d'):format(dice, sides)
    local playerName = GetPlayerName(source)
    local displayText

    if dice == 1 then
        displayText = playerName .. ' rolled ' .. notation_str .. ': ' .. results[1]
    else
        displayText = playerName .. ' rolled ' .. notation_str .. ': [' .. table.concat(results, ', ') .. '] = ' .. total
    end

    -- Private notification to the roller
    local privateDesc
    if dice == 1 then
        privateDesc = 'Result: ' .. results[1]
    else
        privateDesc = 'Results: [' .. table.concat(results, ', ') .. '] — Total: ' .. total
    end

    TriggerClientEvent('drs_diceroll:notify', source, {
        title = 'You rolled ' .. notation_str,
        description = privateDesc,
        type = 'inform',
        duration = 5000
    })

    -- Broadcast 3D text to nearby players (server filters by proximity)
    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)

    for _, pidStr in ipairs(GetPlayers()) do
        local pid = tonumber(pidStr)
        local ped = GetPlayerPed(pid)
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            if #(sourceCoords - coords) <= Config.ProximityRange then
                TriggerClientEvent('drs_diceroll:display', pid, source, displayText)
            end
        end
    end
end

RegisterCommand(Config.Command, function(source, args)
    if source == 0 then return end
    handleRoll(source, args[1])
end, false)

if Config.CommandAlias and Config.CommandAlias ~= Config.Command then
    RegisterCommand(Config.CommandAlias, function(source, args)
        if source == 0 then return end
        handleRoll(source, args[1])
    end, false)
end
