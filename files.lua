




local exportPath = GetResourcePath(GetCurrentResourceName()) .. "/exports"

local function normalizePath(path)
    local first = path:gsub("//", "/")
    local second = first:gsub("/", "\\")
    return second
end

local function createXMLFile(filename, content)
    local filePath = exportPath .. "/" .. filename

    local file = io.open(filePath, "w+")
    if not file then
        --print("Failed to create file: " .. filename)
        return false
    end

    file:write(content)
    file:close()

    --print("File created: " .. filename)
    return true, normalizePath(filePath)
end

RegisterCommand("exportymap", function (source, args)

    local fileNamePrefix = args[1]

    if not fileNamePrefix then
        print("NO FILE NAME PROVIDED, CANCELING")
        return
    end

    TriggerClientEvent("ppt-exportrequest", source, fileNamePrefix)

end, true)


RegisterNetEvent("ppt-createFiles", function (data)
    local successes = {}
    local fails = {}

    print("Initiating ymap file creation sequence, on behalf of id:", source)

    for key, value in pairs(data) do
        local fileName = value.fileName
        local contents = value.contents
        print("^3Attempting to create file:^0", fileName)
        local success = createXMLFile(fileName, contents)
        if success then
            successes[#successes+1] = {
                fileName = fileName,
            }
        else
            fails[#fails+1] = {
                fileName = fileName,
            }
        end
    end
    local msg = ""
    for index, value in ipairs(successes) do
        print(value.fileName, "^2was created successfully^0")
        msg = msg .. value.fileName .."\t^2was created successfully^0\n"
    end
    for index, value in ipairs(fails) do
        print(value.fileName, "^1failed to create^0")
        msg = msg .. value.fileName .."\t^1failed to create^0\n"
    end
    if #successes >= 1 then
        print("^4New files are located at the path below^0")
        print("^4Absolute:^0", normalizePath(exportPath))
        print("^4WinSCP:  ^0", normalizePath(exportPath):match("\\resources\\.*"))
        msg = msg .. "^4New files are located at the path below^0\n"
        msg = msg .. "^4Absolute:^0\t" .. normalizePath(exportPath) .. "\n"
        msg = msg .. "^4WinSCP:  ^0\t" .. normalizePath(exportPath):match("\\resources\\.*") .. "\n"
    end
    TriggerClientEvent("ppt-fileCreationResponse", source, msg)
end)

    