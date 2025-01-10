ESX = nil
local isOnJob = false
local deliveryVehicle = nil
local holdingPackage = false
local currentDelivery = nil
local currentDeliveryBlip = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    local blip = AddBlipForCoord(Config.JobStart.coords)
    SetBlipSprite(blip, Config.JobStart.blip.sprite)
    SetBlipColour(blip, Config.JobStart.blip.color)
    SetBlipScale(blip, Config.JobStart.blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.JobStart.blip.text)
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.JobStart.coords)

        if distance < 10.0 then
            sleep = 0
            DrawMarker(1, Config.JobStart.coords.x, Config.JobStart.coords.y, Config.JobStart.coords.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
            if distance < 2.0 then
                ESX.ShowHelpNotification("Tryck ~INPUT_CONTEXT~ för att börja leverera paket hos Bertil")
                if IsControlJustReleased(0, 38) then
                    StartDeliveryJob()
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function StartDeliveryJob()
    if isOnJob then
    end

    local model = GetHashKey(Config.VehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    deliveryVehicle = CreateVehicle(model, Config.VehicleSpawn.coords.x, Config.VehicleSpawn.coords.y, Config.VehicleSpawn.coords.z, Config.VehicleSpawn.heading, true, false)
    SetVehicleNumberPlateText(deliveryVehicle, "BERTIL")
    SetEntityAsMissionEntity(deliveryVehicle, true, true)

    ESX.ShowNotification("Ta ditt fordon och kör till platsen!")
    isOnJob = true
    GenerateDeliveryPoint()
end

function GenerateDeliveryPoint()
    local randomPoint = Config.LevereraPlats[math.random(#Config.LevereraPlats)]
    currentDelivery = randomPoint.coords

    ESX.ShowNotification("Kör till markerad plats och ta paketet ur bilen!")
    CreateDeliveryBlip(currentDelivery)
end

function CreateDeliveryBlip(coords)
    if currentDeliveryBlip then
        RemoveBlip(currentDeliveryBlip)
    end

    currentDeliveryBlip = AddBlipForCoord(coords)
    SetBlipSprite(currentDeliveryBlip, 1)
    SetBlipColour(currentDeliveryBlip, 5)
    SetBlipScale(currentDeliveryBlip, 0.8)
    SetBlipRoute(currentDeliveryBlip, true)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        if isOnJob and currentDelivery then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local vehicleCoords = GetEntityCoords(deliveryVehicle)
            local distanceToVehicle = #(playerCoords - vehicleCoords)
            local distanceToDelivery = #(playerCoords - currentDelivery)

            if distanceToVehicle < 3.0 and IsBehindVehicle(playerCoords, vehicleCoords) and not holdingPackage then
                sleep = 0
                DrawMarker(1, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
                ESX.ShowHelpNotification("Tryck ~INPUT_CONTEXT~ för att ta ett paket.")
                if IsControlJustReleased(0, 38) then
                    PickUpPackage()
                end
            end

            if distanceToDelivery < 10.0 and holdingPackage then
                sleep = 0
                DrawMarker(1, currentDelivery.x, currentDelivery.y, currentDelivery.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, false, 2, false, nil, nil, false)
                if distanceToDelivery < 2.0 then
                    ESX.ShowHelpNotification("Tryck ~INPUT_CONTEXT~ för att leverera paketet.")
                    if IsControlJustReleased(0, 38) then
                        DeliverPackage()
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

function IsBehindVehicle(playerCoords, vehicleCoords)
    local vehicleForward = GetEntityForwardVector(deliveryVehicle)
    local toPlayer = playerCoords - vehicleCoords
    local dotProduct = Dot(vehicleForward, toPlayer)
    return dotProduct < 0
end

function PickUpPackage()
    holdingPackage = true
    LoadProp('prop_cs_cardbox_01')
    ESX.ShowNotification("Ta paketet till markeringen")
end

function DeliverPackage()
    holdingPackage = false
    RemoveProp()
    ESX.ShowNotification("Paketet har lastas av!")
    TriggerServerEvent('bosse:betala')
    GenerateDeliveryPoint()
end

function LoadProp(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local prop = CreateObject(hash, playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.3, 0.0, 0.0, 0.0, 0.0, 270.0, true, true, false, true, 1, true)
    return prop
end

function RemoveProp()
    ClearPedTasks(PlayerPedId())
    local prop = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.0, GetHashKey('prop_cs_cardbox_01'), false, false, false)
    if DoesEntityExist(prop) then
        DeleteEntity(prop)
    end
end

function Dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end
