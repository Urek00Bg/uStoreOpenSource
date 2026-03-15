local QBCore = exports['qb-core']:GetCoreObject()
local dbTable = Config.DatabaseTable or 'players'

--- Helper to send data back to client
local function sendData(src, data)
    if data then
        TriggerClientEvent('uStaffPlayerInspector:receivePlayerData', src, 
            data.license, 
            json.encode(data.charinfo), 
            json.encode(data.job), 
            json.encode(data.items or data.inventory),
            json.encode(data.money)
        )
    else
        TriggerClientEvent('uStaffPlayerInspector:receivePlayerData', src, nil)
    end
end

-- Check Admin Status
RegisterNetEvent('uStaffPlayerInspector:checkAdmin', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local isAdmin = player and Config.AdminList[player.PlayerData.license] or false
    
    TriggerClientEvent('uStaffPlayerInspector:adminStatus', src, isAdmin)
end)

-- Main Data Request
RegisterNetEvent('uStaffPlayerInspector:requestPlayerData', function(searchValue)
    local src = source
    if not searchValue or searchValue == "" then return end

    local targetId = tonumber(searchValue)
    local onlinePlayer = targetId and QBCore.Functions.GetPlayer(targetId)

    if onlinePlayer then
        return sendData(src, onlinePlayer.PlayerData)
    end


    local query = [[
        SELECT license, charinfo, job, inventory, money 
        FROM ]]..dbTable..[[ 
        WHERE license = ? OR citizenid = ? OR charinfo LIKE ?
    ]]
    local wildCardName = '%' .. searchValue .. '%'

    exports.oxmysql:execute(query, {searchValue, searchValue, wildCardName}, function(results)
        if not results or #results == 0 then
            return sendData(src, nil)
        end

        -- If multiple people found, send to selection menu
        if #results > 1 then
            TriggerClientEvent('uStaffPlayerInspector:receiveMultiplePlayers', src, results)
        else
            -- If exactly one person found, send data
            sendData(src, results[1])
        end
    end)
end)