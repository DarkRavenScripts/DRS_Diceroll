fx_version 'cerulean'
game 'gta5'

author 'Xavlios'
description 'A simple FiveM script to roll dice with customizable sides and number of dice.'
version '1.0.1'

lua54 'yes'

shared_scripts {
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