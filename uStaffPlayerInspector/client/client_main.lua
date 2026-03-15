local isAdmin = false

RegisterNetEvent('uStaffPlayerInspector:adminStatus', function(status)
    isAdmin = status
    if isAdmin then
        TriggerEvent('uStaffPlayerInspector:openMenu')
    else
        lib.notify({ title = 'uStaffPlayerInspector', description = 'You are not an admin', type = 'error' })
    end
end)

if Config.OpenMenuKey then
    CreateThread(function()
        while true do
            Wait(0)
            if IsControlJustReleased(0, Config.OpenMenuKey) then
                TriggerServerEvent('uStaffPlayerInspector:checkAdmin')
                Wait(500)
            end
        end
    end)
end

RegisterCommand(Config.OpenMenuCommand or 'ustaffmenu', function()
    TriggerServerEvent('uStaffPlayerInspector:checkAdmin')
end)

RegisterNetEvent('uStaffPlayerInspector:openMenu', function()
    local input = lib.inputDialog('Search Player', {
        {type = 'input', label = 'Search Value', description = 'Enter player ID, or license', required = true}
    })
    if input and input[1] and input[1] ~= '' then
        TriggerServerEvent('uStaffPlayerInspector:requestPlayerData', input[1])
    else
    end
end)

RegisterNetEvent('uStaffPlayerInspector:receivePlayerData', function(license, charinfo, job, inventory, money)
    if not license or not charinfo then 
        return lib.notify({ title = 'Error', description = 'Player data is corrupt or missing.', type = 'error' })
    end

    local moneyData = json.decode(money)
    local charData  = json.decode(charinfo)
    local jobData   = json.decode(job)
    local invData   = json.decode(inventory)

    local jobGrade = "null"
    if jobData and jobData.grade then
        jobGrade = (type(jobData.grade) == 'table') and (jobData.grade.level or jobData.grade.label) or jobData.grade
    end

    local infoOptions = {
        { title = 'License', description = license, icon = 'id-card' },
        { 
            title = 'Character Info', 
            description = string.format("Name: %s %s\nDOB: %s\nPhone: %s", 
                charData.firstname or "Unknown", charData.lastname or "", 
                charData.birthdate or "null", charData.phone or "null"),
            icon = 'user' 
        },
        { 
            title = 'Job & Finance', 
            description = string.format("Job: %s (Grade: %s)\nCash: $%s | Bank: $%s", 
                jobData.label or "Unemployed", jobGrade,
                moneyData.cash or 0, moneyData.bank or 0),
            icon = 'briefcase' 
        }
    }

    local items = {}
    if invData then
        for _, item in pairs(invData) do
            table.insert(items, string.format("%s (x%s)", item.name, item.amount))
        end
    end

    table.insert(infoOptions, {
        title = 'Inventory',
        description = #items > 0 and table.concat(items, ", ") or "Empty",
        icon = 'box-open'
    })

    lib.registerContext({
        id = 'player_view_menu',
        title = 'Staff: Player Management',
        options = infoOptions
    })
    
    lib.showContext('player_view_menu')
end)



RegisterNetEvent('uStaffPlayerInspector:receiveMultiplePlayers', function(results)
    local options = {}

    for _, data in ipairs(results) do
        local char = json.decode(data.charinfo)
        local fullName = ("%s %s"):format(char.firstname or "Unknown", char.lastname or "Player")

        table.insert(options, {
            title = fullName,
            description = ("License: %s"):format(data.license or "null"),
            icon = 'user',
            onSelect = function()
                -- Pass the data directly to the display event
                TriggerEvent('uStaffPlayerInspector:receivePlayerData', 
                    data.license, 
                    data.charinfo, 
                    data.job, 
                    data.inventory, 
                    data.money
                )
            end
        })
    end

    lib.registerContext({
        id = 'uStaffPlayerInspector_playerselect',
        title = 'Multiple Players Found',
        position = 'top-right',
        options = options
    })

    lib.showContext('uStaffPlayerInspector_playerselect')
end)