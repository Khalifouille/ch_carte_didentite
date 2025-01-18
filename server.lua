ESX = exports['es_extended']:getSharedObject()

---------------------------------------------------------------------------------------- FAIRE CARTE

RegisterCommand('fairemacarte', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    local query = 'SELECT firstname, lastname FROM users WHERE identifier = @identifier'
    exports.oxmysql:execute(query, { ['@identifier'] = xPlayer.identifier }, function(result)
        if result and #result > 0 then
            local firstname = result[1].firstname
            local lastname = result[1].lastname
            local checkQuery = 'SELECT * FROM user_identity WHERE identifier = @identifier AND fake_id = FALSE'
            exports.oxmysql:execute(checkQuery, { ['@identifier'] = xPlayer.identifier }, function(existingIdentity)
                if existingIdentity and #existingIdentity > 0 then
                    TriggerClientEvent('esx:showNotification', source, 'Vous avez déjà une carte d\'identité.')
                    return
                end

                local age = tonumber(args[1])
                local nationality = args[2] or 'Marocaine'

                if not age or age <= 0 then
                    TriggerClientEvent('esx:showNotification', source, 'Veuillez entrer un âge valide.')
                    return
                end

                local dob = os.date('%Y-%m-%d', os.time() - (age * 365 * 24 * 60 * 60))
                local insertQuery = "INSERT INTO user_identity (identifier, firstname, lastname, dob, nationality, photo, fake_id) VALUES (?, ?, ?, ?, ?, NULL, FALSE)"

                local insertId = exports.oxmysql:insert(insertQuery, {
                    xPlayer.identifier,
                    firstname,
                    lastname,
                    dob,
                    nationality
                }, function(insertId)
                    if insertId then
                        local item = {
                            name = 'carte_identite',
                            label = 'Carte d\'identité',
                            weight = 0,
                            stack = false,
                            metadata = {
                                firstname = firstname,
                                lastname = lastname,
                                dob = dob,
                                nationality = nationality
                            }
                        }
                        xPlayer.addInventoryItem(item.name, 1, item.metadata)

                        TriggerClientEvent('esx:showNotification', source, 'Votre carte d\'identité a été créée avec succès !')
                    else
                        TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la carte d\'identité.')
                    end
                end)
            end)
        end
    end)
end, false)

---------------------------------------------------------------------------------------- VERIFIER CARTE

RegisterCommand('verifiercarte', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    if xPlayer.job.name ~= 'police' then
        TriggerClientEvent('esx:showNotification', source, 'Tu es pas condé !')
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

    local query = "SELECT firstname, lastname, dob, nationality, fake_id FROM user_identity WHERE identifier = ?"
    exports.oxmysql:execute(query, {targetPlayer.identifier}, function(result)
        if result and #result > 0 then
            local isFake = result[1].fake_id
            local message = string.format(
                "Nom: %s\nPrénom: %s\nDate de naissance: %s\nNationalité: %s",
                result[1].lastname, result[1].firstname, result[1].dob, result[1].nationality
            )

            local random = math.random(100)
            if isFake and random <= 20 then
                TriggerClientEvent('esx:showNotification', source, 'Carte d\'identité fausse !')
            else
                TriggerClientEvent('esx:showNotification', source, message)
            end
        else
            TriggerClientEvent('esx:showNotification', source, 'Le joueur n\'a pas de carte d\'identité.')
        end
    end)
end, false)

---------------------------------------------------------------------------------------- FAKE ID

RegisterCommand('fakeid', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    if #args < 4 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /fakeID [Nom] [Prénom] [Âge] [Nationalité]')
        return
    end

    local query = "SELECT COUNT(*) as count FROM user_identity WHERE identifier = ? AND fake_id = TRUE"
    exports.oxmysql:execute(query, {xPlayer.identifier}, function(result)
        if result[1].count > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez déjà une fausse carte d\'identité.')
            return
        end

        local firstname = args[1]
        local lastname = args[2]
        local age = tonumber(args[3])
        local nationality = args[4] or 'Marocaine'

        if not age or age <= 0 then
            TriggerClientEvent('esx:showNotification', source, 'Veuillez entrer un âge valide.')
            return
        end

        local dob = os.date('%Y-%m-%d', os.time() - (age * 365 * 24 * 60 * 60))
        local insertQuery = "INSERT INTO user_identity (identifier, firstname, lastname, dob, nationality, fake_id) VALUES (?, ?, ?, ?, ?, TRUE)"

        local insertId = exports.oxmysql:insert(insertQuery, {
            xPlayer.identifier,
            firstname,
            lastname,
            dob,
            nationality
        }, function(insertId)
            if insertId then
                local item = {
                    name = 'carte_identite_fake',
                    label = 'Fausse carte d\'identité',
                    weight = 0,
                    stack = false,
                    metadata = {
                        firstname = firstname,
                        lastname = lastname,
                        dob = dob,
                        nationality = nationality
                    }
                }
                xPlayer.addInventoryItem(item.name, 1, item.metadata)

                TriggerClientEvent('esx:showNotification', source, 'Votre fausse carte d\'identité a été créée avec succès !')
            else
                TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la fausse carte d\'identité.')
            end
        end)
    end)
