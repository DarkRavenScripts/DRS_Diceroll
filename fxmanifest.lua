fx_version 'cerulean'
game 'gta5'

author 'Xavlios'
description 'FiveM QBox dice roll script with server-side rolling and ox_lib integration.'
version '2.0.1'

lua54 'yes'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/*.lua'
}

escrow_ignore {
    'config.lua'
}