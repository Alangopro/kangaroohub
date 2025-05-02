--[[ /*
* This code is protected by applicable copyright law and is licensed under the
* GNU General Public License v3 (GPL-3.0). Unauthorized reproduction, distribution,
* or modification of this code without permission is prohibited.
*
* For full license details, see: https://www.gnu.org/licenses/gpl-3.0.html
* Copyright (c) Kamerzystanasyt 2025
*/ --]]






local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = Character:WaitForChild("HumanoidRootPart")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local workNPC = workspace["NPCs Proximities"]:FindFirstChild("SugarShop")
local sellNPC150 = workspace["NPCs Proximities"]:FindFirstChild("SugarSell") 
local sellNPC270 = workspace["NPCs Proximities"]:FindFirstChild("SugarSellDoble")
local autoFarmEnabled = false
local cooldown = 6
local lastAttackTime = 0
local espEnabled = false
local speedValue = 16
local jumpPowerValue = 50

local function modifyProximityPrompt(prompt)
    if prompt then
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 100 
    end
end

if workNPC then modifyProximityPrompt(workNPC:FindFirstChildOfClass("ProximityPrompt")) end
if sellNPC150 then modifyProximityPrompt(sellNPC150:FindFirstChildOfClass("ProximityPrompt")) end
if sellNPC270 then modifyProximityPrompt(sellNPC270:FindFirstChildOfClass("ProximityPrompt")) end


local function teleportTo(target)
    if target and hrp then
        hrp.CFrame = target.CFrame - Vector3.new(0, 0.3, 0) 
        task.wait(0.5)
    end
end

local function disableCollisions()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function notify(title, content)
    if not title then title = "Notification" end
    if not content then content = "Unknown error occurred!" end
    Rayfield:Notify({ Title = tostring(title), Content = tostring(content), Duration = 2, Image = 4483362458 })
end

local function resetPlayer()
    notify("⚠ Resetting", "You were already working. Resetting player...")
    Character:BreakJoints()  
    LocalPlayer.CharacterAdded:Wait()  
    task.wait(2)  
    Character = LocalPlayer.Character  
    hrp = Character:WaitForChild("HumanoidRootPart")  
end


local function deliverSugar150()
    teleportTo(sellNPC150)
    task.wait(0.5)
    local prompt = sellNPC150:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        notify("✅ Success", "Sold sugar box for $150!")
    else
        notify("❌ Error", "Sell prompt not found for $150!")
    end
end

local function deliverSugar270()
    teleportTo(sellNPC270)
    task.wait(0.1)
    local prompt = sellNPC270:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        notify("✅ Success", "Sold sugar box for $270!")
    else
        notify("❌ Error", "Sell prompt not found for $270!")
    end
end


local function isAlreadyWorking()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    
    local sugarGui = playerGui:FindFirstChild("SugarGui")
    if sugarGui and sugarGui.Enabled then
        local textLabel = sugarGui.Frame.Framef.ImageLabel.TextLabel1
        if textLabel and textLabel.Text:lower():find("you are already working") then
            return true
        end
    end
    return false
end




local function waitForButtonClick()
    local workGui = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("SugarGui")
    if not workGui or not workGui.Enabled then
        notify("❌ Error", "SugarGui not found or not enabled!")
        return
    end

    local workButton = workGui.Frame.Framef.ImageLabel.TextLabel1.TextButton
    if not workButton then
        notify("❌ Error", "Work button not found!")
        return
    end

        --( this does not even work fr ) --
    local VirtualUser  = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(workButton.AbsolutePosition + Vector2.new(0, 0))

    notify("✅ Success", "Work button clicked!")
end




