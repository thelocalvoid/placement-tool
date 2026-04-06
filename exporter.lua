




local timeStart


-- RegisterCommand("exportTest", function (source, args)

--     local fileNamePrefix = args[1]

--     if not fileNamePrefix then
--         print("NO FILE NAME PROVIDED, CANCELING")
--         return
--     end

--     timeStart = GetGameTimer()
--     local ymapXmlData = CompileEntitiesToYmap(PropLines, fileNamePrefix)
--     TriggerServerEvent("ppt-createFiles", ymapXmlData)

-- end, true)

RegisterNetEvent("ppt-exportrequest", function(fileNamePrefix)
    
    timeStart = GetGameTimer()
    local ymapXmlData = CompileEntitiesToYmap(PropLines, fileNamePrefix)
    TriggerServerEvent("ppt-createFiles", ymapXmlData)

end)


RegisterNetEvent("ppt-fileCreationResponse", function (msg)
    Citizen.Trace(msg)
    print(string.format("%s %.2fs", "Operation completed in", ((GetGameTimer() - timeStart) / 1000)))
end)