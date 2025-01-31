local QBCore = exports['qb-core']:GetCoreObject()
local isNearMarker = false
local currentMarker = nil

-- Menu configuration
local function OpenMusicMenu(markerId)
    local dialog = exports['qb-input']:ShowInput({
        header = "DJ Меню",
        submitText = "Играть",
        inputs = {
            {
                text = "URL (MP3 или YouTube)",
                name = "musicUrl",
                type = "text",
                isRequired = true
            },
            {
                text = "Дальность (метры)",
                name = "range",
                type = "number",
                isRequired = true
            },
            {
                text = "Громкость (0 - 10)",
                name = "volume",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog then
        if dialog.musicUrl and dialog.range and dialog.volume then
            local range = tonumber(dialog.range)
            local volume = tonumber(dialog.volume) / 10
            if range > 0 then
                if volume >= 0.0 and volume <= 1.0 then
                    TriggerServerEvent('music-marker:playMusic', dialog.musicUrl, markerId, range, volume)
                else
                    QBCore.Functions.Notify('Громкость должна быть от 1 до 10', 'error')
                end
            else
                QBCore.Functions.Notify('Дальность должна быть больше 0', 'error')
            end
        end
    end
end

local function OpenVolumeMenu(markerId)
    local dialog = exports['qb-input']:ShowInput({
        header = "Регулировка Громкости",
        submitText = "Установить громкость",
        inputs = {
            {
                text = "Громкость (0 - 10)",
                name = "volume",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog then
        if dialog.volume then

            local volume = tonumber(dialog.volume) / 10
            print (volume)


            if volume >= 0.0 and volume <= 1.0 then
                TriggerServerEvent('music-marker:setVolume', markerId, volume)
            else
                QBCore.Functions.Notify('Громкость должна быть от 1 до 10', 'error')
            end
        end
    end
end

-- Check distance to markers
CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local isNearAny = false
        
        for markerId, markerData in pairs(Config.Markers) do
            local dist = #(playerCoords - markerData.coords)
            
            -- Draw marker
            DrawMarker(1, markerData.coords.x, markerData.coords.y, markerData.coords.z - 1.0, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                1.0, 1.0, 1.0, 138, 43, 226, 100, 
                false, false, 2, false, nil, nil, false)

            if dist < 1.5 then
                isNearAny = true
                currentMarker = markerId
                -- Show help text
                DrawText3D(markerData.coords.x, markerData.coords.y, markerData.coords.z, 
                    string.format("~g~E~w~ DJ Меню ~n~ ~b~H~w~ громкость ~n~ ~r~G~w~ чтобы остановить ~n~%s ", markerData.label))
                
                -- Open menu on E press
                if IsControlJustReleased(0, 38) then -- E key
                    OpenMusicMenu(markerId)
                end
                
                -- Open volume menu on H press
                if IsControlJustReleased(0, 74) then -- H key
                    OpenVolumeMenu(markerId)
                end
                
                -- Stop music on G press
                if IsControlJustReleased(0, 47) then -- G key
                    TriggerServerEvent('music-marker:stopMusic', markerId)
                    QBCore.Functions.Notify('Музыка остановлена', 'success')
                end
            end
        end
        
        if not isNearAny then
            currentMarker = nil
        end
    end
end)

-- 3D Text function
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for markerId, _ in pairs(Config.Markers) do
        TriggerServerEvent('music-marker:stopMusic', markerId)
    end
end)