local function isNearFarm(player)
    local farms = {
        workspace.Farm.Farm1,
        workspace.Farm.Farm2,
        workspace.Farm.Farm3,
        workspace.Farm.Farm4
    }

    for _, farm in pairs(farms) do
        local farmPart = farm.PrimaryPart or farm:FindFirstChildWhichIsA("BasePart")
        if farmPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (farmPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < 50 then
                return true
            end
        end
    end
    return false
end



local function useBusinessTool(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local businessTool = LocalPlayer.Backpack:FindFirstChild("BusinessTool") or Character:FindFirstChild("BusinessTool")
    if businessTool then
        businessTool.Parent = Character
        businessTool:Activate()
        lastAttackTime = tick()
        notify("✅ Success", "Used BusinessTool on " .. player.Name)
    else
        notify("❌ Error", "BusinessTool not found!")
    end
end

local function attackPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team == Teams.People and not isNearFarm(player) then
            local targetHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                for _ = 1, 10 do
                    hrp.CFrame = targetHrp.CFrame
                    task.wait()
                end

                if tick() - lastAttackTime >= cooldown then
                    useBusinessTool(player)
                end
            end
        end
    end
end



local function autoFarmLoop()
    while autoFarmEnabled do
        attackPlayers()
        task.wait(0.5)
    end
end




local function toggleESP(value)
    espEnabled = value
    if espEnabled then
        local FillColor = Color3.fromRGB(175,25,255)
        local DepthMode = "AlwaysOnTop"
        local FillTransparency = 0.5
        local OutlineColor = Color3.fromRGB(255,255,255)
        local OutlineTransparency = 0

        local CoreGui = game:GetService("CoreGui")
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local connections = {}

        local Storage = Instance.new("Folder")
        Storage.Parent = CoreGui
        Storage.Name = "Highlight_Storage"

        local function Highlight(plr)
            local Highlight = Instance.new("Highlight")
            Highlight.Name = plr.Name
            Highlight.FillColor = FillColor
            Highlight.DepthMode = DepthMode
            Highlight.FillTransparency = FillTransparency
            Highlight.OutlineColor = OutlineColor
            Highlight.OutlineTransparency = 0
            Highlight.Parent = Storage
            
            local plrchar = plr.Character
            if plrchar then
                Highlight.Adornee = plrchar
            end

            connections[plr] = plr.CharacterAdded:Connect(function(char)
                Highlight.Adornee = char
            end)
        end

        Players.PlayerAdded:Connect(Highlight)
        for i,v in next, Players:GetPlayers() do
            Highlight(v)
        end

        Players.PlayerRemoving:Connect(function(plr)
            local plrname = plr.Name
            if Storage[plrname] then
                Storage[plrname]:Destroy()
            end
            if connections[plr] then
                connections[plr]:Disconnect()
            end
        end)
    else
        local CoreGui = game:GetService("CoreGui")
        if CoreGui:FindFirstChild("Highlight_Storage") then
            CoreGui.Highlight_Storage:Destroy()
        end
    end
end





local function updateSpeed(value)
    speedValue = value
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = speedValue
    end
end

local function updateJumpPower(value)
    jumpPowerValue = value
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = jumpPowerValue
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    Character = LocalPlayer.Character
    hrp = Character:WaitForChild("HumanoidRootPart")
    if Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = speedValue
        Character.Humanoid.JumpPower = jumpPowerValue
    end
end)

local function antiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local Window = Rayfield:CreateWindow({
    Name = "KangarooHub v2.3 | by Kamerzystanasyt",
    LoadingTitle = "Welcome " .. LocalPlayer.Name .. ", Loading...",
    LoadingSubtitle = "AutoFarm for Sugar NPCs",
    ConfigurationSaving = {
      Enabled = true,
      FolderName = "KangarooHub",
      FileName = "AfricaScript"
	},
	
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   
    Discord = {
      Enabled = true,
      Invite = "Demk9JpfMc",
      RememberJoins = true
    },
	
	KeySystem = false,
    KeySettings = {
      Title = "KangarooHub - Key System",
      Subtitle = "shitty keysystem",
      Note = "Visit https://gowno.szamancode.pl/script/getkey for the key.",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = true,
       -- ( does nothing for now ) --
      Key = {"https://auth.kangarooleaks.club/getkey"}
    }
})


local MainTab = Window:CreateTab("Main", 4483362458)
local CombatMainSection = MainTab:CreateSection("Combat")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")


local AttackRange = 4
local FistAuraEnabled = false

local function FistAuraAttack()
    local Character = LocalPlayer.Character
    if not Character then return end

    local PunchTool = LocalPlayer.Backpack:FindFirstChild("PunchTool") or Character:FindFirstChild("PunchTool")
    if not PunchTool then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance <= AttackRange then
                local success, err = pcall(function()
                    PunchTool:Activate()
                end)
                if not success then
                    warn("Failed to use PunchTool:", err)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if FistAuraEnabled then
        FistAuraAttack()
    end
end)