end, false)

---------------------------------------------------------------------------------------- METADATA POUR LE PORTEFEUILLE

exports('portefeuille', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local xPlayer = ESX.GetPlayerFromId(inventory.id)

        if not xPlayer then
            print("Le joueur n'est pas trouvé.")
            return false
        end
        
        local query = "SELECT firstname, lastname, dob, nationality FROM user_identity WHERE identifier = ?"
        exports.oxmysql:execute(query, { xPlayer.identifier }, function(result)
            if result and #result > 0 then
                for _, identity in ipairs(result) do
                    local message = string.format("Nom: %s, Prénom: %s, Date de naissance: %s, Nationalité: %s",
                        identity.lastname, identity.firstname, identity.dob, identity.nationality)
                    TriggerClientEvent('esx:showNotification', xPlayer.source, message)
                end
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous n\'avez pas de cartes d\'identité enregistrées.')
            end
        end)


        return false
    end

    if event == 'usedItem' then
        TriggerClientEvent('esx:showNotification', inventory.id, {description = 'Vous avez utilisé le portefeuille.'})
    end
end)

---------------------------------------------------------------------------------------- METADATA POUR LE VRAI ID

exports('cartedidentite', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local xPlayer = ESX.GetPlayerFromId(inventory.id)

        if not xPlayer then
            print("Le joueur n'est pas trouvé.")
            return false
        end

        local query = 'SELECT firstname, lastname, dob, nationality FROM user_identity WHERE identifier = @identifier AND fake_id = FALSE'
        exports.oxmysql:execute(query, { ['@identifier'] = xPlayer.identifier }, function(result)
            if result and #result > 0 then
                local message = string.format(
                    "Nom: %s\nPrénom: %s\nDate de naissance: %s\nNationalité: %s",
                    result[1].lastname, result[1].firstname, result[1].dob, result[1].nationality
                )
                TriggerClientEvent('esx:showNotification', xPlayer.source, message)
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous n\'avez pas de cartes d\'identité enregistrées.')
            end
        end)
    end

    if event == 'usedItem' then
        local itemLabel = ESX.GetItemLabel(item.name)
        TriggerClientEvent('esx:showNotification', inventory.id, {description = 'Vous avez utilisé ' .. itemLabel .. '.'})
    end

    return false
end)

---------------------------------------------------------------------------------------- METADATA POUR LE FAKE ID

exports('cartedidentite2', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local xPlayer = ESX.GetPlayerFromId(inventory.id)

        if not xPlayer then
            print("Le joueur n'est pas trouvé.")
            return false
        end

        local query = 'SELECT firstname, lastname, dob, nationality, fake_id FROM user_identity WHERE identifier = @identifier AND fake_id = TRUE'
        exports.oxmysql:execute(query, { ['@identifier'] = xPlayer.identifier }, function(result)
            if result and #result > 0 then
                local message = string.format(
                    "Nom: %s\nPrénom: %s\nDate de naissance: %s\nNationalité: %s",
                    result[1].lastname, result[1].firstname, result[1].dob, result[1].nationality
                )
                TriggerClientEvent('esx:showNotification', xPlayer.source, message)
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous n\'avez pas de carte d\'identité fausse.')
            end
        end)
    end

    if event == 'usedItem' then
        local itemLabel = ESX.GetItemLabel(item.name)
        TriggerClientEvent('esx:showNotification', inventory.id, {description = 'Vous avez utilisé ' .. itemLabel .. '.'})
    end

    return false
end)
