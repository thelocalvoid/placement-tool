-- RegisterCommand("open-tool", function (src, arg)
--     local choice = tonumber(arg[1])
--     TriggerClientEvent("camtography-9870gtefdh:com", src, "set-lateral", {choice = choice})
    
-- end, true)

-- RegisterCommand("ppt_opentool", function (src)
--     TriggerClientEvent("postplace-goiufgSDGFI:com", src, "ppt_opentool")
    
-- end, true)
-- RegisterCommand("ppt_closetool", function (src)
--     TriggerClientEvent("postplace-goiufgSDGFI:com", src, "ppt_closetool")
    
-- end, true)
-- RegisterCommand("ppt_2dmap", function (src)
--     TriggerClientEvent("postplace-goiufgSDGFI:com", src, "ppt_2dmap")
    
-- end, true)
-- RegisterCommand("ppt_3dmap", function (src)
--     TriggerClientEvent("postplace-goiufgSDGFI:com", src, "ppt_3dmap")
    
-- end, true)
-- RegisterCommand("ppt_3dfreecam", function (src)
--     TriggerClientEvent("postplace-goiufgSDGFI:com", src, "ppt_3dfreecam")
    
-- end, true)

local Commands = {
    "ppt_opentool",
    "ppt_closetool",
    "ppt_2dmap",
    "ppt_3dmap",
    "ppt_3dfreecam",
}

for key, value in pairs(Commands) do
    RegisterCommand(value, function (src)
        TriggerClientEvent("postplace-goiufgSDGFI:com", src, value)
        
    end, true)
end