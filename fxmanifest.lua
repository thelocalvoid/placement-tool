fx_version 'cerulean'
game 'gta5'

author 'clook'
version 'v1.3.51'

shared_scripts {
    'config.lua',
}

client_scripts {
    'enums.lua',
    'cmath.lua',
    'main.lua',
    'camera.lua',
    'hud.lua',
    'overlays.lua',
    'entity-preview.lua',
    'entity-management.lua',
    'control-handler.lua',
    'compiler.lua',
    'exporter.lua',
}

server_scripts {
    'commands.lua',
    'ace.lua',
    'files.lua'
}

escrow_ignore { 
    'config.lua',
} 