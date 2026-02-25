# Red Dream City Ped Menu

A premium ped menu resource for FiveM servers using ESX/QBX framework with advanced permission system and Discord integration.

## Features

- **Advanced Permission System**: Different permission tiers with configurable access
- **Unlimited Ped Library**: Define unlimited peds with images, descriptions, and restrictions
- **User Allocations**: Assign specific peds to individual users via Discord ID or license
- **Modern UI**: Sleek red/black themed NUI with search and filtering
- **Discord Logging**: Comprehensive logging of ped changes and attempts
- **Cooldown System**: Configurable cooldown between ped changes
- **Admin Commands**: Extensive command system for managing peds

## Installation

1. Place the `rdc_ped` folder in your resources directory
2. Add `ensure rdc_ped` to your `server.cfg`
3. Install required dependencies (see Dependencies section)

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) (for NUI components and callbacks)
- [qbx-core](https://github.com/Qbox-project/qbx_core) OR [es_extended](https://github.com/esx-framework/esx_core)

## Configuration

### 1. Discord Webhook Setup

Edit `config/config.lua` and set your Discord webhook URL:

```lua
Config.Discord = {
    Enabled = true,
    WebhookURL = 'YOUR_WEBHOOK_URL_HERE',  -- Replace with your actual webhook URL
    LogPedChanges = true,
    LogMenuOpens = false,
    LogDeniedAttempts = true
}
```

### 2. Adding New Peds

Edit `config/peds.lua` to add new ped models:

```lua
{
    label = 'My Custom Ped',           -- Display name
    model = 'a_m_y_beach_01',          -- Model name
    category = 'civilian',             -- Category for filtering
    image = 'https://example.com/image.jpg', -- Optional image URL
    restricted = false,                -- Whether requires special permissions
    minTier = 'mod',                   -- Minimum tier required (if restricted)
    gender = 'male',                   -- Gender tag (optional)
    description = 'A custom ped'       -- Description
}
```

### 3. Allocating Peds to Users

Edit `config/allocations.lua` to assign peds to specific users:

By Discord ID (recommended):
```lua
['YOUR_DISCORD_ID_HERE'] = {
    allowedPedModels = {
        's_m_y_cop_01',
        's_f_y_cop_01'
    },
    allowedCategories = {'police'},
    maxCount = 10,
    note = 'User Name - Role'
}
```

By License ID:
```lua
['license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = {
    allowedPedModels = {
        'a_m_y_beach_01'
    },
    allowedCategories = {'civilian'},
    maxCount = 5,
    note = 'User Name - Role'
}
```

### 4. Permission Tiers

Configure permission tiers in `config/config.lua`:

```lua
Config.PermissionTiers = {
    owner = {'owner'},
    headadmin = {'headadmin'},
    senioradmin = {'senioradmin'},
    admin = {'admin'},
    mod = {'mod'},
    trialmod = {'trialmod'},
    helper = {'helper'}
}
```

## Commands

- `/ped` - Opens the ped selection menu
- `/ped reload` - Reloads configuration (high-tier admins only)
- `/ped reset` - Resets ped to default
- `/ped set [player_id] [ped_model]` - Sets ped for another player (admin command)
- `rdc_pedmenu:reload` - Console command to reload configs

## Enabling Discord Identifiers

For Discord IDs to work properly, ensure your server has the `set steam_webApiKey` in server.cfg with a valid Steam Web API key. This allows FiveM to resolve Discord IDs from player identifiers.

Example in `server.cfg`:
```
set steam_webApiKey "YOUR_STEAM_WEB_API_KEY"
```

## Customization

### Theme Colors
Adjust theme colors in `config/config.lua`:
```lua
Config.Theme = {
    PrimaryColor = '#FF0000',      -- Red accent color
    SecondaryColor = '#000000',    -- Black background
    TextColor = '#FFFFFF',         -- White text
    AccentColor = '#FF4444'        -- Lighter red accent
}
```

### Menu Position
Adjust menu position in `config/config.lua`:
```lua
Config.MenuPosition = {
    top = '50%',
    left = '50%',
    transform = 'translate(-50%, -50%)'
}
```

## Support

For issues or questions, please contact the development team or check the documentation.