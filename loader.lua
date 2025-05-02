--[[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⠿⠿⠿⠿⠿⠿⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⣤⣄⡀⠀⠰⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡖⠀⢀⣠⣤⣄⠀⠀⠀⠀
⠀⠀⠀⠀⠙⣿⣿⡟⢀⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⡀⢻⣿⣿⠋⠀⠀⠀⠀
⠀⠀⠀⠀⣠⣿⠏⢠⣾⣿⡟⠙⣿⣿⣿⣿⣿⣿⠋⢻⣿⣷⡄⠹⣿⣄⠀⠀⠀⠀
⠀⢰⣾⣿⣿⡏⢠⣿⣿⠏⢠⣦⠈⢿⣿⣿⡿⠁⣴⡄⠹⣿⣿⡄⢹⣿⣿⣷⡆⠀
⠀⠀⠙⢿⣿⠁⣼⣿⡟⢀⣿⣿⣇⠘⣿⣿⠃⣸⣿⣿⡀⢻⣿⣧⠈⣿⡿⠋⠀⠀
⠀⠀⠀⠸⠿⠀⣿⣿⠁⣸⡇⠀⣿⡀⢹⡏⢀⣿⠀⢸⣇⠈⣿⣿⠀⠿⠇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢿⣿⣤⡤⣤⣤⡄⢀⡤⠀⠀⢠⣤⣤⢤⣤⣿⡿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠘⢁⣤⣤⣤⣄⡀⠏⠀⠀⠀⢀⣠⣤⣤⣤⡈⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢻⣿⡍⠹⣿⣷⣤⣀⣀⣤⣾⣿⠏⢩⣿⡟⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣦⣈⠙⠿⠿⠿⠿⠋⣁⣴⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⣿⣶⣶⣶⣶⣿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--]]
print("🦘 KangarooHub loader starting...")

local scripts = {
    [9944150959] = "https://github.com/Alangopro/kangaroohub/raw/refs/heads/main/games/surviveinafrica.lua"
}

local placeId = game.PlaceId
print("Current PlaceId:", placeId)

local src = scripts[placeId]

local fnlSuccess, fnlResult = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Code1Tech/utils/main/notification.lua"))()
end)

if not fnlSuccess then
    warn("❌ Failed to load notification module:", fnlResult)
end

if src then
    print("✅ Script found for this game:", src)

    if fnlSuccess and fnlResult then
        fnlResult:MakeNotification({
            Title = "🦘 × KangarooHub",
            Text = "Your game is supported, loading script!",
            Duration = 3
        })
    else
        warn("⚠️ Notification module not loaded; skipping notification")
    end

    local ok, err = pcall(function()
        local scriptText = game:HttpGet(src)
        print("Loaded script content:\n", scriptText:sub(1, 200))
        loadstring(scriptText)()
    end)

    if not ok then
        warn("❌ Failed to execute game script:", err)
    end
else
    print("❌ This game is not supported. PlaceId:", placeId)
end