local FistAuraToggle = MainTab:CreateToggle({
    Name = "Fist Aura",
    CurrentValue = false,
    Flag = "FistAuraToggle",
    Callback = function(value)
        FistAuraEnabled = value
        if FistAuraEnabled then
            notify("✅ Fist Aura", "Enabled!")
        else
            notify("❌ Fist Aura", "Disabled!")
        end
    end
})





local UsefullMainSection = MainTab:CreateSection("Usefull")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local autoCollectEnabled = false
local TargetTeam = "Farmer"

local function FindTomatoPrompts()
    local foundPrompts = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText == "Collect tomatoes" then
            print("✅ Found 'Collect Tomatoes' at:", obj.Parent:GetFullName())
            table.insert(foundPrompts, obj)
        end
    end

    print("🍅 Total Tomato Prompts Found:", #foundPrompts)
    return foundPrompts
end



local function TweenTo(part)
    local TweenInfoData = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local Goal = {CFrame = part.CFrame + Vector3.new(0, 3, 0)}
    local Tween = TweenService:Create(HumanoidRootPart, TweenInfoData, Goal)
    Tween:Play()
    Tween.Completed:Wait()
end

 -- ( this works like shit ) --
local function AutoCollectTomatoes()
    notify("🍅 Auto Collect", "Started collecting tomatoes!", 3)
    
    while autoCollectEnabled do
        if LocalPlayer.Team and LocalPlayer.Team.Name ~= TargetTeam then
            notify("❌ Auto Collect Stopped", "You're no longer a Farmer!", 3)
            autoCollectEnabled = false
            return
        end

        local prompts = FindTomatoPrompts()
        print("Found " .. #prompts .. " tomato prompts!")

        if #prompts == 0 then
            notify("⚠️ No Tomatoes Found", "Try moving around!", 3)
        end

        local collected = 0

        for _, prompt in ipairs(prompts) do
            if not autoCollectEnabled then return end
            if collected >= 10 then
                break
            end

            local part = prompt.Parent
            if part and part:IsA("BasePart") then
                print("Moving to tomato at:", part.Position)
                TweenTo(part)
                wait(0.5)

                print("Attempting to collect tomato...")
                fireproximityprompt(prompt)

                collected = collected + 1
                notify("✅ Collected!", "Tomato #" .. collected .. " collected!", 1)
                wait(0.5)
            end
        end
        wait(1)
    end
end


local AutoCollectToggle = MainTab:CreateToggle({
    Name = "Auto Collect Tomatoes",
    CurrentValue = false,
    Flag = "AutoCollectTomatoes",
    Callback = function(value)
        autoCollectEnabled = value
        if autoCollectEnabled then
            notify("✅ Auto Collect Enabled", "Collecting tomatoes now!", 3)
            AutoCollectTomatoes()
        else
            notify("❌ Auto Collect Disabled", "Stopped collecting.", 3)
        end
    end
})




local autoLagEnabled = false

local function autoLagLoop()
    while autoLagEnabled do
        if sellNPC270 then
            fireproximityprompt(sellNPC270.ProximityPrompt, 1)
        end
        task.wait(0.01)
    end
end






local LagHelperDescription = MainTab:CreateParagraph({
    Title = "📖 How to Use (LAG) Helper",
    Content = [[
1️⃣  Enable Clumsy and set lag settings (optional).  
2️⃣  Press (LAG) Helper to start auto-spamming the sell NPC.  
3️⃣  Disable Clumsy after 15 seconds (or you will get kicked!)
    ]]
})



local LagHelperToggle = MainTab:CreateToggle({
    Name = "(LAG) Helper",
    CurrentValue = false,
    Flag = "LagHelperToggle",
    Callback = function(value)
        autoLagEnabled = value
        if autoLagEnabled then
            notify("✅ (LAG) Helper", "Activated!")
            coroutine.wrap(autoLagLoop)()
            
            task.spawn(function()
                task.wait(15)
                if autoLagEnabled then
                    notify("⚠️ WARNING", "Disable Clumsy NOW to avoid disconnection!")
                end
            end)
        else
            notify("❌ (LAG) Helper", "Deactivated!")
        end
    end
})






local AutoFarmsSection = MainTab:CreateSection("AutoFarms")
local AutoFarmsDescription = MainTab:CreateParagraph({
    Title = "📖 How to Use Auto Farms?",
    Content = [[
1️⃣  Launch an autofarm that you wanna use.  
2️⃣  Setup AutoClicker for the Work button.  
3️⃣  Everthing else should be done automaticly.
    ]]
})

local function autoFarm()
    while autoFarmEnabled do
        disableCollisions()

        if isAlreadyWorking() then
            resetPlayer()  
        end

        teleportTo(workNPC)
        task.wait(0.2)

        local workPrompt = workNPC:FindFirstChildOfClass("ProximityPrompt")
        if workPrompt then
            fireproximityprompt(workPrompt)
            task.wait(1)
            waitForButtonClick()
        else
            notify("❌ Error", "Work ProximityPrompt not found!")
        end

        task.wait(3)  

        local sellNPC = autoFarm150Enabled and sellNPC150 or sellNPC270
        local sellPrice = autoFarm150Enabled and 150 or 270

        teleportTo(sellNPC)
        task.wait(0.2)

        local sellPrompt = sellNPC:FindFirstChildOfClass("ProximityPrompt")
        if sellPrompt then
            fireproximityprompt(sellPrompt)
            notify("✅ Success", "Sold sugar box for $" .. sellPrice .. "!")
        else
            notify("❌ Error", "Sell prompt not found for $" .. sellPrice .. "!")
        end

        task.wait(3) 
    end
end



local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local SUGARGUI = Players.LocalPlayer.PlayerGui.SugarGui
local SP1 = Workspace["NPCs Proximities"].SugarSellDoble.ProximityPrompt
local ROOT = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local FARM_POSITION = CFrame.new(-350.4, 3.0, 145.9)
SP1.HoldDuration = 0.06

local spotAutoFarmEnabled = false

local function teleportBack()
    local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if root then
        root.CFrame = FARM_POSITION
    end
end

local function spotAutoFarm()
    while spotAutoFarmEnabled do
        local startTime = tick()

        while spotAutoFarmEnabled and tick() - startTime < 32 do
            local character = Players.LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then
                task.wait(1)
                teleportBack()
            end
            
            SUGARGUI.Frame.Framef.ImageLabel.TextLabel1.TextButton.Visible = true
            SUGARGUI.Enabled = true
            task.wait(0.02)
            fireproximityprompt(SP1)
            task.wait()
        end

        if spotAutoFarmEnabled then
            notify("⏳ Spot AutoFarm", "Taking a 15-second break...") 
            task.wait(15)
            teleportBack()
        end
    end
end

local ToggleSpotAF = MainTab:CreateToggle({
    Name = "Enable $270 (Spot) AutoFarm",
    CurrentValue = false,
    Flag = "SpotFarm",
    Callback = function(value)
        spotAutoFarmEnabled = value 

        if spotAutoFarmEnabled then
            notify("✅ $270 (Spot) AutoFarm", "Started!")
            task.spawn(spotAutoFarm)
        else
            notify("❌ $270 (Spot) AutoFarm", "Stopped!")
        end
    end
})



local Toggle150 = MainTab:CreateToggle({
    Name = "Enable $150 AutoFarm",
    CurrentValue = false,
    Flag = "AutoFarm150Toggle",
    Callback = function(value)
        autoFarm150Enabled = value
        autoFarmEnabled = autoFarm150Enabled or autoFarm270Enabled
        if autoFarm150Enabled then
            notify("✅ $150 AutoFarm", "Started!")
            autoFarm()
        else
            notify("❌ $150 AutoFarm", "Stopped!")
        end
    end
})

local Toggle270 = MainTab:CreateToggle({
    Name = "Enable $270 AutoFarm",
    CurrentValue = false,
    Flag = "AutoFarm270Toggle",
    Callback = function(value)
        autoFarm270Enabled = value
        autoFarmEnabled = autoFarm150Enabled or autoFarm270Enabled
        if autoFarm270Enabled then
            notify("✅ $270 AutoFarm", "Started!")
            autoFarm()
        else
            notify("❌ $270 AutoFarm", "Stopped!")
        end
    end
})



local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Enable Business Man AutoFarm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        autoFarmEnabled = value
        if autoFarmEnabled then
            notify("✅ AutoFarm", "Started!")
            coroutine.wrap(autoFarmLoop)()
        else
            notify("❌ AutoFarm", "Stopped!")
        end
    end
})




