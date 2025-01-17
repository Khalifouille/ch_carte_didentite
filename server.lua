ESX = exports['es_extended']:getSharedObject()

RegisterCommand('fairemacarte', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    if #args < 4 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /fairemacarte [Nom] [Prénom] [Âge] [Nationalité]')
        return
    end

    local lastname = args[1]
    local firstname = args[2]
    local age = tonumber(args[3])
    local nationality = args[4] or 'Marocaine'

    if not age or age <= 0 then
        TriggerClientEvent('esx:showNotification', source, 'Veuillez entrer un âge valide.')
        return
    end

    local dob = os.date('%Y-%m-%d', os.time() - (age * 365 * 24 * 60 * 60))
    local query = "INSERT INTO user_identity (identifier, firstname, lastname, dob, nationality, photo, fake_id) VALUES (?, ?, ?, ?, ?, NULL, FALSE)"

    exports.oxmysql:execute(query, {
        xPlayer.identifier,
        firstname,
        lastname,
        dob,
        nationality
    }, function(rowsChanged)
        if type(rowsChanged) == "table" then
            if rowsChanged.affectedRows and rowsChanged.affectedRows > 0 then
                TriggerClientEvent('esx:showNotification', source, 'Votre carte d\'identité a été créée avec succès !')
            else
                TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la carte d\'identité.')
            end
        elseif type(rowsChanged) == "number" and rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Votre carte d\'identité a été créée avec succès !')
        else
            TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la carte d\'identité.')
        end
    end)
end, false) 
