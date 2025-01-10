ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('bosse:betala')
AddEventHandler('bosse:betala', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local reward = math.random(Config.Reward.min, Config.Reward.max)
        xPlayer.addMoney(reward)
        TriggerClientEvent('esx:showNotification', source, "Du fick " .. reward .. " för leveransen!")
    end
end)
