RegisterNetEvent('rolldice:broadcast')
AddEventHandler('rolldice:broadcast', function(text)
    if not text or type(text) ~= "string" or text == "" then
        return
    end
    local sourcePlayer = source
    TriggerClientEvent('rolldice:receive', -1, sourcePlayer, text)
end)