local function notify(title, message)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = 3,
        Image = nil,
        Actions = {}
    })
end











local OtherMainSection = MainTab:CreateSection("Other")
local function fixBug()
    local player = game.Players.LocalPlayer
    if player.Character then
        player.Character:BreakJoints()
    end
    task.wait(2)
    if workNPC then
        player.Character:SetPrimaryPartCFrame(workNPC.CFrame + Vector3.new(0, 3, 0))
    end
    Rayfield:Notify({
        Title = "🔄 Fix Applied",
        Content = "Character reset & teleported back!",
        Duration = 3
    })
end







local function EnableFastInteraction()
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end
    end
    notify("✅ Insta Interact", "All prompts are now instant!")
end

local InstaInteractButton = MainTab:CreateButton({
    Name = "⚡ Insta Interact",
    Callback = function()
        EnableFastInteraction()
    end
})






local UnStuckDescription = MainTab:CreateParagraph({
    Title = "📖 What to do if i am stuck in (already working)?",
    Content = [[
Launch the fix button bellow,
After it everything should work fine!	
    ]]
})

local FixBugButton = MainTab:CreateButton({
    Name = "Fix Already Working Bug",
    Callback = function()
        fixBug()
    end
})


local MainUselessescription = MainTab:CreateParagraph({
    Title = "📖 Useless",
    Content = [[
Bellow are the useless modules.
    ]]
})




