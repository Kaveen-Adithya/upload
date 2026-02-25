-- RDC Ped Menu Configuration
Config = {}

-- General Settings
Config.Command = 'ped'                    -- Main command to open the ped menu
Config.Keybind = {                        -- Optional keybind to open the menu (comment out to disable)
    Enabled = true,
    Key = 'F6'
}
Config.NotificationSystem = 'qbx'         -- 'qbx' for QBX notifications, 'esx' for ESX notifications, 'chat' for chat messages
Config.Cooldown = 5000                    -- Cooldown between ped changes in milliseconds (0 to disable)
Config.DefaultPed = 'mp_m_freemode_01'    -- Default ped model to reset to
Config.PedBlacklist = {                   -- List of ped models that are not allowed
    's_m_y_blackops_01',
    's_m_y_swat_01',
    's_m_y_hwaycop_01'
}

-- Permission Settings
Config.PermissionTiers = {
    owner = {'owner'},
    headadmin = {'headadmin'},
    senioradmin = {'senioradmin'},
    admin = {'admin'},
    mod = {'mod'},
    trialmod = {'trialmod'},
    helper = {'helper'}
}

-- UI Settings
Config.Theme = {
    PrimaryColor = '#FF0000',              -- Red accent color
    SecondaryColor = '#000000',            -- Black background
    TextColor = '#FFFFFF',                 -- White text
    AccentColor = '#FF4444'                -- Lighter red accent
}

-- Discord Webhook Settings
Config.Discord = {
    Enabled = true,
    WebhookURL = '',                       -- Set your webhook URL here
    LogPedChanges = true,
    LogMenuOpens = false,
    LogDeniedAttempts = true
}

-- Menu Position (CSS positioning values)
Config.MenuPosition = {
    top = '50%',
    left = '50%',
    transform = 'translate(-50%, -50%)'
}

-- Sound Effects (set to false to disable)
Config.Sound = {
    Enabled = true,
    Volume = 0.5
}