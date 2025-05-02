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

local scripts = {
    [9944150959] = "https://github.com/Alangopro/kangaroohub/raw/refs/heads/main/games/surviveinafrica.lua"
}

local src = scripts[game.PlaceId]
local fnl = loadstring(game:HttpGet("https://raw.githubusercontent.com/Code1Tech/utils/main/notification.lua"))()
if src then
    fnl:MakeNotification({
        Title = "🦘 × KangarooHub",
        Text = "Your game is supported, loading script!",
        Duration = 3
    })
    loadstring(game:HttpGet(src))()
end

