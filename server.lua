ESX = exports['es_extended']:getSharedObject()

---------------------------------------------------------------------------------------- UTILITAIRES

local function getIdentity(identifier, fake_id, callback)
    local query = 'SELECT firstname, lastname, dob, nationality, fake_id FROM user_identity WHERE identifier = @identifier'
    if fake_id ~= nil then
        query = query .. ' AND fake_id = @fake_id'
    end
    exports.oxmysql:execute(query, { ['@identifier'] = identifier, ['@fake_id'] = fake_id }, callback)
end

---------------------------------------------------------------------------------------- FAIRE CARTE

RegisterCommand('fairemacarte', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Le joueur n'est pas trouvé.")
        return
    end

    exports.oxmysql:execute('SELECT firstname, lastname FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier }, function(result)
        if result and #result > 0 then
            local firstname = result[1].firstname
            local lastname = result[1].lastname

            getIdentity(xPlayer.identifier, false, function(existingIdentity)
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
                exports.oxmysql:insert('INSERT INTO user_identity (identifier, firstname, lastname, dob, nationality, photo, fake_id) VALUES (?, ?, ?, ?, ?, NULL, FALSE)', {
                    xPlayer.identifier,
                    firstname,
                    lastname,
                    dob,
                    nationality
                }, function(insertId)
                    if insertId then
                        xPlayer.addInventoryItem('carte_identite', 1, {
                            firstname = firstname,
                            lastname = lastname,
                            dob = dob,
                            nationality = nationality
                        })
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
        TriggerClientEvent('esx:showNotification', source, 'Tu n\'es pas policier !')
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

    getIdentity(targetPlayer.identifier, nil, function(result)
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

    exports.oxmysql:execute('SELECT COUNT(*) as count FROM user_identity WHERE identifier = ? AND fake_id = TRUE', {xPlayer.identifier}, function(result)
        if result[1].count > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez déjà une fausse carte d\'identité.')
            return
        end

        local inkCount = xPlayer.getInventoryItem('cartouche_encre').count
        local paperCount = xPlayer.getInventoryItem('papier').count
        local watermarkCount = xPlayer.getInventoryItem('filigranne').count
        local money = xPlayer.getMoney()
    
        if inkCount < 5 then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez besoin de 5 cartouches d\'encre.')
            return
        end
    
        if paperCount < 2 then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez besoin de 2 papiers.')
            return
        end
    
        if watermarkCount < 2 then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez besoin de 2 filigranes.')
            return
        end
    
        if money < 5000 then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez besoin de 5000$.')
            return
        end
    
        xPlayer.removeInventoryItem('cartouche_encre', 5)
        xPlayer.removeInventoryItem('papier', 2)
        xPlayer.removeInventoryItem('filigranne', 2)
        xPlayer.removeMoney(5000)

        local firstname = args[1]
        local lastname = args[2]
        local age = tonumber(args[3])
        local nationality = args[4] or 'Marocaine'

        if not age or age <= 0 then
            TriggerClientEvent('esx:showNotification', source, 'Veuillez entrer un âge valide.')
            return
        end

        local dob = os.date('%Y-%m-%d', os.time() - (age * 365 * 24 * 60 * 60))
        exports.oxmysql:insert('INSERT INTO user_identity (identifier, firstname, lastname, dob, nationality, fake_id) VALUES (?, ?, ?, ?, ?, TRUE)', {
            xPlayer.identifier,
            firstname,
            lastname,
            dob,
            nationality
        }, function(insertId)
            if insertId then
                xPlayer.addInventoryItem('carte_identite_fake', 1, {
                    firstname = firstname,
                    lastname = lastname,
                    dob = dob,
                    nationality = nationality
                })
                TriggerClientEvent('esx:showNotification', source, 'Votre fausse carte d\'identité a été créée avec succès !')
            else
                TriggerClientEvent('esx:showNotification', source, 'Erreur lors de la création de la fausse carte d\'identité.')
            end
        end)
    end)
end, false)

---------------------------------------------------------------------------------------- EXPORTS PORTFEUILLE ET CARTES

exports('portefeuille', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local xPlayer = ESX.GetPlayerFromId(inventory.id)

        if not xPlayer then
            print("Le joueur n'est pas trouvé.")
            return false
        end

        getIdentity(xPlayer.identifier, nil, function(result)
            if result and #result > 0 then
                for _, identity in ipairs(result) do
                    local message = string.format("Nom: %s\nPrénom: %s\nDate de naissance: %s\nNationalité: %s",
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

---------------------------------------------------------------------------------------- EXPORTS CARTES IDENTITES

exports('cartedidentite', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local xPlayer = ESX.GetPlayerFromId(inventory.id)

        if not xPlayer then
            print("Le joueur n'est pas trouvé.")
            return false
        end

        getIdentity(xPlayer.identifier, false, function(result)
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

exports('cartedidentite2', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local xPlayer = ESX.GetPlayerFromId(inventory.id)

        if not xPlayer then
            print("Le joueur n'est pas trouvé.")
            return false
        end

        getIdentity(xPlayer.identifier, true, function(result)
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
