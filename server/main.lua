local QBCore = exports['qb-core']:GetCoreObject()
local xSound = exports.xsound

local activeSounds = {}

RegisterNetEvent('music-marker:playMusic')
AddEventHandler('music-marker:playMusic', function(url, markerId, range, volume)
    local src = source
    if activeSounds[markerId] then
        exports.xsound:Destroy(-1, markerId)
    end

    local markerData = Config.Markers[markerId]
    if markerData then
        local pos = markerData.coords
        exports.xsound:PlayUrlPos(-1, markerId, url, volume, vector3(pos.x, pos.y, pos.z), range)
        exports.xsound:Distance(-1, markerId, range)
        activeSounds[markerId] = true

        -- Notify player
        TriggerClientEvent('QBCore:Notify', src, 'Music started playing', 'success')
    end
end)

RegisterNetEvent('music-marker:setVolume')
AddEventHandler('music-marker:setVolume', function(markerId, volume)
    local src = source
    if activeSounds[markerId] then
        exports.xsound:setVolume(-1, markerId, volume)
        TriggerClientEvent('QBCore:Notify', src, 'Volume updated', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'No active music at this marker', 'error')
    end
end)

RegisterNetEvent('music-marker:stopMusic')
AddEventHandler('music-marker:stopMusic', function(markerId)
    if activeSounds[markerId] then
        exports.xsound:Destroy(-1, markerId)
        activeSounds[markerId] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for markerId, _ in pairs(activeSounds) do
        exports.xsound:Destroy(-1, markerId)
    end
end)