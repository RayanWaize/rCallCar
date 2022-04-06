ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)


rCarCall = {
    listevoiture = {},
}


local UneTableDePed = {}
function CallVoiture(car, plate, nomvoiture, props)
    local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(plyCoords.x + math.random(-100, 100), plyCoords.y + math.random(-100, 100), plyCoords.z, 0, 3, 0)
    local modelcar = GetHashKey(car)
    RequestModel(modelcar)
    while not HasModelLoaded(modelcar) do Wait(10) end
    carcall = CreateVehicle(modelcar, spawnPos, spawnHeading, true, false)
    ESX.Game.SetVehicleProperties(carcall, props)
    SetVehRadioStation(carcall, false)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(modelcar), true)
	SetEntityAsMissionEntity(carcall, true, false)
	SetVehicleHasBeenOwnedByPlayer(carcall, true)
	SetVehicleNeedsToBeHotwired(carcall, false)
    RequestModel(GetHashKey("a_m_y_salton_01"))
    while not HasModelLoaded(GetHashKey("a_m_y_salton_01")) do Wait(1) end
    local pedcall = CreatePedInsideVehicle(carcall, 26, GetHashKey('a_m_y_salton_01'), -1, true, false)
    table.insert(UneTableDePed, pedcall)
    Wait(30)
    TaskVehicleDriveToCoord(pedcall, carcall, plyCoords.x+2, plyCoords.y, plyCoords.z+2, 15.0, 0, GetEntityModel(carcall), 2883621, 10.0)
    mechBlip = AddBlipForEntity(carcall)
    SetBlipSprite(blip, 473)
    SetBlipFlashes(mechBlip, true)
    SetBlipColour(mechBlip, 5)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local plyCoords2 = GetEntityCoords(GetPlayerPed(-1), false)
            local poscar = GetEntityCoords(pedcall, false)
            local dst = #(poscar-plyCoords2)
            if dst <= 1.5 then
                for _, omg in pairs (UneTableDePed) do 
                    DeleteEntity(omg)
                end
                RemoveBlip(mechBlip)
                TriggerServerEvent('rCallcar:etatvehiculesortie', plate, false, nomvoiture)
            end
        end
    end)
end


function MenuCallVoiture()
    local MenuCallcar = RageUI.CreateMenu("Commander vos voitures", "Voici vos véhicules disponible")
      RageUI.Visible(MenuCallcar, not RageUI.Visible(MenuCallcar))
          while MenuCallcar do
              Citizen.Wait(0)
                RageUI.IsVisible(MenuCallcar, true, true, true, function()
                    for i = 1, #rCarCall.listevoiture, 1 do
                    local hashvoiture = rCarCall.listevoiture[i].vehicle.model
                    local modelevoiturespawn = rCarCall.listevoiture[i].vehicle
                    local nomvoituremodele = GetDisplayNameFromVehicleModel(hashvoiture)
                    local nomvoituretexte  = GetLabelText(nomvoituremodele)
                    local plaque = rCarCall.listevoiture[i].plate
                RageUI.ButtonWithStyle("~b~→~s~ "..plaque.." | "..nomvoituretexte, nil, {RightLabel = Config.prixCommande.." $"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                	    CallVoiture(nomvoituremodele, plaque, nomvoituretexte, modelevoiturespawn)
                        RageUI.CloseAll()
                    end
                end)
            end

        end, function()
        end)
        if not RageUI.Visible(MenuCallcar) then
            MenuCallcar = RMenu:DeleteType("MenuCallcar", true)
        end
    end
end

RegisterCommand(Config.commandName, function()
    ESX.TriggerServerCallback('rCallcar:listdesvoiture', function(ownedCars)
        rCarCall.listevoiture = ownedCars
    end)
    MenuCallVoiture()
end, false)