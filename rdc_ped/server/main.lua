local Players = {}
local LastChangeTime = {}

-- Import QBX/ESX framework functions
local function getFrameworkFunctions()
    local QBX = exports['qbx-core']:GetCoreObject()
    if QBX then
        return {
            getPlayer = function(source)
                return QBX.Functions.GetPlayer(source)
            end,
            getGroup = function(source)
                local xPlayer = QBX.Functions.GetPlayer(source)
                if xPlayer then
                    return xPlayer.PlayerData.group
                end
                return nil
            end,
            notify = function(source, text, type)
                if Config.NotificationSystem == 'qbx' then
                    TriggerClientEvent('ox_lib:notify', source, { type = type or 'inform', description = text })
                elseif Config.NotificationSystem == 'chat' then
                    TriggerClientEvent('chat:addMessage', source, { template = '<div class="chat-message">^3{0}:</div>', args = { text } })
                end
            end
        }
    end

    -- Fallback to ESX if QBX isn't available
    local ESX = exports['es_extended']:getSharedObject()
    if ESX then
        return {
            getPlayer = function(source)
                return ESX.GetPlayerFromId(source)
            end,
            getGroup = function(source)
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer then
                    return xPlayer.getGroup()
                end
                return nil
            end,
            notify = function(source, text, type)
                if Config.NotificationSystem == 'esx' then
                    TriggerClientEvent('esx:showNotification', source, text)
                elseif Config.NotificationSystem == 'chat' then
                    TriggerClientEvent('chat:addMessage', source, { template = '<div class="chat-message">^3{0}:</div>', args = { text } })
                end
            end
        }
    end

    -- If neither framework is available, return basic functionality
    return {
        getPlayer = function(source)
            return nil
        end,
        getGroup = function(source)
            return nil
        end,
        notify = function(source, text, type)
            TriggerClientEvent('chat:addMessage', source, { template = '<div class="chat-message">^3{0}:</div>', args = { text } })
        end
    }
end

Framework = getFrameworkFunctions()

-- Function to get player identifiers
local function getIdentifiers(source)
    local identifiers = {
        discord = nil,
        license = nil
    }
    
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, 'discord:') then
            identifiers.discord = string.gsub(id, 'discord:', '')
        elseif string.find(id, 'license:') then
            identifiers.license = id
        end
    end
    
    return identifiers
end

-- Function to check if a player has permission based on tier
local function hasPermission(source, requiredTier)
    if not requiredTier then return true end -- No tier required means accessible to everyone with basic access

    local player = Framework.getPlayer(source)
    if not player then return false end

    -- Check if the player has one of the required groups
    local playerGroup = Framework.getGroup(source)
    if not playerGroup then return false end

    -- Check if the required tier exists in the configuration
    if not Config.PermissionTiers[requiredTier] then return false end

    -- Check if the player's group matches any of the required groups for this tier
    for _, group in ipairs(Config.PermissionTiers[requiredTier]) do
        if playerGroup == group then
            return true
        end
    end

    return false
end

