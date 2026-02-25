local currentPed = nil
local isMenuOpen = false

-- Function to handle ped changes
local function changePed(model)
    -- Validate model name
    if not model or model == '' then
        lib.notify({ type = 'error', description = 'Invalid ped model.' })
        return
    end

    -- Request the model
    local modelHash = joaat(model)
    RequestModel(modelHash)

    -- Wait for model to load with timeout
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end

    if not HasModelLoaded(modelHash) then
        lib.notify({ type = 'error', description = 'Failed to load ped model: ' .. model })
        return
    end

    -- Change the ped
    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Update current ped
    currentPed = model
    
    lib.notify({ type = 'success', description = 'Ped changed successfully!' })
end

-- Function to reset to default ped
local function resetToDefaultPed()
    local modelHash = joaat(Config.DefaultPed)
    RequestModel(modelHash)

    -- Wait for model to load with timeout
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end

    if not HasModelLoaded(modelHash) then
        lib.notify({ type = 'error', description = 'Failed to load default ped model.' })
        return
    end

    -- Change the ped
    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Update current ped
    currentPed = Config.DefaultPed
    
    lib.notify({ type = 'inform', description = 'Ped reset to default.' })
end

-- NUI Callbacks
RegisterNUICallback('applyPed', function(data, cb)
    local success = lib.callback.await('rdc_pedmenu:applyPed', false, data.pedModel)
    
    if success then
        changePed(data.pedModel)
    end
    
    cb(success)
end)

RegisterNUICallback('resetPed', function(data, cb)
    local success = lib.callback.await('rdc_pedmenu:resetPed', false)
    
    if success then
        resetToDefaultPed()
    end
    
    cb(success)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb({})
end)

-- Event to open the ped menu
RegisterNetEvent('rdc_pedmenu:openMenu')
AddEventHandler('rdc_pedmenu:openMenu', function(data)
    if isMenuOpen then
        SetNuiFocus(false, false)
        isMenuOpen = false
        return
    end

    SetNuiFocus(true, true)
    isMenuOpen = true
    
    SendNUIMessage({
        action = 'openMenu',
        data = data
    })
end)

-- Event to set a specific ped (for admin commands)
RegisterNetEvent('rdc_pedmenu:setPed')
AddEventHandler('rdc_pedmenu:setPed', function(pedModel)
    changePed(pedModel)
end)

-- Event to reset ped (for admin commands)
RegisterNetEvent('rdc_pedmenu:resetPed')
AddEventHandler('rdc_pedmenu:resetPed', function()
    resetToDefaultPed()
end)

-- Keybind to open menu if enabled
if Config.Keybind.Enabled then
    RegisterKeyMapping(Config.Command, 'Open Ped Menu', 'keyboard', Config.Keybind.Key)

    -- Create thread to handle key press
    CreateThread(function()
        while true do
            Wait(0)
            
            if IsControlJustReleased(0, GetHashKey(Config.Keybind.Key)) and not isMenuOpen then
                -- Try to open the menu by triggering the command
                ExecuteCommand(Config.Command)
            end
        end
    end)
end

-- Export function to open menu programmatically
function openPedMenu()
    if not isMenuOpen then
        ExecuteCommand(Config.Command)
    end
end

-- Close menu when player dies
AddEventHandler('baseevents:onPlayerKilled', function(killerServerId, deathCoords)
    if isMenuOpen then
        SetNuiFocus(false, false)
        isMenuOpen = false
    end
end)

-- Close menu when player is respawned
AddEventHandler('baseevents:onPlayerSpawned', function(spawnCoords)
    if isMenuOpen then
        SetNuiFocus(false, false)
        isMenuOpen = false
    end
end)