local ROOT_POSITION = Vector3.new(-350, 3, 137) 
local bodySpammerEnabled = false

local function bodySpammer()
    while bodySpammerEnabled do
        game:GetService("Players").LocalPlayer.Character:BreakJoints()
        task.wait(0.5)

        local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        root.CFrame = CFrame.new(ROOT_POSITION)
        task.wait(0.5)
    end
end

local ToggleBodySpammer = MainTab:CreateToggle({
    Name = "Enable Body Spammer",
    CurrentValue = false,
    Flag = "BodySpammer",
    Callback = function(value)
        bodySpammerEnabled = value
        
        if bodySpammerEnabled then
            notify("✅ Body Spammer", "Started!")
            task.spawn(bodySpammer)
        else
            notify("❌ Body Spammer", "Stopped!")
        end
    end
})





local AntiAFKButton = MainTab:CreateButton({
    Name = "Enable Anti-AFK",
    Callback = function()
        antiAFK()
        notify("✅ Anti-AFK", "Enabled!")
    end
})

local DiscordButton = MainTab:CreateButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("https://kangarooleaks.club/discord")
        notify("📋 Copied!", "Discord invite link has been copied to clipboard!")
    end
})







local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local NPCTeleportsSection = TeleportsTab:CreateSection("Your cordinates")
local CoordinatesLabel = TeleportsTab:CreateLabel("Coordinates: X: 0, Y: 0, Z: 0")

local function getPlayerPosition()
    if LocalPlayer.Character then
        local part = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or
                    LocalPlayer.Character:FindFirstChild("Torso") or
                    LocalPlayer.Character.PrimaryPart

        if part then
            return part.Position
        else
            return LocalPlayer.Character:GetPivot().Position
        end
    else
        warn("Player Character not found!")
        return Vector3.new(0, 0, 0)
    end
end


local NPCTeleportsSection = TeleportsTab:CreateSection("Player Teleporter")
local selectedPlayer = nil

