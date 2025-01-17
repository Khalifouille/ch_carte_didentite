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

RegisterCommand('verifiercarte', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    if #args < 1 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /verifiercarte [ID joueur]')
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or targetId <= 0 then
        TriggerClientEvent('esx:showNotification', source, 'Veuillez entrer un ID valide.')
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', source, 'Le joueur avec cet ID n\'existe pas ou n\'est pas en ligne.')
        return
    end

    local query = "SELECT firstname, lastname, dob, nationality FROM user_identity WHERE identifier = ?"
    exports.oxmysql:execute(query, { targetPlayer.identifier }, function(result)
        if result and #result > 0 then
            local identity = result[1]
            local message = string.format(
                "Carte d'identité de %s %s\nDate de naissance : %s\nNationalité : %s",
                identity.firstname, identity.lastname, identity.dob, identity.nationality
            )
            TriggerClientEvent('esx:showNotification', source, message)
        else
            TriggerClientEvent('esx:showNotification', source, 'Ce joueur n\'a pas de carte d\'identité enregistrée.')
        end
    end)
end, false)

RegisterCommand('modifinfos', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    if #args < 4 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /modifinfos [Nom] [Prénom] [Âge] [Nationalité]')
        return
    end

    local lastname = args[1]
    local firstname = args[2]
    local age = tonumber(args[3])
    local nationality = args[4]

    if not age or age <= 0 then
        TriggerClientEvent('esx:showNotification', source, 'Veuillez entrer un âge valide.')
        return
    end

    local dob = os.date('%Y-%m-%d', os.time() - (age * 365 * 24 * 60 * 60))

    local query = "UPDATE user_identity SET firstname = ?, lastname = ?, dob = ?, nationality = ? WHERE identifier = ?"
    exports.oxmysql:execute(query, {
        firstname,
        lastname,
        dob,
        nationality,
        xPlayer.identifier
    }, function(rowsChanged)
        if type(rowsChanged) == "table" and rowsChanged.affectedRows and rowsChanged.affectedRows > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Vos informations ont été mises à jour avec succès.')
        elseif type(rowsChanged) == "number" and rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Vos informations ont été mises à jour avec succès.')
        else
            TriggerClientEvent('esx:showNotification', source, 'Erreur : Impossible de mettre à jour vos informations.')
        end
    end)
end, false)

RegisterCommand('fakeID', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    if #args < 4 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /fakeID [Nom] [Prénom] [Âge] [Nationalité]')
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
    local query = "INSERT INTO user_identity (identifier, firstname, lastname, dob, nationality, photo, fake_id) VALUES (?, ?, ?, ?, ?, NULL, TRUE)"

    exports.oxmysql:execute(query, {
        xPlayer.identifier,
        firstname,
        lastname,
        dob,
        nationality
    }, function(rowsChanged)
        if type(rowsChanged) == "table" then
            if rowsChanged.affectedRows and rowsChanged.affectedRows > 0 then
                TriggerClientEvent('esx:showNotification', source, 'Votre fausse carte d\'identité a été créée avec succès !')
            else
                TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la fausse carte d\'identité.')
            end
        elseif type(rowsChanged) == "number" and rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Votre fausse carte d\'identité a été créée avec succès !')
        else
            TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la fausse carte d\'identité.')
        end
    end)
end, false)

