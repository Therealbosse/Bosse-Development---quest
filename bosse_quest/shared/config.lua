Config = {}

-- Vart ska man börja jobbet
Config.JobStart = {
    coords = vector3(65.9615, -1008.7871, 29.3574),
    blip = {
        sprite = 280,
        color = 2,
        scale = 0.8,
        text = "Betils Paketleverans"
    }
}

-- Vart ska bilen spawna
Config.VehicleSpawn = {
    coords = vector3(63.6881, -996.8576, 29.2831),
    heading = 250.5775
}

-- Bil modell
Config.VehicleModel = 'benson'

-- Leverans coords, lägg till mer om man vill
Config.LevereraPlats = {
    {coords = vector3(115.3, -1462.6, 29.2)}, 
    {coords = vector3(-303.4, -2693.5, 6.0)}, 
    {coords = vector3(1212.7, -1252.1, 35.2)}, 
    {coords = vector3(-136.3, 6470.4, 31.4)}
}

-- Rewards
Config.Reward = {
    min = 1250,
    max = 1500 
}

-- Jobb cooldown
Config.Cooldown = 10 -- minuter