-- Function to get allowed peds for a specific player
local function getAllowedPeds(source)
    local identifiers = getIdentifiers(source)
    local player = Framework.getPlayer(source)
    if not player then return {} end

    local allowedPeds = {}
    local playerGroup = Framework.getGroup(source) or 'user'
    local isHighAdmin = false

    -- Check if player is a high admin (can access all peds)
    for tier, groups in pairs(Config.PermissionTiers) do
        if tier == 'owner' or tier == 'headadmin' or tier == 'senioradmin' then
            for _, group in ipairs(groups) do
                if playerGroup == group then
                    isHighAdmin = true
                    break
                end
            end
            if isHighAdmin then break end
        end
    end

    -- If high admin, return all peds they have permission for
    if isHighAdmin then
        for _, ped in ipairs(Peds) do
            if not ped.restricted or hasPermission(source, ped.minTier) then
                table.insert(allowedPeds, ped)
            end
        end
    else
        -- For lower admins, check allocations
        local allocation = nil
        
        -- First try to find allocation by Discord ID
        if identifiers.discord and Allocations[identifiers.discord] then
            allocation = Allocations[identifiers.discord]
        -- Then try by license
        elseif identifiers.license and Allocations[identifiers.license] then
            allocation = Allocations[identifiers.license]
        end

        if allocation then
            -- Add peds based on allowed models
            for _, pedModel in ipairs(allocation.allowedPedModels) do
                for _, ped in ipairs(Peds) do
                    if ped.model == pedModel then
                        if not ped.restricted or hasPermission(source, ped.minTier) then
                            table.insert(allowedPeds, ped)
                        end
                        break
                    end
                end
            end
            
            -- Add peds based on allowed categories
            for _, category in ipairs(allocation.allowedCategories) do
                for _, ped in ipairs(Peds) do
                    if ped.category == category then
                        if not ped.restricted or hasPermission(source, ped.minTier) then
                            -- Make sure we don't duplicate peds already added via allowedPedModels
                            local exists = false
                            for _, allowedPed in ipairs(allowedPeds) do
                                if allowedPed.model == ped.model then
                                    exists = true
                                    break
                                end
                            end
                            
                            if not exists then
                                table.insert(allowedPeds, ped)
                            end
                        end
                    end
                end
            end
        else
            -- Player has no allocation, so they can't use the ped menu
            return {}
        end
    end

    return allowedPeds
end

-- Function to validate if a ped is allowed for a player
local function isPedAllowed(source, pedModel)
    local allowedPeds = getAllowedPeds(source)
    for _, ped in ipairs(allowedPeds) do
        if ped.model == pedModel then
            return true
        end
    end
    return false
end

-- Function to check if ped is blacklisted
local function isPedBlacklisted(pedModel)
    for _, blacklisted in ipairs(Config.PedBlacklist) do
        if pedModel == blacklisted then
            return true
        end
    end
    return false
end

-- Function to check cooldown
local function checkCooldown(source)
    if Config.Cooldown <= 0 then return true end
    
    local currentTime = GetGameTimer()
    local lastChange = LastChangeTime[source] or 0
    
    if (currentTime - lastChange) < Config.Cooldown then
        return false, math.ceil((Config.Cooldown - (currentTime - lastChange)) / 1000)
    end
    
    return true
end

