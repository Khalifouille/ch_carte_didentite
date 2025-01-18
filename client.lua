ESX = exports['es_extended']:getSharedObject()

local fakeIDMarkerPosition = vector3(-15.019775, -1310.373657, 29.263062)

CreateThread(function()
    while true do
        Wait(0)

        DrawMarker(23, fakeIDMarkerPosition.x, fakeIDMarkerPosition.y, fakeIDMarkerPosition.z - 1.0,0.0, 0.0, 0.0,0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 100,false,true,2, nil, nil, false)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - fakeIDMarkerPosition)

        if distance < 1.0 then
            ESX.ShowHelpNotification("Hmmm, je pourrais peut-être créer une fausse carte d'identité ici...")
        end
    end
end)