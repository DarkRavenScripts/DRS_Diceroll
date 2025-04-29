RegisterCommand("rolldice", function(source, args, rawCommand)
    -- Default values
    local sides = Config.DefaultSides
    local dice = Config.DefaultDice
    
    -- Parse arguments if provided
    if #args >= 1 then
        sides = tonumber(args[1]) or Config.DefaultSides
    end
    if #args >= 2 then
        dice = tonumber(args[2]) or Config.DefaultDice
    end
    
    -- Validate inputs
    if sides < Config.MinSides or sides > Config.MaxSides then
        TriggerEvent('chat:addMessage', {
            color = Config.ErrorColor,
            multiline = true,
            args = {"[RollDice]", string.format("Invalid number of sides. Please use a number between %d and %d.", Config.MinSides, Config.MaxSides)}
        })
        return
    end
    if dice < Config.MinDice or dice > Config.MaxDice then
        TriggerEvent('chat:addMessage', {
            color = Config.ErrorColor,
            multiline = true,
            args = {"[RollDice]", string.format("Invalid number of dice. Please use a number between %d and %d.", Config.MinDice, Config.MaxDice)}
        })
        return
    end
    
    -- Perform roll
    local results = {}
    for die = 1, dice do
        -- Roll a die with the specified number of sides
        results[die] = math.random(1, sides)
    end
    
    -- Format the results
    local resultString = table.concat(results, ", ")
    TriggerEvent('chat:addMessage', {
        color = Config.SuccessColor,
        multiline = true,
        args = {"[RollDice]", string.format("Rolled %d %d-sided dice: %s", dice, sides, resultString)}
    })
end, false)

-- Add a suggestion for the command
TriggerEvent('chat:addSuggestion', '/rolldice', 'Roll dice with optional number of sides and number of dice.', {
    { name = "sides", help = string.format("Number of sides on each die (default: %d)", Config.DefaultSides) },
    { name = "dice", help = string.format("Number of dice to roll (default: %d)", Config.DefaultDice) }
})