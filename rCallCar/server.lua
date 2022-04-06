ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('rCallcar:listdesvoiture', function(source, cb)
	local ownedCars = {}
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
		MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND `stored` = @stored', {
			['@owner'] = xPlayer.identifier,
			['@Type'] = 'car',
			['@stored'] = true
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedCars)
		end)
end)

RegisterServerEvent('rCallcar:etatvehiculesortie')
AddEventHandler('rCallcar:etatvehiculesortie', function(plate, state, lavoitre)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = @stored WHERE plate = @plate AND owner = @owner', {
		['@owner'] = xPlayer.identifier,
		['@stored'] = state,
		['@plate'] = plate
	}, function(rowsChanged)
		xPlayer.removeMoney(Config.prixCommande)
	    TriggerClientEvent('esx:showAdvancedNotification', _src, 'Information', '~g~Garagiste', 'Votre vehicule '..lavoitre.." a bien été livrée ~r~-"..Config.prixCommande.."$", 'CHAR_CARSITE', 8)
	end)
end)