fx_version 'cerulean'
game 'gta5'

author 'Urek'
description '[QB-Core] uStaffPlayerInspector - a staff tool for viewing player information, that is hidden inside the DB and not normally accessible. View character info, job, inventory, and more. Supports both online and offline players.'
version '1.0.0'



lua54 'yes'


shared_script '@ox_lib/init.lua'

shared_scripts {
    'shared/*.lua'
}


client_scripts {
    'client/*.lua'
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',   
    'server/*.lua'
}

dependencies {
    'qb-core',
    'ox_lib'
}

escrow_ignore {
    'shared/*.lua'
}