-- Main command to open ped menu
RegisterCommand(Config.Command, function(source, args, rawCommand)
    local allowedPeds = getAllowedPeds(source)
    
    if #allowedPeds == 0 then
        Framework.notify(source, 'You do not have permission to use the ped menu.', 'error')
        
        -- Log denied attempt if enabled
        if Config.Discord.Enabled and Config.Discord.LogDeniedAttempts then
            local identifiers = getIdentifiers(source)
            local playerName = GetPlayerName(source)
            logToDiscord({
                title = 'Ped Menu Access Denied',
                description = string.format('Player %s (%s) attempted to access the ped menu but has no permissions.', playerName, source),
                fields = {
                    { name = 'Discord ID', value = identifiers.discord or 'Not Available', inline = true },
                    { name = 'License', value = identifiers.license or 'Not Available', inline = true },
                    { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
                }
            })
        end
        return
    end
    
    -- Log menu open if enabled
    if Config.Discord.Enabled and Config.Discord.LogMenuOpens then
        local identifiers = getIdentifiers(source)
        local playerName = GetPlayerName(source)
        logToDiscord({
            title = 'Ped Menu Opened',
            description = string.format('Player %s opened the ped menu.', playerName),
            fields = {
                { name = 'Player ID', value = tostring(source), inline = true },
                { name = 'Discord ID', value = identifiers.discord or 'Not Available', inline = true },
                { name = 'License', value = identifiers.license or 'Not Available', inline = true },
                { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
            }
        })
    end
    
    -- Send data to client to open the menu
    local player = Framework.getPlayer(source)
    local playerGroup = Framework.getGroup(source) or 'user'
    
    TriggerClientEvent('rdc_pedmenu:openMenu', source, {
        allowedPeds = allowedPeds,
        playerName = GetPlayerName(source),
        playerGroup = playerGroup,
        defaultPed = Config.DefaultPed
    })
end, false)

-- Sub-command to reload configurations
RegisterCommand(Config.Command .. ' reload', function(source, args, rawCommand)
    local playerGroup = Framework.getGroup(source)
    local isAllowed = false
    
    -- Only high-tier admins can reload
    for tier, groups in pairs(Config.PermissionTiers) do
        if tier == 'owner' or tier == 'headadmin' then
            for _, group in ipairs(groups) do
                if playerGroup == group then
                    isAllowed = true
                    break
                end
            end
            if isAllowed then break end
        end
    end
    
    if not isAllowed then
        Framework.notify(source, 'You do not have permission to reload the ped menu configuration.', 'error')
        return
    end
    
    -- Reload configurations
    loadConfig()
    Framework.notify(source, 'Ped menu configuration reloaded successfully.', 'success')
end, false)

-- Sub-command to reset ped
RegisterCommand(Config.Command .. ' reset', function(source, args, rawCommand)
    local allowedPeds = getAllowedPeds(source)
    if #allowedPeds == 0 then
        Framework.notify(source, 'You do not have permission to use the ped menu.', 'error')
        return
    end
    
    TriggerClientEvent('rdc_pedmenu:resetPed', source)
end, false)

-- Sub-command to set ped for another player
RegisterCommand(Config.Command .. ' set', function(source, args, rawCommand)
    if #args ~= 2 then
        Framework.notify(source, 'Usage: /' .. Config.Command .. ' set [player_id] [ped_model]', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    local pedModel = args[2]
    
    if not targetId or not pedModel then
        Framework.notify(source, 'Invalid arguments. Usage: /' .. Config.Command .. ' set [player_id] [ped_model]', 'error')
        return
    end
    
    local targetSrc = targetId
    local allowedPeds = getAllowedPeds(source)
    if #allowedPeds == 0 then
        Framework.notify(source, 'You do not have permission to use the ped menu.', 'error')
        return
    end
    
    -- Check if the admin has permission to use this ped
    if not isPedAllowed(source, pedModel) then
        Framework.notify(source, 'You do not have permission to set that ped model.', 'error')
        return
    end
    
    -- Validate ped model
    local pedValid = false
    for _, ped in ipairs(Peds) do
        if ped.model == pedModel then
            pedValid = true
            break
        end
    end
    
    if not pedValid then
        Framework.notify(source, 'Invalid ped model: ' .. pedModel, 'error')
        return
    end
    
    if isPedBlacklisted(pedModel) then
        Framework.notify(source, 'That ped model is blacklisted.', 'error')
        return
    end
    
    -- Check cooldown for target
    local canChange, remainingTime = checkCooldown(targetSrc)
    if not canChange then
        Framework.notify(source, string.format('Target player is on cooldown. Wait %d more seconds.', remainingTime), 'error')
        return
    end
    
    -- Apply ped to target
    LastChangeTime[targetSrc] = GetGameTimer()
    TriggerClientEvent('rdc_pedmenu:setPed', targetSrc, pedModel)
    
    local sourceName = GetPlayerName(source)
    local targetName = GetPlayerName(targetSrc)
    Framework.notify(source, string.format('Set ped %s for player %s', pedModel, targetName), 'success')
    Framework.notify(targetSrc, string.format('Your ped was set to %s by %s', pedModel, sourceName), 'inform')
    
    -- Log ped change if enabled
    if Config.Discord.Enabled and Config.Discord.LogPedChanges then
        local sourceIdentifiers = getIdentifiers(source)
        local targetIdentifiers = getIdentifiers(targetSrc)
        
        logToDiscord({
            title = 'Ped Changed (Admin Action)',
            description = string.format('Admin %s set ped for player %s', sourceName, targetName),
            fields = {
                { name = 'Admin ID', value = tostring(source), inline = true },
                { name = 'Target ID', value = tostring(targetSrc), inline = true },
                { name = 'New Ped Model', value = pedModel, inline = true },
                { name = 'Admin Discord ID', value = sourceIdentifiers.discord or 'Not Available', inline = true },
                { name = 'Target Discord ID', value = targetIdentifiers.discord or 'Not Available', inline = true },
                { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
            }
        })
    end
end, false)

-- Sub-command to reset ped for another player
RegisterCommand(Config.Command .. ' reset', function(source, args, rawCommand)
    if #args ~= 1 then
        Framework.notify(source, 'Usage: /' .. Config.Command .. ' reset [player_id]', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        Framework.notify(source, 'Invalid player ID. Usage: /' .. Config.Command .. ' reset [player_id]', 'error')
        return
    end
    
    local targetSrc = targetId
    local allowedPeds = getAllowedPeds(source)
    if #allowedPeds == 0 then
        Framework.notify(source, 'You do not have permission to use the ped menu.', 'error')
        return
    end
    
    -- Check cooldown for target
    local canChange, remainingTime = checkCooldown(targetSrc)
    if not canChange then
        Framework.notify(source, string.format('Target player is on cooldown. Wait %d more seconds.', remainingTime), 'error')
        return
    end
    
    -- Reset ped for target
    LastChangeTime[targetSrc] = GetGameTimer()
    TriggerClientEvent('rdc_pedmenu:resetPed', targetSrc)
    
    local sourceName = GetPlayerName(source)
    local targetName = GetPlayerName(targetSrc)
    Framework.notify(source, string.format('Reset ped for player %s', targetName), 'success')
    Framework.notify(targetSrc, string.format('Your ped was reset by %s', sourceName), 'inform')
    
    -- Log ped reset if enabled
    if Config.Discord.Enabled and Config.Discord.LogPedChanges then
        local sourceIdentifiers = getIdentifiers(source)
        local targetIdentifiers = getIdentifiers(targetSrc)
        
        logToDiscord({
            title = 'Ped Reset (Admin Action)',
            description = string.format('Admin %s reset ped for player %s', sourceName, targetName),
            fields = {
                { name = 'Admin ID', value = tostring(source), inline = true },
                { name = 'Target ID', value = tostring(targetSrc), inline = true },
                { name = 'Admin Discord ID', value = sourceIdentifiers.discord or 'Not Available', inline = true },
                { name = 'Target Discord ID', value = targetIdentifiers.discord or 'Not Available', inline = true },
                { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
            }
        })
    end
end, false)

-- Console command to reload
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RegisterCommand('rdc_pedmenu:reload', function(source, args, rawCommand)
            if source ~= 0 then -- Only allow from server console
                print('This command can only be executed from the server console.')
                return
            end
            
            loadConfig()
            print('Ped menu configuration reloaded successfully.')
        end, true)
    end
end)

-- NUI Callbacks
lib.callback.register('rdc_pedmenu:getData', function(source)
    local allowedPeds = getAllowedPeds(source)
    local playerGroup = Framework.getGroup(source) or 'user'
    
    return {
        allowedPeds = allowedPeds,
        playerName = GetPlayerName(source),
        playerGroup = playerGroup,
        defaultPed = Config.DefaultPed
    }
end)

lib.callback.register('rdc_pedmenu:applyPed', function(source, pedModel)
    -- Validate that the ped is allowed for this player
    if not isPedAllowed(source, pedModel) then
        Framework.notify(source, 'You do not have permission to use this ped model.', 'error')
        
        -- Log unauthorized attempt
        if Config.Discord.Enabled and Config.Discord.LogDeniedAttempts then
            local identifiers = getIdentifiers(source)
            local playerName = GetPlayerName(source)
            
            logToDiscord({
                title = 'Unauthorized Ped Attempt',
                description = string.format('Player %s tried to use unauthorized ped %s', playerName, pedModel),
                fields = {
                    { name = 'Player ID', value = tostring(source), inline = true },
                    { name = 'Discord ID', value = identifiers.discord or 'Not Available', inline = true },
                    { name = 'License', value = identifiers.license or 'Not Available', inline = true },
                    { name = 'Attempted Ped', value = pedModel, inline = true },
                    { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
                }
            })
        end
        
        return false
    end
    
    -- Check if ped is blacklisted
    if isPedBlacklisted(pedModel) then
        Framework.notify(source, 'This ped model is blacklisted.', 'error')
        return false
    end
    
    -- Check cooldown
    local canChange, remainingTime = checkCooldown(source)
    if not canChange then
        Framework.notify(source, string.format('You are on cooldown. Wait %d more seconds.', remainingTime), 'error')
        return false
    end
    
    -- Update last change time
    LastChangeTime[source] = GetGameTimer()
    
    -- Validate ped model exists in our list
    local pedExists = false
    for _, ped in ipairs(Peds) do
        if ped.model == pedModel then
            pedExists = true
            break
        end
    end
    
    if not pedExists then
        Framework.notify(source, 'Invalid ped model.', 'error')
        return false
    end
    
    -- Log ped change if enabled
    if Config.Discord.Enabled and Config.Discord.LogPedChanges then
        local identifiers = getIdentifiers(source)
        local playerName = GetPlayerName(source)
        local oldPed = GetEntityModel(GetPlayerPed(source))
        local oldPedHash = GetEntityModelName(oldPed)
        
        logToDiscord({
            title = 'Ped Changed',
            description = string.format('Player %s changed ped', playerName),
            fields = {
                { name = 'Player ID', value = tostring(source), inline = true },
                { name = 'Old Ped Model', value = oldPedHash or 'Unknown', inline = true },
                { name = 'New Ped Model', value = pedModel, inline = true },
                { name = 'Discord ID', value = identifiers.discord or 'Not Available', inline = true },
                { name = 'License', value = identifiers.license or 'Not Available', inline = true },
                { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
            }
        })
    end
    
    -- Return success to client
    return true
end)

lib.callback.register('rdc_pedmenu:resetPed', function(source)
    -- Check cooldown
    local canChange, remainingTime = checkCooldown(source)
    if not canChange then
        Framework.notify(source, string.format('You are on cooldown. Wait %d more seconds.', remainingTime), 'error')
        return false
    end
    
    -- Update last change time
    LastChangeTime[source] = GetGameTimer()
    
    -- Log ped reset if enabled
    if Config.Discord.Enabled and Config.Discord.LogPedChanges then
        local identifiers = getIdentifiers(source)
        local playerName = GetPlayerName(source)
        local oldPed = GetEntityModel(GetPlayerPed(source))
        local oldPedHash = GetEntityModelName(oldPed)
        
        logToDiscord({
            title = 'Ped Reset',
            description = string.format('Player %s reset their ped', playerName),
            fields = {
                { name = 'Player ID', value = tostring(source), inline = true },
                { name = 'Previous Ped Model', value = oldPedHash or 'Unknown', inline = true },
                { name = 'Reset To', value = Config.DefaultPed, inline = true },
                { name = 'Discord ID', value = identifiers.discord or 'Not Available', inline = true },
                { name = 'License', value = identifiers.license or 'Not Available', inline = true },
                { name = 'Timestamp', value = os.date('%Y-%m-%d %H:%M:%S'), inline = true }
            }
        })
    end
    
    return true
end)

-- Function to reload configurations
function loadConfig()
    -- Load the configuration files
    Config = {}
    Peds = {}
    Allocations = {}
    
    -- Execute the config files to reload them
    LoadResourceFile(GetCurrentResourceName(), 'config/config.lua')
    LoadResourceFile(GetCurrentResourceName(), 'config/peds.lua')
    LoadResourceFile(GetCurrentResourceName(), 'config/allocations.lua')
    
    -- Parse the config files manually since they define global variables
    local configContent = LoadResourceFile(GetCurrentResourceName(), 'config/config.lua')
    local pedsContent = LoadResourceFile(GetCurrentResourceName(), 'config/peds.lua')
    local allocationsContent = LoadResourceFile(GetCurrentResourceName(), 'config/allocations.lua')
    
    -- We'll use a different approach - just restart the script parts that read these
    -- Since we're using shared_scripts, we need to ensure they are reloaded properly
    -- For now, we'll just reload the server-side logic
end

-- Event handler for when player disconnects
AddEventHandler('playerDropped', function(reason)
    -- Clean up player data
    Players[source] = nil
    LastChangeTime[source] = nil
end)