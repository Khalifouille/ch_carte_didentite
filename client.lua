ESX = exports['es_extended']:getSharedObject()

local posmarkeur = vector3(-15.019775, -1310.373657, 29.263062)

CreateThread(function()
    while true do
        Wait(0)

        DrawMarker(23, posmarkeur.x, posmarkeur.y, posmarkeur.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 100, false, true, 2, nil, nil, false)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - posmarkeur)

        if distance < 1.0 then
            if ESX.GetPlayerData().job.name == 'police' then
                ESX.ShowHelpNotification("Monsieur l'agent? Je chill juste en bas du bâtiment.")
            else
                ESX.ShowHelpNotification("Hmmm, je pourrais peut-être créer une fausse carte d'identité ici...")
            end
        end
    end
end)

RegisterNetEvent('ch_carte_didentite:showIdentity')
AddEventHandler('ch_carte_didentite:showIdentity', function(info)
    SendNUIMessage({
        type = "showIdentity",
        info = info
    })
end)