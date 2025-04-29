AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print(string.format("[RollDice] Resource %s started successfully.", resourceName))
    end
end)