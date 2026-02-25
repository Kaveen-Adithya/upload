fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'

author 'RDC Development Team'
description 'Premium Ped Menu for ESX/QBX Framework'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'config/peds.lua',
    'config/allocations.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    'server/discord.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/app.js'
}

-- Additional exports if needed
exports {
    'openPedMenu'
}