local PlayerDropdown = TeleportsTab:CreateDropdown({
    Name = "Select Player",
    Options = {},
    CurrentOption = nil,
    Flag = "PlayerList",
    Callback = function(value)
        selectedPlayer = value
    end
})

-- Function to Update Player List
local function updatePlayerList()
    local playerNames = {}
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        table.insert(playerNames, player.Name)
    end

    if #playerNames == 0 then
        playerNames = {"No Players Found"}
    end

    PlayerDropdown:Refresh(playerNames)
end

task.spawn(function()
    while true do
        updatePlayerList()
        task.wait(5)
    end
end)

local TeleportButton = TeleportsTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = game:GetService("Players"):FindFirstChild(selectedPlayer)

            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

                while not targetHRP do
                    task.wait(0.1)
                    targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                end

                local localPlayer = game:GetService("Players").LocalPlayer
                if localPlayer and localPlayer.Character then
                    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
                        notify("✅ Teleported!", "You have been teleported to " .. selectedPlayer)
                        return
                    end
                end
            end

            notify("❌ Teleport Failed", "Player not found or missing HumanoidRootPart!")
        else
            notify("⚠️ No Player Selected", "Please select a player from the list!")
        end
    end
})






local NPCTeleportsSection = TeleportsTab:CreateSection("NPC Teleports")

