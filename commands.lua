




local Commands = {
    "ppt_opentool",
    "ppt_closetool",
    "ppt_2dmap",
    "ppt_3dmap",
    -- "ppt_3dfreecam",
}

for key, value in pairs(Commands) do
    RegisterCommand(value, function (src)
        TriggerClientEvent("postplace-goiufgSDGFI:com", src, value)
        
    end, true)
end