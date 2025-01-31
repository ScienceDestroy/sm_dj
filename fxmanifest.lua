fx_version 'cerulean'
game 'gta5'

description 'Music Marker Script for QB-Core'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@xsound/xsound.lua',
    'server/main.lua'
}

dependencies {
    'xsound'
}