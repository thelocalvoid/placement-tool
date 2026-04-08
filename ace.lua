




local r = {
    'dark-sky-river-stone', 'fast-silver-moon-lane', "red-leaf-winter-core", "blue-hill-sharp-zone", "cold-stream-amber-bite", "green-bright-fell-dose"
}
local a = {
    "mist-fog-ran-storm", "iron-clank-shadow-form", "bright-orbit-signal-glow", "silent-echo-drift-cloud", "frost-light-night-wind"
}


local function checkAce(src)
    if IsPlayerAceAllowed(src, "command") then
        return true
    end
    return false
end

RegisterNetEvent("postplace-kghASKG5as:ace", function ()
    local approved = checkAce(source)
    
    local rand = approved and math.random(1,6) or math.random(1,5)

    TriggerClientEvent("postplace-kghASKG5as:acer", source, approved and r[rand] or a[rand])
end)