local function updateCoordinates()
    while true do
        task.wait(0.1)
        local position = getPlayerPosition()
        CoordinatesLabel:Set(string.format("Coordinates: X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z))
    end
end

coroutine.wrap(updateCoordinates)()



local NPCTeleportsParagraph = TeleportsTab:CreateParagraph({
    Title = "NPC Teleports",
    Content = "Teleport to various NPCs in the game. Use these to quickly move to important locations."
})



local teleports = {
    { Name = "Work NPC", Location = CFrame.new(-109, 3, -135) },
    { Name = "Sell $270 NPC", Location = CFrame.new(-350, 3, 140) },
    { Name = "Sell $150 NPC", Location = CFrame.new(146, 3, 124) },
	
    { Name = "Heal NPC", Location = CFrame.new(-105, 3, -115) },
    { Name = "Syrup NPC", Location = CFrame.new(-150, 3, -162) },
    { Name = "Food Shop", Location = CFrame.new(-171, 3, -97) },

	
    { Name = "Pants NPC", Location = CFrame.new(-180, 3, -137) },
    { Name = "Clothes NPC", Location = CFrame.new(-125, 3, -164) },

    { Name = "Business Man NPC", Location = CFrame.new(275, 3, 684) },
	
    { Name = "Plants Shop", Location = CFrame.new(674, 3, 88) },
    { Name = "Potted Plant Lover", Location = CFrame.new(663, 3, 67) },
	
    { Name = "Construction NPC", Location = CFrame.new(553, 110, 653) },
    { Name = "Electricity NPC", Location = CFrame.new(546, 3, 156) },
    { Name = "Trap NPC", Location = CFrame.new(670, 48, 23) },
	
    { Name = "Bomb NPC", Location = CFrame.new(-110, 3, -156) },
    { Name = "Rifle NPC", Location = CFrame.new(872, 3, -9) },
    { Name = "Gun NPC", Location = CFrame.new(500, 3, 50) },

}

for _, teleport in pairs(teleports) do
    TeleportsTab:CreateButton({
        Name = teleport.Name,
        Callback = function()
            if hrp then
                hrp.CFrame = teleport.Location
                notify("✅ Teleport", "Teleported to " .. teleport.Name .. "!")
            else
                notify("❌ Error", "HumanoidRootPart not found!")
            end
        end
    })
end


local UtilityTeleportsSection = TeleportsTab:CreateSection("Utility Teleports")

local UtilityTeleportsParagraph = TeleportsTab:CreateParagraph({
    Title = "Utility Teleports",
    Content = "Use these teleports for quick access to useful locations or functions."
})


local CTeleportsDescription = TeleportsTab:CreateParagraph({
    Title = "📖 City Teleports",
    Content = [[
Most usefull places for you to use.
    ]]
})


local CityTPSSection = TeleportsTab:CreateSection("City Teleports")

TeleportsTab:CreateButton({
    Name = "Cotton Farm",
    Callback = function()
        if hrp then
            hrp.CFrame = CFrame.new(447.6, 3.0, -576.5)
            notify("✅ Teleport", "Teleported to Cotton Farm!")
        else
            notify("❌ Error", "HumanoidRootPart not found!")
        end
    end
})


TeleportsTab:CreateButton({
    Name = "Oil Sell",
    Callback = function()
        if hrp then
            hrp.CFrame = CFrame.new(90.5, 3.2, 534.5)
            notify("✅ Teleport", "Teleported to Oil Store!")
        else
            notify("❌ Error", "HumanoidRootPart not found!")
        end
    end
})

TeleportsTab:CreateButton({
    Name = "Cactus Sell",
    Callback = function()
        if hrp then
            hrp.CFrame = CFrame.new(-309, 15.6, 350.3)
            notify("✅ Teleport", "Teleported to Cactus Sell!")
        else
            notify("❌ Error", "HumanoidRootPart not found!")
        end
    end
})

TeleportsTab:CreateButton({
    Name = "Cactus Sell All",
    Callback = function()
        if hrp then
            hrp.CFrame = CFrame.new(-339, 15.6, 367)
            notify("✅ Teleport", "Teleported to Cactus Sell All!")
        else
            notify("❌ Error", "HumanoidRootPart not found!")
        end
    end
})


TeleportsTab:CreateButton({
    Name = "House Sell",
    Callback = function()
        if hrp then
            hrp.CFrame = CFrame.new(-98.2, 14.6, 509.9)
            notify("✅ Teleport", "Teleported to House Sell!")
        else
            notify("❌ Error", "HumanoidRootPart not found!")
        end
    end
})


TeleportsTab:CreateButton({
    Name = "Mountain Top",
    Callback = function()
        if hrp then
            hrp.CFrame = CFrame.new(-276, 277, 493)
            notify("✅ Teleport", "Teleported to Mountain Top!")
        else
            notify("❌ Error", "HumanoidRootPart not found!")
        end
    end
})





local ETPDescription = TeleportsTab:CreateParagraph({
    Title = "📖 Things Teleports",
    Content = [[
Event like teleport places.
    ]]
})


local CityTPSSection = TeleportsTab:CreateSection("Event Teleports")


TeleportsTab:CreateButton({
    Name = "Teleport to Nearest Crate",
    Callback = function()
        local crates = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Crate" and obj:IsA("Model") then
                table.insert(crates, obj)
            end
        end

        if #crates > 0 then
            local nearestCrate = crates[1]
            local nearestDistance = math.huge

            for _, crate in pairs(crates) do
                local cratePart = crate.PrimaryPart or crate:FindFirstChildWhichIsA("BasePart")
                if cratePart then
                    local distance = (hrp.Position - cratePart.Position).Magnitude
                    if distance < nearestDistance then
                        nearestCrate = crate
                        nearestDistance = distance
                    end
                end
            end

            local cratePart = nearestCrate.PrimaryPart or nearestCrate:FindFirstChildWhichIsA("BasePart")
            if cratePart then
                teleportTo(cratePart)
                notify("✅ Teleport", "Teleported to nearest crate!")
            else
                notify("❌ Error", "Crate has no valid part to teleport to!")
            end
        else
            notify("❌ Error", "No crates found!")
        end
    end
})




local RenderTab = Window:CreateTab("Render", 4483362458)

local RendersDescription = RenderTab:CreateParagraph({
    Title = "📖 Renders",
    Content = [[
Some of the render features.
(boxes might not update but idk)
    ]]
})


local RenderSection = RenderTab:CreateSection("Render")


local PlayerESPToggle = RenderTab:CreateToggle({
    Name = "Enable Player ESP",
    CurrentValue = false,
    Flag = "PlayerESPToggle",
    Callback = function(value)
        toggleESP(value)
    end
})

local CrateHighlightToggle = RenderTab:CreateToggle({
    Name = "Highlight Crates",
    CurrentValue = false,
    Flag = "CrateHighlightToggle",
    Callback = function(value)
        if value then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Crate" then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Parent = obj
                    Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0

                    local BillboardGui = Instance.new("BillboardGui")
                    BillboardGui.Parent = obj
                    BillboardGui.Adornee = obj
                    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)

                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Parent = BillboardGui
                    TextLabel.Text = "Crate #" .. tostring(obj:GetAttribute("CrateNumber") or "?")
                    TextLabel.TextColor3 = Color3.new(1, 1, 1)
                    TextLabel.TextScaled = true
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                end
            end
        else
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Crate" then
                    local highlight = obj:FindFirstChild("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    local billboard = obj:FindFirstChild("BillboardGui")
                    if billboard then
                        billboard:Destroy()
                    end
                end
            end
        end
    end
})



local UtilityTab = Window:CreateTab("Utility", 4483362458)

local UtilitiesDescription = UtilityTab:CreateParagraph({
    Title = "📖 Utils",
    Content = [[
Bellow are features you mostly would want to use.
    ]]
})


local UtilitySection = UtilityTab:CreateSection("Utility")

local AimbotButton = UtilityTab:CreateButton({
    Name = "(Shit) Aim Bot",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yzeedw/Mortalv2-main/main/UNIVERSAL%20AIMBOT%20V2"))()
    end
})

local BetterAimbotButton = UtilityTab:CreateButton({
    Name = "(Open) Aim Bot",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ttwizz/Open-Aimbot/master/source.lua"))()
    end
})

local InfinityYeldButton = UtilityTab:CreateButton({
    Name = "Infinity Yeld",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

local BetterAimbotButton = UtilityTab:CreateButton({
    Name = "(Free) GamePasses",
    Callback = function()
        loadstring(game:HttpGet('https://gist.githubusercontent.com/dark-modz/6982de484735e730494b2d5a10fd6a2a/raw/a92563b0cd6a63683341a09f54baccea5349ed69/feGamepassV2'))()
    end
})



local Teams = game:GetService("Teams")
local LocalPlayer = game:GetService("Players").LocalPlayer
local TeamNames = {}

for _, team in pairs(Teams:GetChildren()) do
    table.insert(TeamNames, team.Name)
end

local TeamDropdown = UtilityTab:CreateDropdown({
    Name = "Change Team",
    Options = TeamNames,
    CurrentOption = "",
    Flag = "TeamDropdown",
    Callback = function(selectedTeam)
        local team = Teams:FindFirstChild(selectedTeam)
        if team then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local success, err = pcall(function()
                    LocalPlayer.Character:SetTeam(team)
                end)
                if not success then
                    LocalPlayer.Team = team
                end
            else
                LocalPlayer.Team = team
            end
            notify("✅ Team Changed", "You are now on " .. selectedTeam)
        else
            notify("❌ Error", "Invalid team selected!")
        end
    end
})


local NoClipEnabled = false
local NoClipToggle = UtilityTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(value)
        NoClipEnabled = value
        local LocalPlayer = game.Players.LocalPlayer
        game:GetService("RunService").Stepped:Connect(function()
            if NoClipEnabled then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
        notify(value and "✅ NoClip Enabled" or "❌ NoClip Disabled", "")
    end
})


-- Infinite Jump Toggle
local InfiniteJumpEnabled = false
local InfiniteJumpToggle = UtilityTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(value)
        InfiniteJumpEnabled = value
        if InfiniteJumpEnabled then
            notify("✅ Infinite Jump", "Enabled!")
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if InfiniteJumpEnabled then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        else
            notify("❌ Infinite Jump", "Disabled!")
        end
    end
})



-- Gravity Slider
local GravitySlider = UtilityTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 196.2},
    Increment = 1,
    Suffix = " G",
    CurrentValue = game.Workspace.Gravity,
    Flag = "GravitySlider",
    Callback = function(value)
        game.Workspace.Gravity = value
    end
})


local SpeedSlider = UtilityTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(value)
        updateSpeed(value)
    end
})

local JumpPowerSlider = UtilityTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        updateJumpPower(value)
    end
})
